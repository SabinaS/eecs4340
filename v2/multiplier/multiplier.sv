`timescale 1ns/1ns

/* module for performing 4096 bit multiplication */
module multiplier(
	clk, rst, a, b, o
);
	input logic clk, rst;
	input logic [4095:0] a, b; 
	output logic [4095:0] o;

	always_ff @(posedge clk) begin
		if(rst) begin
			o <= 'b0;
		end else begin
			o <= a*b;
		end
	end

endmodule
