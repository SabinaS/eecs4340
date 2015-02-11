`timescale 1ns/1ns

/* module for performing 4096 bit multiplication */
module multiplier2(
	clk, rst, a, b, o
);
	input logic clk, rst;
	input logic [4095:0] a, b; 
	output logic [4095:0] o;

	logic [8191:0] intermediate; 
	logic [11:0] stage; 

	assign o = intermediate[4095:0];


	always_ff @(posedge clk) begin
		if(rst) begin
			intermediate <= 'b0;
			stage <= 'b0;
		end else begin
			if(stage == 12'b0) begin
				if(a[0]==1) begin
					intermediate[4095:0] <= intermediate[4095:0] + a; 
				end

generate
genvar i;
for(i=1;i<4096;i++) begin
			end else if(stage == i) begin
				if(a[i]==1) begin
					intermediate[4095+i:0+i] <= intermediate[4095+i:0+i] + a; 
				end

endgenerate
			end
		end
	end

endmodule
