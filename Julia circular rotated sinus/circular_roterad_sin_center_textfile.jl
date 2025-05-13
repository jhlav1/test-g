function generate_circular_rotated_sinusoidal_wall_gcode(amplitude, frequency, layer_height, num_layers, radius, extrusion_factor, rotation_per_layer, filename)
    # Centrera strukturen på byggytan
    center_x, center_y = 111.5, 111.5

    open(filename, "w") do file
        # Skriv G-code header
        write(file, "; Rotated Circular Sinusoidal Wall G-code\n")
        write(file, "G21                 ; Set units to millimeters\n")
        write(file, "G90                 ; Absolute positioning\n")
        write(file, "M104 S200           ; Set extruder temperature to 200°C\n")
        write(file, "M140 S60            ; Set bed temperature to 60°C\n")
        write(file, "M190 S60            ; Wait for bed temperature\n")
        write(file, "M109 S200           ; Wait for extruder temperature\n")
        write(file, "G28                 ; Home all axes\n")
        write(file, "G92 E0              ; Reset extruder position\n")

        # Parameter för sinusvågen
        num_points = 360
        delta_theta = 2 * π / num_points
        prev_x, prev_y, prev_z = center_x, center_y, 0.0
        prev_e = 0.0

        for layer in 1:num_layers
            z = layer * layer_height  # Beräkna Z-höjden för lagret
            write(file, "\n; Layer $layer\n")
            write(file, "G1 Z$z F1200       ; Move to layer height $z mm\n")

            # Rotation för detta lager
            rotation_angle = layer * rotation_per_layer * π / 180  # Konvertera grader till radianer

            for i in 1:num_points
                theta = i * delta_theta  # Vinkel runt cirkeln
                rotated_theta = theta + rotation_angle  # Applicera rotation
                x = center_x + (radius + amplitude * sin(frequency * theta)) * cos(rotated_theta)
                y = center_y + (radius + amplitude * sin(frequency * theta)) * sin(rotated_theta)
                dx = x - prev_x
                dy = y - prev_y
                dz = z - prev_z
                distance = sqrt(dx^2 + dy^2 + dz^2)
                e = prev_e + extrusion_factor * distance
                write(file, "G1 X$x Y$y Z$z E$e\n")
                prev_x, prev_y, prev_z, prev_e = x, y, z, e
            end

            write(file, "G92 E0              ; Reset extruder position\n")
        end

        # Skriv G-code footer
        write(file, "\n; End G-code\n")
        write(file, "M104 S0             ; Turn off extruder\n")
        write(file, "M140 S0             ; Turn off bed\n")
        write(file, "G28 X0 Y0           ; Home X and Y axes\n")
        write(file, "M84                 ; Disable motors\n")
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

params = read_parameters_from_file("param_circular_roterad_sin_center.txt")
generate_circular_rotated_sinusoidal_wall_gcode(amplitude, frequency, layer_height, num_layers, radius, extrusion_factor, rotation_per_layer, filename)
    (
    params["amplitude"],
    params["frequency"],
    params["layer_height"],
    params["num_layers"],
    params["radius"],
    params["extrusion_factor"],
    params["rotation_per_layer"],
    params["filename"]
)
