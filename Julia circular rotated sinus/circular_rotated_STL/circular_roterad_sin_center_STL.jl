using FileIO

function generate_circular_rotated_sinusoidal_wall_stl(amplitude, frequency, layer_height, num_layers, radius, rotation_per_layer, filename)
    # Centrera strukturen på byggytan
    center_x, center_y = 0.0, 0.0

    # STL-header
    open(filename, "w") do file
        write(file, "solid sinusoidal_wall\n")

        # Parameter för sinusvågen
        num_points = 360
        delta_theta = 2 * π / num_points

        for layer in 1:num_layers
            z = (layer - 1) * layer_height  # Beräkna Z-höjden för lagret
            next_z = layer * layer_height  # Höjden på nästa lager

            # Rotation för detta lager och nästa lager
            rotation_angle = (layer - 1) * rotation_per_layer * π / 180
            next_rotation_angle = layer * rotation_per_layer * π / 180

            for i in 1:num_points
                theta = i * delta_theta  # Vinkel runt cirkeln
                next_theta = ((i % num_points) + 1) * delta_theta  # Nästa punkt runt cirkeln

                # Beräkna punkter för detta lager
                x1 = center_x + (radius + amplitude * sin(frequency * theta)) * cos(theta + rotation_angle)
                y1 = center_y + (radius + amplitude * sin(frequency * theta)) * sin(theta + rotation_angle)

                x2 = center_x + (radius + amplitude * sin(frequency * next_theta)) * cos(next_theta + rotation_angle)
                y2 = center_y + (radius + amplitude * sin(frequency * next_theta)) * sin(next_theta + rotation_angle)

                # Beräkna punkter för nästa lager
                x3 = center_x + (radius + amplitude * sin(frequency * theta)) * cos(theta + next_rotation_angle)
                y3 = center_y + (radius + amplitude * sin(frequency * theta)) * sin(theta + next_rotation_angle)

                x4 = center_x + (radius + amplitude * sin(frequency * next_theta)) * cos(next_theta + next_rotation_angle)
                y4 = center_y + (radius + amplitude * sin(frequency * next_theta)) * sin(next_theta + next_rotation_angle)

                # Skriv trianglar till STL
                # Första triangeln
                write(file, "  facet normal 0 0 0\n")
                write(file, "    outer loop\n")
                write(file, "      vertex $x1 $y1 $z\n")
                write(file, "      vertex $x2 $y2 $z\n")
                write(file, "      vertex $x3 $y3 $next_z\n")
                write(file, "    endloop\n")
                write(file, "  endfacet\n")

                # Andra triangeln
                write(file, "  facet normal 0 0 0\n")
                write(file, "    outer loop\n")
                write(file, "      vertex $x2 $y2 $z\n")
                write(file, "      vertex $x4 $y4 $next_z\n")
                write(file, "      vertex $x3 $y3 $next_z\n")
                write(file, "    endloop\n")
                write(file, "  endfacet\n")
            end
        end

        # STL-footer
        write(file, "endsolid sinusoidal_wall\n")
    end
end

generate_circular_rotated_sinusoidal_wall_stl(
    2.0,
    3.0,
    0.2,
    360,
    20.0,
    0.8,  # 360° rotation över 360 lager
    "rotated_sinusoidal_wall.stl"
)
