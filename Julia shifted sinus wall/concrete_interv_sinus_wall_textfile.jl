function generate_shifted_sinusoidal_wall_gcode(amplitude, frequency, layer_height, num_layers, wall_length, line_spacing, shift_interval, extrusion_factor, filename)
    open(filename, "w") do io
        # Initiera G-kod
        println(io, "; Shifted Sinusoidal Wall G-code")
        println(io, "G21                 ; Set units to millimeters")
        println(io, "G90                 ; Absolute positioning")
        println(io, "M104 S200           ; Set extruder temperature to 200°C")
        println(io, "M140 S60            ; Set bed temperature to 60°C")
        println(io, "M190 S60            ; Wait for bed temperature")
        println(io, "M109 S200           ; Wait for extruder temperature")
        println(io, "G28                 ; Home all axes")
        println(io, "G92 E0              ; Reset extruder position")
        println(io, "M106 P0 S255        ; Start concrete pump")

        # Parametrar
        wavelength = π / frequency  # Beräknad våglängd
        shift = 0.0                 # Initial förskjutning

        for layer in 1:num_layers
            z = layer * layer_height
            println(io, "\n; Layer $layer")
            println(io, "G1 Z$(z) F600       ; Move to layer height $(z) mm")

            # Uppdatera förskjutning efter varje "shift_interval" lager
            if layer % shift_interval == 0
                shift += wavelength / 2  # Förskjutning med en halv våglängd
            end

            # Generera vågor för lagret
            x = 0.0
            y_prev = 0.0
            e_total = 0.0
            while x <= wall_length
                y = amplitude * sin(frequency * (x + shift))  # Sinus med förskjutning
                dist = sqrt(line_spacing^2 + (y - y_prev)^2)  # Beräkna distans
                e = dist * extrusion_factor
                e_total += e

                println(io, "G1 X$(round(x, digits=2)) Y$(round(y, digits=2)) Z$(round(z, digits=2)) E$(round(e_total, digits=4)) F600")
                x += line_spacing  # Flytta till nästa punkt
                y_prev = y         # Uppdatera föregående Y
            end
        end

        # Stängning
        println(io, "\n; === END ===")
        println(io, "M107 P0             ; Stop concrete pump")
        println(io, "G1 Z10 F3000        ; Raise nozzle")
        println(io, "G28 X0 Y0           ; Home X and Y axes")
        println(io, "M84                 ; Disable motors")
    end
end

function read_parameters_from_file(filename)
    params = Dict()
    open(filename, "r") do file
        for line in eachline(file)
            key, value = split(line, "=")
            params[key] = tryparse(Float64, value) === nothing ? value : tryparse(Float64, value)
        end
    end
    return params
end

params = read_parameters_from_file("parameters_shifted.txt")
generate_shifted_sinusoidal_wall_gcode(
    params["amplitude"],
    params["frequency"],
    params["layer_height"],
    params["num_layers"],
    params["wall_length"],
    params["line_spacing"],
    params["shift_interval"],
    params["extrusion_factor"],
    params["filename"]
)
 
