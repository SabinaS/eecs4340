`timescale 1ns/1ns

module ps2_port #(
	parameter CLK_MHZ = 50,
	parameter BUS_WIDTH = 128,
	parameter SCLK_WAIT = 74
) (
	ps2_ifc.dut d
);

ps2_core #(CLK_MHZ, BUS_WIDTH, SCLK_WAIT, COMMAND_WIDTH,
	  INTERNAL_DAT_WIDTH, COMMAND_BUF_SIZE) ps2_core
			(
				.clk(d.clk),
				.rst(d.rst),
				.ps2_clk(d.ps2_clk),
				.ps2_data(d.ps2_data),
				.ps2_code(d.ps2_code),
				.valid(d.valid),
				.ps2_code_new(d.ps2_code_new)
			);
   
endmodule
