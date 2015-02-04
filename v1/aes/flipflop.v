module flipflop(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   din, clk, en, rst
   );
	parameter WIDTH = 1;
	
	input [WIDTH-1:0] din;
	input clk;
	input en;
	input rst;

	output [WIDTH-1:0] dout;
	
	reg [WIDTH-1:0] dout;
	
	always @( posedge clk )
	begin
		if ( rst )
			dout <= 0;
		else if ( en )
			dout <= din;
	end
	
endmodule
// cmh
