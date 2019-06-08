create_project:
	vivado -mode batch -source tcl/create_project.tcl -nojournal -nolog

clean:
	rm -rf .Xil hwpe-vfpu.cache hwpe-vfpu.hw hwpe-vfpu.ip_user_files hwpe-vfpu.sim hwpe-vfpu.xpr hwpe-vfpu.runs vivado.*

gui:
	vivado hwpe-vfpu.xpr -nolog -nojournal
