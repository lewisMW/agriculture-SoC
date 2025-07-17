set REF_CLK "REF_CLK";
set PLL_CLK1 "PLL_CLK1"
set PLL_CLK2 "PLL_CLK2"

set REF_CLK_PERIOD 4;
set PLL_CLK1_PERIOD 1;
set PLL_CLK2_PERIOD 1;

create_clock -name "$REF_CLK" -period "$REF_CLK_PERIOD"  [get_ports ref_clk]

create_generated_clock -name "$PLL_CLK1" -source [get_ports ref_clk] -multiply_by 4 [get_pins u_snps_PLL/clkoutp]
create_generated_clock -name "$PLL_CLK2" -source [get_ports ref_clk] -multiply_by 4 [get_pins u_snps_PLL/clkoutr]
