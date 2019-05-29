create_project simulation .
add_files -scan_for_includes -fileset sources_1 { .. }
update_compile_order -fileset sources_1
set_property top hwpe_test_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
