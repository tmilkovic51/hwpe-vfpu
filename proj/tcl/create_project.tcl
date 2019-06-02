create_project simulation .
set_property part xc7z020clg484-1 [current_project]
# set_property board_part em.avnet.com:zed:part0:1.4 [current_project]
add_files -scan_for_includes -fileset sources_1 { .. }
update_compile_order -fileset sources_1
set_property top hwpe_test_tb [get_filesets sim_1]
set_property top hwpe_top_wrap [get_filesets sources_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sources_1
