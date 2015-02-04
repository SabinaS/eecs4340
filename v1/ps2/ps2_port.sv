`timescale 1ns/1ns

module ps2_port (
	ps2_ifc.dut d
);

ps2_converter ps2_converter
			(
				.clk(d.clk),
				.rst(d.rst),
				.ps2_clk(d.ps2_clk),
				.ps2_data(d.ps2_data),
				.ps2_code(d.ps2_code),
				.ps2_code_new(d.ps2_code_new),
				.valid(d.valid)
			);
   
endmodule
