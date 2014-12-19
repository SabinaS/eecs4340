`timescale 1ns/1ns

module ps2_top;

	bit clk = 1;
	always #10 clk = ~clk;

	initial $vcdplusion;

	ps2_ifc IFC(clk);
	ps2_port dur (IFC.dut);
	ps2_tb bench (IFC.bench);

endmodule
