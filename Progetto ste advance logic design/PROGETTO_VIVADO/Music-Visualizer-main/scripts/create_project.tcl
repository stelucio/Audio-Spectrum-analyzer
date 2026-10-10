# ====================================================================
# Music-Visualizer - Progetto Vivado per Nexys 4 DDR (Artix-7 XC7A100T-1CSG324)
# Vivado 2025.1
# ====================================================================

set proj_name "Music-Visualizer"
set proj_dir  [file normalize "./vivado/$proj_name"]
set part_name "xc7a100t-1csg324"

# --------------------------------------------------------------------
# Utility
# --------------------------------------------------------------------
proc ensure_dir {d} {
    if {![file isdirectory $d]} { file mkdir $d }
}
proc write_if_new {path content} {
    if {![file exists $path]} {
        set f [open $path "w"]
        puts $f $content
        close $f
        puts "Creato: $path"
    }
}

# --------------------------------------------------------------------
# Chiudi eventuali progetti aperti e sgancia lock
# --------------------------------------------------------------------
catch {close_project -quiet}
set tmpdir [file normalize "./vivado/__tmp_empty"]
file mkdir $tmpdir
create_project __tmp__ $tmpdir -part $part_name -force
close_project
file delete -force $tmpdir

# --------------------------------------------------------------------
# Cancella progetto precedente
# --------------------------------------------------------------------
if {[file isdirectory $proj_dir]} {
    puts "Rimuovo progetto precedente in $proj_dir"
    file delete -force $proj_dir
}

# --------------------------------------------------------------------
# Crea cartelle repository
# --------------------------------------------------------------------
foreach d {
    ./cpu/src ./cpu/testbench
    ./audio/src ./audio/testbench
    ./matrix/src ./matrix/testbench
    ./top/src ./top/constraints
    ./sim ./scripts
} { ensure_dir $d }

# --------------------------------------------------------------------
# Crea progetto
# --------------------------------------------------------------------
create_project $proj_name $proj_dir -part $part_name -force

# --------------------------------------------------------------------
# Imposta VHDL-2008
# --------------------------------------------------------------------
set_param project.enableVHDL2008 1
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]
set_property -name {xvhdl.enableV2008} -value {1} -objects [get_filesets sim_1]

# --------------------------------------------------------------------
# Aggiungi sorgenti e vincoli
# --------------------------------------------------------------------
add_files -fileset sources_1 [glob -nocomplain ./cpu/src/*.vhd]
add_files -fileset sources_1 [glob -nocomplain ./audio/src/*.vhd]
add_files -fileset sources_1 [glob -nocomplain ./matrix/src/*.vhd]
add_files -fileset sources_1 [glob -nocomplain ./top/src/*.vhd]
set_property top top [current_fileset]

add_files -fileset constrs_1 ./top/constraints/top.xdc

# Testbench (aggiunti solo se presenti)
foreach tb_dir {./cpu/testbench ./audio/testbench ./matrix/testbench ./sim} {
    set tb_files [glob -nocomplain $tb_dir/*.vhd]
    if {[llength $tb_files] > 0} {
        add_files -fileset sim_1 $tb_files
    }
}

# --------------------------------------------------------------------
# Aggiorna e salva progetto
# --------------------------------------------------------------------
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Non serve save_project, ma se vuoi avere uno script backup:
write_project_tcl -force $proj_dir/${proj_name}_backup.tcl

close_project

puts "Progetto creato in $proj_dir con VHDL-2008 attivo."
