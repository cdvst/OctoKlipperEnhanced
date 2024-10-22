# Bedmesh in der "print area" (Druckbereich)

Alle, die ein altes Skript benutzen bitte alle unten aufgeführten Punkte für den Startcode und den Slicer beachten!
  
Um ein bedmesh im Druckbereich durchzuführen, muss einmal die "bedmesh_printarea.cfg" erfolgreich eingebunden sein und folgenden Parameter definiert werden:  
  
`variable_parameter_AREA_START_X & Y` = Default Startparameter X und Y  
`variable_parameter_AREA_END_X & Y` = Default Endparameter X und Y  
`variable_mesh_min_x & y` = Minimalwert X und Y  
`variable_mesh_max_x & y` = Maximalwert X und Y  
`variable_mesh_area_offset` = Offset der auf die Min und Max Werte gerechnet werden  
`variable_probe_samples` = Wie oft soll geprobed werden  
`variable_min_probe_count` = Mesh Größe  
`variable_probe_count_scale_factor` = Skaliert die Probecounts mit der Größe  
`variable_enable_reference_index` = Messpunkte werden auf einen Bezugspunkt bezogen  
  
```
variable_parameter_AREA_START : 0,0
variable_parameter_AREA_END : 0,0
; the clearance between print area and probe area 
variable_mesh_area_offset : 5.0
; number of sample per probe point
variable_probe_samples : 2
; minimum probe count
variable_min_probe_count : 3
; scale up the probe count, should be 1.0 ~ < variable_max_probe_count/variable_min_probe_count
variable_probe_count_scale_factor : 1.0
; enable preference index
variable_enable_reference_index : True
```  
  
---     
**<u>Folgender Startcode ist für den Superslicer zu benutzen:</u>**  
  
`START_PRINT BED={first_layer_bed_temperature} EXTRUDER={first_layer_temperature} AREA_START={first_layer_print_min[0]},{first_layer_print_min[1]} AREA_END={first_layer_print_max[0]},{first_layer_print_max[1]}`
   
_Falls Ihr andere Name für die Variablen von Extruder und Bed Temperatur habt, müssen diese natürlich auch angepasst werden_  
  
 --- 
 **<u>Folgender Code müsst ihr in euer Startcode einfügen:</u>**  
 
```
[gcode_macro START_PRINT]
variable_parameter_AREA_START : 0,0
variable_parameter_AREA_END : 0,0
gcode:
 #Euer Startcode 
 BED_MESH_PRINT_AREA AREA_START={params.AREA_START|default("0,0")} AREA_END={params.AREA_END|default("0,0")}
```  
   
 ---
<u>**Wichtiger Hinweis:** </u>  
   
  
Das Script zum PrintArea mesh stammt nicht von uns, sondern wurde von der folgenden Quelle bezogen. Daher bitten wir euch bei Problem, erstmal das Script zu Updaten.
Ebenfalls bedanken wir uns bei dem Ersteller und verweisen hiermit auf Ihn. Das Script wird auf eigene Gefahr benutzt und sollte vor Verwendung geprüft werden.  
  
https://gist.github.com/ChipCE/95fdbd3c2f3a064397f9610f915f7d02

  
  
CRYDTEAM
