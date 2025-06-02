using ZipFile
using EzXML

# Funktion för att extrahera 3Dmodel.model från 3MF-fil
function extract_3dmodel_from_3mf(file_path::String)
    r = ZipFile.Reader(file_path)
    for f in r.files
        if f.name == "3D/3Dmodel.model"
            content = read(f, String)
            close(r)
            return content
        end
    end
    close(r)
    error("3Dmodel.model not found in 3MF file")
end

# Funktion för att parsa XML och extrahera data
function parse_3dmodel(xml_content::String)
    doc = parsexml(xml_content)
    root = doc.root

    # Namnrymder
    ns_core = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
    ns_material = "http://schemas.microsoft.com/3dmanufacturing/material/2015/02"

    # Extrahera metadata
    metadata = Dict{String, String}()
    for meta in findall("//core:metadata", root, ["core"=>ns_core])
        name = meta["name"]
        value = nodecontent(meta)
        metadata[name] = value
    end

    # Extrahera färger
    colors = Dict{Int, Vector{String}}()
    for colorgroup in findall("//material:colorgroup", root, ["material"=>ns_material])
        group_id = parse(Int, colorgroup["id"])
        group_colors = String[]
        for color in findall("material:color", colorgroup, ["material"=>ns_material])
            push!(group_colors, color["color"])
        end
        colors[group_id] = group_colors
    end

    # Extrahera vertices och trianglar
    vertices = Vector{Tuple{Float64, Float64, Float64}}()
    triangles = Vector{Tuple{Int, Int, Int, Union{String, Nothing}, Union{Int, Nothing}}}()

    for mesh in findall("//core:mesh", root, ["core"=>ns_core])
        for vertex in findall("core:vertices/core:vertex", mesh, ["core"=>ns_core])
            x = parse(Float64, vertex["x"])
            y = parse(Float64, vertex["y"])
            z = parse(Float64, vertex["z"])
            push!(vertices, (x, y, z))
        end

        for triangle in findall("core:triangles/core:triangle", mesh, ["core"=>ns_core])
            v1 = parse(Int, triangle["v1"]) + 1
            v2 = parse(Int, triangle["v2"]) + 1
            v3 = parse(Int, triangle["v3"]) + 1
            pid = haskey(triangle, "pid") ? triangle["pid"] : nothing
            p1 = haskey(triangle, "p1") ? parse(Int, triangle["p1"]) : nothing
            push!(triangles, (v1, v2, v3, pid, p1))
        end
    end

    return metadata, colors, vertices, triangles
end

# Funktion för att identifiera dimensioner och sida baserat på färg
function analyze_model(vertices, triangles, colors, target_color::String)
    # Beräkna dimensioner
    dimensions = (
        x_min = minimum(v[1] for v in vertices),
        x_max = maximum(v[1] for v in vertices),
        y_min = minimum(v[2] for v in vertices),
        y_max = maximum(v[2] for v in vertices),
        z_min = minimum(v[3] for v in vertices),
        z_max = maximum(v[3] for v in vertices)
    )
    box_length = dimensions.x_max - dimensions.x_min
    box_width = dimensions.y_max - dimensions.y_min

    # Mappa sidor till trianglar och färger
    # Sida 1: Topp (z ≈ 0), Sida 2: Fram (y ≈ 0), Sida 3: Botten (z ≈ 30), Sida 4: Bak (y ≈ 30)
    # Vi grupperar trianglar baserat på deras vertices
    sides = Dict(
        1 => [],  # Topp (z ≈ 0)
        2 => [],  # Fram (y ≈ 0)
        3 => [],  # Botten (z ≈ 30)
        4 => []   # Bak (y ≈ 30)
    )

    for (i, t) in enumerate(triangles)
        v1, v2, v3, pid, p1 = t
        vert1 = vertices[v1]
        vert2 = vertices[v2]
        vert3 = vertices[v3]

        # Beräkna genomsnittliga Z- och Y-värden för att identifiera sida
        avg_z = (vert1[3] + vert2[3] + vert3[3]) / 3
        avg_y = (vert1[2] + vert2[2] + vert3[2]) / 3

        if avg_z < 1.0  # Topp (z ≈ 0)
            push!(sides[1], (i, pid, p1))
        elseif avg_y < 1.0  # Fram (y ≈ 0)
            push!(sides[2], (i, pid, p1))
        elseif avg_z > 29.0  # Botten (z ≈ 30)
            push!(sides[3], (i, pid, p1))
        elseif avg_y > 29.0  # Bak (y ≈ 30)
            push!(sides[4], (i, pid, p1))
        end
    end

    # Identifiera vilken sida som har target_color
    sinusoidal_side = 2  # Standardvärde
    for side in 1:4
        for (tri_idx, pid, p1) in sides[side]
            if !isnothing(pid) && !isnothing(p1)
                group = parse(Int, pid)
                idx = p1 + 1
                if haskey(colors, group) && idx <= length(colors[group])
                    color = colors[group][idx]
                    if color == target_color
                        sinusoidal_side = side
                        break
                    end
                end
            end
        end
    end

    return box_length, box_width, sinusoidal_side
end

# Funktion för att generera G-code
function generate_shifted_sinusoidal_box_gcode(amplitude, frequency, layer_height, num_layers, box_length, box_width, line_spacing, shift_interval, extrusion_factor, filename, sinusoidal_side)
    build_plate_size = 223.0
    box_offset_x = (build_plate_size - box_length) / 2
    box_offset_y = (build_plate_size - box_width) / 2

    open(filename, "w") do io
        println(io, "; Shifted Sinusoidal Box G-code")
        println(io, "G21                 ; Set units to millimeters")
        println(io, "G90                 ; Absolute positioning")
        println(io, "M104 S200           ; Set extruder temperature to 200°C")
        println(io, "M140 S60            ; Set bed temperature to 60°C")
        println(io, "M190 S60            ; Wait for bed temperature")
        println(io, "M109 S200           ; Wait for extruder temperature")
        println(io, "G28                 ; Home all axes")
        println(io, "G92 E0              ; Reset extruder position")
        println(io, "M106 P0 S255        ; Start concrete pump")

        println(io, "G1 X$(box_offset_x) Y$(box_offset_y) Z0.2 F600 ; Move to start position without extruding")
        println(io, "G92 E0              ; Reset extruder position")

        wavelength = π / frequency
        shift = 0.0

        for layer in 1:num_layers
            z = layer * layer_height
            println(io, "\n; Layer $layer")
            println(io, "G1 Z$(z) F600       ; Move to layer height $(z) mm")

            if layer % shift_interval == 0
                shift += wavelength / 2
            end

            e_total = 0.0

            for side in 1:4
                if side == 1
                    x = 0.0
                    y_prev = 0.0
                    while x <= box_length
                        if sinusoidal_side == 1
                            y = amplitude * sin(frequency * (x + shift))
                        else
                            y = 0.0
                        end
                        y_absolute = y + box_offset_y
                        dist = sqrt(line_spacing^2 + (y - y_prev)^2)
                        e = dist * extrusion_factor
                        e_total += e

                        println(io, "G1 X$(round(x + box_offset_x, digits=2)) Y$(round(y_absolute, digits=2)) Z$(round(z, digits=2)) E$(round(e_total, digits=4)) F600")
                        x += line_spacing
                        y_prev = y
                    end
                elseif side == 2
                    y = 0.0
                    x_prev = box_length
                    while y <= box_width
                        if sinusoidal_side == 2
                            x = amplitude * sin(frequency * (y + shift))
                        else
                            x = 0.0
                        end
                        x_absolute = x + box_offset_x + box_length
                        dist = sqrt(line_spacing^2 + (x - x_prev)^2)
                        e = dist * extrusion_factor
                        e_total += e

                        println(io, "G1 X$(round(x_absolute, digits=2)) Y$(round(y + box_offset_y, digits=2)) Z$(round(z, digits=2)) E$(round(e_total, digits=4)) F600")
                        y += line_spacing
                        x_prev = x
                    end
                elseif side == 3
                    x = box_length
                    y_prev = box_width
                    while x >= 0
                        if sinusoidal_side == 3
                            y = amplitude * sin(frequency * (x + shift))
                        else
                            y = 0.0
                        end
                        y_absolute = y + box_offset_y + box_width
                        dist = sqrt(line_spacing^2 + (y - y_prev)^2)
                        e = dist * extrusion_factor
                        e_total += e

                        println(io, "G1 X$(round(x + box_offset_x, digits=2)) Y$(round(y_absolute, digits=2)) Z$(round(z, digits=2)) E$(round(e_total, digits=4)) F600")
                        x -= line_spacing
                        y_prev = y
                    end
                elseif side == 4
                    y = box_width
                    x_prev = 0.0
                    while y >= 0
                        if sinusoidal_side == 4
                            x = amplitude * sin(frequency * (y + shift))
                        else
                            x = 0.0
                        end
                        x_absolute = x + box_offset_x
                        dist = sqrt(line_spacing^2 + (x - x_prev)^2)
                        e = dist * extrusion_factor
                        e_total += e

                        println(io, "G1 X$(round(x_absolute, digits=2)) Y$(round(y + box_offset_y, digits=2)) Z$(round(z, digits=2)) E$(round(e_total, digits=4)) F600")
                        y -= line_spacing
                        x_prev = x
                    end
                end
            end
        end

        println(io, "\n; === END ===")
        println(io, "M107 P0             ; Stop concrete pump")
        println(io, "G1 Z10 F3000        ; Raise nozzle")
        println(io, "G28 X0 Y0           ; Home X and Y axes")
        println(io, "M84                 ; Disable motors")
    end
end

# Huvudfunktion som binder ihop allt
function main(three_mf_file::String, target_color::String)
    # Steg 1: Läs och parsa 3MF-fil
    xml_content = extract_3dmodel_from_3mf(three_mf_file)
    metadata, colors, vertices, triangles = parse_3dmodel(xml_content)

    # Steg 2: Analysera modell och få parametrar
    box_length, box_width, sinusoidal_side = analyze_model(vertices, triangles, colors, target_color)

    # Steg 3: Sätt standardparametrar för G-code-generering
    amplitude = 1.0
    frequency = 0.8
    layer_height = 0.3
    num_layers = 100
    line_spacing = 1.0
    shift_interval = 4
    extrusion_factor = 0.05
    filename = "sinusoidal_box_from_3mf_1.gcode"

    # Skriv ut parametrar för verifiering
    println("Extracted parameters:")
    println("  Box Length: $box_length mm")
    println("  Box Width: $box_width mm")
    println("  Sinusoidal Side: $sinusoidal_side (based on color $target_color)")

    # Steg 4: Generera G-code
    generate_shifted_sinusoidal_box_gcode(
        amplitude,
        frequency,
        layer_height,
        num_layers,
        box_length,
        box_width,
        line_spacing,
        shift_interval,
        extrusion_factor,
        filename,
        sinusoidal_side
    )

    println("G-code generated: $filename")
end

# Kör programmet
main("cube_6color2.3mf", "#449648FF")
