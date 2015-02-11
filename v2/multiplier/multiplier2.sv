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


genvar i;
generate
for(i=0;i<4096;i=i+1) begin
assign intermediate[4095+i:i] = (stage == i) ? ((a[i] == 1 ) ?  intermediate[4095+i:0+i] + a : intermediate[4095+i:i]) : intermediate[4095+i:i]; 
end
endgenerate 


	always_ff @(posedge clk) begin
		if(rst) begin
			stage <= 'b0;
		end else begin
                 	if(stage == 12'b111111111111) begin
				o <= intermediate[4095:0];
				stage <= 'b0;
			end
		end
	end

endmodule
