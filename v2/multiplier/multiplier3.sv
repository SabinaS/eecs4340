`timescale 1ns/1ns

/* module for performing 4096 bit multiplication */
module multiplier3(
	clk, rst, a, b, o
);
	input logic clk, rst;
	input logic [4095:0] a, b; 
	output logic [4095:0] o;

	logic [8191:0] intermediate; 
	logic [8191:0] shifter; 
	logic [11:0] stage; 

	assign o = intermediate[4095:0];

	always_ff @(posedge clk) begin
		if(rst) begin
			intermediate <= 'b0;
			stage <= 'b0;
			shifter <= 'b0;
		end else begin
			if(stage == 12'b000000000000) begin
				shifter <= a<<1;
				stage <= stage + 1'b1;
				if(b[0] == 1) begin
					intermediate <= intermediate + a;
				end
			end else if(stage==12'b111111111111) begin
				stage <= 'b0;
				shifter <= 'b0;
			end else begin
				stage <= stage+1'b1;
				shifter <= shifter << 1;
				if(b[stage] == 1) begin
					intermediate <= intermediate + shifter;
				end
			end
		end
	end

endmodule
