compile_vcs:
	vcs -ad -ams soclabs_adc_tb.vams soclabs_adc.vams -debug_access+all -kdb > compile.log

sim_vcs:
	./simv -gui

compile_mti:
	vlog -vams soclabs_adc_tb.vams 