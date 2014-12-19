module pipereg( din, dout, clk, rst);
	//parameter WIDTH = 128;

	input clk;
	input rst;

	input [0:127] din;
	
	output [0:127] dout;


	flipflop arr [0:127]
	(
		.rst(rst),
		.clk(clk),
		.din(din),
		.dout(dout),
		.en(1'b1)
			
	);
	
endmodule


