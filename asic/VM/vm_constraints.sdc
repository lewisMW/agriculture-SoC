set PCLK "PCLK";

set PCLK_PERIOD 4;

create_clock -name "$PCLK" -period "$PCLK_PERIOD"  [get_ports PCLK]
