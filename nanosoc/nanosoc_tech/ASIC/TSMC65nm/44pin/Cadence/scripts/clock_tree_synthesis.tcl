############################################
# Script : Clock Tree Implementation
# Date : 24th May 2023 
# Author : Srimanth Tenneti 
# Description : Implements the Clock Tree
############################################ 

### Buffer Cells 
set_db cts_buffer_cells {*BUFH*}
### Inverter Cells 
set_db cts_inverter_cells {*INV*} 

### Clock Tree Sepc 
create_clock_tree_spec -out_file design_clk.spec 

### Creating a Clock Tree 
ccopt_design 

### Optimizing the design 
opt_design -post_cts 
opt_design -post_cts -hold 


