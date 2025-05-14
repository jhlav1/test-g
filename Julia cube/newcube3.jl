function generate_gcode(filename)
    open(filename, "w") do file
        # Cura header for Ultimaker 2+ Connect
        println(file, "M82 ;absolute extrusion mode")
        println(file, "G92 E0")
        println(file, "M190 S60")
        println(file, "M104 S210")
        println(file, "M109 S210")
        println(file, "G28 ; Home all axes")
        println(file, "G1 Z0.2 F300 ; Initial layer height")

        # Move to the center of the bed
        bed_center_x = 111.5 # Center X coordinate for Ultimaker 2+ Connect
        bed_center_y = 111.5 # Center Y coordinate for Ultimaker 2+ Connect

        # Settings for the square
        side_length = 20.0 # Side length of the square in mm
        layer_height = 0.2 # Height per layer in mm
        num_layers = 15 # Number of layers
        base_extrusion = 1.0 # Base extrusion value
        extrusion_variation = 0.01 # Small variation to add to extrusion

        for layer in 1:num_layers
            z_height = layer * layer_height
            println(file, "G1 Z$z_height F300 ; Move to layer $layer")

            # Draw square with varying extrusion
            corners = [
                (bed_center_x - side_length / 2, bed_center_y - side_length / 2),  # Bottom-left
                (bed_center_x + side_length / 2, bed_center_y - side_length / 2),  # Bottom-right
                (bed_center_x + side_length / 2, bed_center_y + side_length / 2),  # Top-right
                (bed_center_x - side_length / 2, bed_center_y + side_length / 2),  # Top-left
            ]

            for i in 1:4
                x1, y1 = corners[i]
                x2, y2 = corners[mod1(i + 1, 4)]  # Next corner (loop back to first corner at the end)
                extrusion = base_extrusion + (i - 1) * extrusion_variation
                println(file, "G1 X$x1 Y$y1 F1200 ; Move to corner $i")
                println(file, "G1 X$x2 Y$y2 E$extrusion F1200 ; Extrude to next corner with variation")
            end

            println(file, "G92 E0 ; Reset extrusion")
        end

        # Footer
        println(file, "G1 Z10 F300 ; Move up after print")
        println(file, "G28 X0 Y0 ; Home X and Y axes")
        println(file, "M104 S0 ; Turn off hotend")
        println(file, "M140 S0 ; Turn off heated bed")
        println(file, "M84 ; Disable motors")
    end
    println("G-code file saved as $filename")
end

# Generate G-code file
generate_gcode("cube_variable_extrusion_2.gcode")
