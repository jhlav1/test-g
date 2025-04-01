; 3mm Cube G-code
; Layer height: 0.2mm
; Nozzle diameter: 0.4mm
; Material: PLA
; Temperature: 200C

; Initial setup
G21 ; Set units to millimeters
G90 ; Use absolute coordinates
M82 ; Use absolute extrusion
M104 S200 ; Set extruder temp
M140 S60 ; Set bed temp
M190 S60 ; Wait for bed temp
M109 S200 ; Wait for extruder temp
G28 ; Home all axes
G1 Z5 F5000 ; Lift nozzle

; Start printing
G1 X0 Y0 F3000 ; Move to starting position
G1 Z0.2 F3000 ; Move to first layer height

; First layer - solid base
G1 X3 Y0 E1.5 F1500 ; Draw first line
G1 X3 Y3 E3 F1500 ; Draw second line
G1 X0 Y3 E4.5 F1500 ; Draw third line
G1 X0 Y0 E6 F1500 ; Draw fourth line
G1 X3 Y0 E7.5 F1500 ; Close the square

; Second layer
G1 Z0.4 F3000 ; Move to second layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E9 F1500 ; Draw first line
G1 X3 Y3 E10.5 F1500 ; Draw second line
G1 X0 Y3 E12 F1500 ; Draw third line
G1 X0 Y0 E13.5 F1500 ; Draw fourth line
G1 X3 Y0 E15 F1500 ; Close the square

; Third layer
G1 Z0.6 F3000 ; Move to third layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E16.5 F1500 ; Draw first line
G1 X3 Y3 E18 F1500 ; Draw second line
G1 X0 Y3 E19.5 F1500 ; Draw third line
G1 X0 Y0 E21 F1500 ; Draw fourth line
G1 X3 Y0 E22.5 F1500 ; Close the square

; Fourth layer
G1 Z0.8 F3000 ; Move to fourth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E24 F1500 ; Draw first line
G1 X3 Y3 E25.5 F1500 ; Draw second line
G1 X0 Y3 E27 F1500 ; Draw third line
G1 X0 Y0 E28.5 F1500 ; Draw fourth line
G1 X3 Y0 E30 F1500 ; Close the square

; Fifth layer
G1 Z1.0 F3000 ; Move to fifth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E31.5 F1500 ; Draw first line
G1 X3 Y3 E33 F1500 ; Draw second line
G1 X0 Y3 E34.5 F1500 ; Draw third line
G1 X0 Y0 E36 F1500 ; Draw fourth line
G1 X3 Y0 E37.5 F1500 ; Close the square

; Sixth layer
G1 Z1.2 F3000 ; Move to sixth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E39 F1500 ; Draw first line
G1 X3 Y3 E40.5 F1500 ; Draw second line
G1 X0 Y3 E42 F1500 ; Draw third line
G1 X0 Y0 E43.5 F1500 ; Draw fourth line
G1 X3 Y0 E45 F1500 ; Close the square

; Seventh layer
G1 Z1.4 F3000 ; Move to seventh layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E46.5 F1500 ; Draw first line
G1 X3 Y3 E48 F1500 ; Draw second line
G1 X0 Y3 E49.5 F1500 ; Draw third line
G1 X0 Y0 E51 F1500 ; Draw fourth line
G1 X3 Y0 E52.5 F1500 ; Close the square

; Eighth layer
G1 Z1.6 F3000 ; Move to eighth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E54 F1500 ; Draw first line
G1 X3 Y3 E55.5 F1500 ; Draw second line
G1 X0 Y3 E57 F1500 ; Draw third line
G1 X0 Y0 E58.5 F1500 ; Draw fourth line
G1 X3 Y0 E60 F1500 ; Close the square

; Ninth layer
G1 Z1.8 F3000 ; Move to ninth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E61.5 F1500 ; Draw first line
G1 X3 Y3 E63 F1500 ; Draw second line
G1 X0 Y3 E64.5 F1500 ; Draw third line
G1 X0 Y0 E66 F1500 ; Draw fourth line
G1 X3 Y0 E67.5 F1500 ; Close the square

; Tenth layer
G1 Z2.0 F3000 ; Move to tenth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E69 F1500 ; Draw first line
G1 X3 Y3 E70.5 F1500 ; Draw second line
G1 X0 Y3 E72 F1500 ; Draw third line
G1 X0 Y0 E73.5 F1500 ; Draw fourth line
G1 X3 Y0 E75 F1500 ; Close the square

; Eleventh layer
G1 Z2.2 F3000 ; Move to eleventh layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E76.5 F1500 ; Draw first line
G1 X3 Y3 E78 F1500 ; Draw second line
G1 X0 Y3 E79.5 F1500 ; Draw third line
G1 X0 Y0 E81 F1500 ; Draw fourth line
G1 X3 Y0 E82.5 F1500 ; Close the square

; Twelfth layer
G1 Z2.4 F3000 ; Move to twelfth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E84 F1500 ; Draw first line
G1 X3 Y3 E85.5 F1500 ; Draw second line
G1 X0 Y3 E87 F1500 ; Draw third line
G1 X0 Y0 E88.5 F1500 ; Draw fourth line
G1 X3 Y0 E90 F1500 ; Close the square

; Thirteenth layer
G1 Z2.6 F3000 ; Move to thirteenth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E91.5 F1500 ; Draw first line
G1 X3 Y3 E93 F1500 ; Draw second line
G1 X0 Y3 E94.5 F1500 ; Draw third line
G1 X0 Y0 E96 F1500 ; Draw fourth line
G1 X3 Y0 E97.5 F1500 ; Close the square

; Fourteenth layer
G1 Z2.8 F3000 ; Move to fourteenth layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E99 F1500 ; Draw first line
G1 X3 Y3 E100.5 F1500 ; Draw second line
G1 X0 Y3 E102 F1500 ; Draw third line
G1 X0 Y0 E103.5 F1500 ; Draw fourth line
G1 X3 Y0 E105 F1500 ; Close the square

; Fifteenth layer (top layer)
G1 Z3.0 F3000 ; Move to top layer
G1 X0 Y0 F3000 ; Move to starting position
G1 X3 Y0 E106.5 F1500 ; Draw first line
G1 X3 Y3 E108 F1500 ; Draw second line
G1 X0 Y3 E109.5 F1500 ; Draw third line
G1 X0 Y0 E111 F1500 ; Draw fourth line
G1 X3 Y0 E112.5 F1500 ; Close the square

; End of print
G1 Z10 F3000 ; Lift nozzle
M104 S0 ; Turn off heatbed
M140 S0 ; Turn off temperature
M84 ; Disable motors
