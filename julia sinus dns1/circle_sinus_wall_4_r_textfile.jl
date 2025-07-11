function generate_circular_sinusoidal_wall_gcode_with_rotation(
    amplitude,
    frequency,
    layer_height,
    num_layers,
    radius,
    extrusion_factor,
    filename,
    max_rotation_angle
)
    open(filename, "w") do io
        # Start-sekvens
        println(io, "; Circular Sinusoidal Wall with Rotation G-code")
        println(io, "G21                 ; Set units to millimeters")
        println(io, "G90                 ; Absolute positioning")
        println(io, "G28                 ; Home all axes")
        println(io, "G92 E0              ; Reset extruder position")

        # Initialisering för konkretutskrift
        println(io, "M400                ; Wait for all moves to complete")
        println(io, "M106 P0 S255        ; Turn on concrete pump") # Anpassa P0/S-värdet för din pump

        # Generera sinusvågscirklar för varje lager med rotation
        for layer in 1:num_layers
            z = layer * layer_height

            # Beräkna rotationsvinkeln för detta lager (pendlar mellan ±max_rotation_angle)
            rotation_angle = max_rotation_angle * sin(2 * π * layer / num_layers)
            rotation_radians = deg2rad(rotation_angle)

            println(io, "\n; Layer $layer")
            println(io, "G1 Z$(z) F600       ; Move to layer height $(z) mm")
            println(io, "G92 E0              ; Reset extruder position")

            # Parametrar för sinuskurvan
            num_points = 360  # Punkter längs cirkeln (en punkt per grad)
            e_accum = 0.0      # Ackumulerad extrudering
            angle_step = 2 * π / num_points

            # Variabler för föregående punkt
            x_prev, y_prev = nothing, nothing

            # Generera cirkulära sinusvågor med rotation
            for i in 0:num_points
                angle = i * angle_step
                rotated_angle = angle + rotation_radians  # Lägg till rotation
                r = radius + amplitude * sin(frequency * angle)  # Radie med sinusvåg
                x = 111.5 + r * cos(rotated_angle)  # X-position (centrerad i Ultimaker)
                y = 111.5 + r * sin(rotated_angle)  # Y-position (centrerad i Ultimaker)

                # Beräkna extrusion baserat på distans
                if i > 0 && x_prev != nothing && y_prev != nothing
                    dx = x - x_prev
                    dy = y - y_prev
                    dist = sqrt(dx^2 + dy^2)
                    e_accum += dist * extrusion_factor
                end

                # Generera G-kod för denna punkt
                println(io, "G1 X$(round(x, digits=2)) Y$(round(y, digits=2)) Z$(round(z, digits=2)) E$(round(e_accum, digits=4)) F600")
                x_prev, y_prev = x, y  # Uppdatera föregående punkt
            end
        end

        # Avslutande sekvens
        println(io, "\n; === END ===")
        println(io, "G1 Z10 F3000        ; Raise nozzle")
        println(io, "M107 P0             ; Turn off concrete pump")
        println(io, "M104 S0             ; Turn off extruder (if applicable)")
        println(io, "G28 X0 Y0           ; Home X and Y")
        println(io, "M84                 ; Disable motors")
    end
end

params = read_parameters_from_file("parameters_sinusdns.txt")
generate_circular_sinusoidal_wall_gcode_with_rotation(
    params["amplitude"],
    params["frequency"],
    params["layer_height"],
    params["num_layers"],
    params["radius"],
    params["extrusion_factor"],
    params["filename"],
    params["max_rotation_angle"]
)

 