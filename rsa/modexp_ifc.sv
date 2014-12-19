`timescale 1ns/1ns

interface modexp_ifc (input bit clk);
	logic             rst, stall;

	logic [4095:0]    exp, mod;
	logic [127:0]     data_i;
	logic [127:0]     data_o;

	logic             start, done, valid;

	clocking cb @(posedge clk);
		output rst, stall;
		output exp, mod;
		output data_i;
		output start;

		input data_o;
		input done, valid;
	endclocking

	modport bench (clocking cb);

	modport dut (
		input clk, rst, stall,
		input exp, mod,
		input data_i,
		input start,

		output data_o,
		output done, valid
	);

endinterface
