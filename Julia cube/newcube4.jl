function generate_gcode_single_cube(filename)
    open(filename, "w") do file
        # Cura header for Ultimaker 2+ Connect
        println(file, "M82 ;absolute extrusion mode")
        println(file, "G92 E0")
        println(file, "M190 S60")
        println(file, "M104 S210")
        println(file, "M109 S210")
        println(file, "G0 F9000 X0.00 Y0.00 Z0.00")
        println(file, "G280")
        println(file, "G1 F2700 E-6.5")
        println(file, ";LAYER_COUNT:")
        println(file, ";LAYER:0")
        println(file, "M107")

        # Settings for the cube
        bed_center_x = 121.5 # Center X coordinate for Ultimaker 2+ Connect
        bed_center_y = 110.0 # Center Y coordinate for Ultimaker 2+ Connect
        side_length = 10.0 # Side length of the cube in mm
        layer_height = 0.2 # Height per layer in mm
        num_layers = 20 # Number of layers
        extrusion_multiplier = 0.05 # Extrusion factor
        segment_points = 5 # Points per segment

        # Total extrusion tracker
        total_extrusion = 0.0

        # Generate G-code for each layer
        for layer in 1:num_layers
            z_height = 0.2 + (layer - 1) * layer_height
            println(file, "G1 Z$z_height F300 ; Move to layer $layer")

            # Draw square for the current layer
            for i in 1:segment_points
                t = (i - 1) / (segment_points - 1) # Normalize point distribution
                x1, y1 = bed_center_x - side_length / 2 + t * side_length, bed_center_y - side_length / 2
                x2, y2 = bed_center_x + side_length / 2, bed_center_y - side_length / 2 + t * side_length
                x3, y3 = bed_center_x + side_length / 2 - t * side_length, bed_center_y + side_length / 2
                x4, y4 = bed_center_x - side_length / 2, bed_center_y + side_length / 2 - t * side_length

                extrusion_increment = extrusion_multiplier * side_length / segment_points
                total_extrusion += extrusion_increment
                println(file, "G1 X$x1 Y$y1 E$total_extrusion F1200")
                total_extrusion += extrusion_increment
                println(file, "G1 X$x2 Y$y2 E$total_extrusion F1200")
                total_extrusion += extrusion_increment
                println(file, "G1 X$x3 Y$y3 E$total_extrusion F1200")
                total_extrusion += extrusion_increment
                println(file, "G1 X$x4 Y$y4 E$total_extrusion F1200")
            end
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
generate_gcode_single_cube("single_cube_centered_3.gcode")
