`timescale 1ns/1ns

/* module for performing 4096 bit multiplication */
module modexp(
	clk, rst, a, b, o
);
	input logic clk, rst;
	input logic [4095:0] a, b; //would actually want to chunk this
	output logic [4095:0] o;

	always_ff @(posedge clk) begin


	end

endmodule
