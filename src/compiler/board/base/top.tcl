create_project $projectName $dir -part xcvu3p-ffvc1517-3-e 
set_property target_language VHDL [current_project] 
set_property simulator_language VHDL [current_project] 
add_files {${files}} 
update_compile_order -fileset sources_1 
set_property elab_link_dcps false [current_fileset]
set_property elab_load_timing_constraints false [current_fileset]
create_bd_design eth_10G
source ${boardDir}/eth_10G.tcl
create_root_design ""
close_bd_design eth_10G
