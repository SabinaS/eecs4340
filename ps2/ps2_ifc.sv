`timescale 1ns/1ns

interface ps2_ifc (input bit clk);
	
	logic rst;
	logic clk, rst, ps2_clk, ps2_data; 
	logic [7:0 ]ps2_code;
	logic ps2_code_new, valid
	
	clocking cb @(posedge clk);
		/* ToDo */
		output rst, ps2_clk, ps2_data;
		input ps2_code, ps2_code_new, valid; 
	endclocking 

	modport bench (clocking cb);

	modport dut(
		/* ToDo */
		input clk, rst, ps2_clk, ps2_data;
		output ps2_code, ps2_code_new, valid; 
	);

endinterface 
