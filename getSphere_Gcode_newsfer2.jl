function generate_sphere_gcode(radius::Float64, layer_height::Float64, resolution::Int=100)
    # Skrivarinställningar
    filament_diameter = 1.75
    nozzle_diameter = 0.4
    line_width = nozzle_diameter
    print_speed = 1500
    hotend_temp = 210
    bed_temp = 60

    # Byggplattans mitt för Ultimaker 2+ Connect
    center_x = 111.5
    center_y = 110.0

    # Beräkningar för extrudering
    layer_area = line_width * layer_height
    filament_area = π * (filament_diameter / 2)^2

    output = IOBuffer()

    # Init G-code
    println(output, "; G-code for centered sphere")
    println(output, "G21 ; mm units")
    println(output, "G90 ; absolute positioning")
    println(output, "M82 ; extruder absolute mode")
    println(output, "M104 S$hotend_temp ; hotend temp")
    println(output, "M140 S$bed_temp ; bed temp")
    println(output, "M109 S$hotend_temp ; wait for hotend")
    println(output, "M190 S$bed_temp ; wait for bed")
    println(output, "G28 ; home all axes")
    println(output, "G92 E0 ; reset extruder")
    println(output, "M107 ; fan off")

    # Snabb förflyttning till startpunkt (radie bort från centrum i X-led)
    start_x = round(center_x + radius, digits=3)
    start_y = round(center_y + 0.0, digits=3)
    start_z = round(layer_height, digits=3)
    println(output, "G0 F9000 X$start_x Y$start_y Z$start_z")

    # Lager-för-lager
    z = 0.0
    total_e = 0.0
    while z <= 2 * radius
        rel_z = z - radius
        if abs(rel_z) > radius
            z += layer_height
            continue
        end

        r = sqrt(radius^2 - rel_z^2)
        println(output, "; Layer at Z = $(round(z, digits=2))")
        println(output, "G1 Z$(round(z, digits=3)) F1000")

        prev_x = r + center_x
        prev_y = 0.0 + center_y
        println(output, "G1 X$(round(prev_x, digits=3)) Y$(round(prev_y, digits=3)) F$print_speed")

        for i in 1:resolution
            angle = 2π * i / resolution
            x = r * cos(angle) + center_x
            y = r * sin(angle) + center_y
            dx = x - prev_x
            dy = y - prev_y
            distance = sqrt(dx^2 + dy^2)

            e = (layer_area * distance) / filament_area
            total_e += e

            println(output, "G1 X$(round(x, digits=3)) Y$(round(y, digits=3)) E$(round(total_e, digits=5)) F$print_speed")

            prev_x = x
            prev_y = y
        end

        z += layer_height
    end

    # Avslutning
    println(output, "M104 S0 ; hotend off")
    println(output, "M140 S0 ; bed off")
    println(output, "G1 X0 Y0 F3000 ; home position")
    println(output, "M84 ; disable motors")

    return String(take!(output))
end

# Kör och spara G-code
gcode = generate_sphere_gcode(10.0, 0.2)

open("sphere_10mm_centered.gcode", "w") do file
    write(file, gcode)
end

println("✅ Centrerad sfär genererad och sparad som 'sphere_10mm_centered.gcode'")
