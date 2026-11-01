create_clock -name clk -period 40 [get_ports {clk_l clk_b clk_r}]
set_input_delay 2 -clock clk [remove_from_collection [all_inputs] [get_ports {clk_l clk_b clk_r}]]
set_output_delay 2 -clock clk [all_outputs]
