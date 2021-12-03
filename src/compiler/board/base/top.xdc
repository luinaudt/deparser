create_clock -period 2 -name clk -waveform {0.000 1.000} [get_ports clk_in]
create_clock -period 10 -name clk_100 -waveform {0.000 5.000} [get_ports clk_100]
