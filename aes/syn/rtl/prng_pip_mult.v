/**Columbia University CASTL**/
/**Spring 2011**/
/**Yipeng Huang, Rachid Jeitani**/
/**AES Research*/

/*
A pipelined multiplier
*/
module prng_pip_mult (
	/*AUTOARG*/
	// Outputs
	product,
	// Inputs
	clk, a, b
	);

parameter WIDTH = 32; //width of the multiplier and multiplicand
parameter DEPTH = 5; //pipeline depth in stages, at least log2 of size

input [WIDTH-1 : 0] a;
input [WIDTH-1 : 0] b;
input clk;

output [2*WIDTH-1 : 0] product;

reg [WIDTH-1 : 0] a_int, b_int;
reg [2*WIDTH-1 : 0] product_int [DEPTH-1 : 0];

integer i;

assign product = product_int [DEPTH-1];

always @ (posedge clk)
begin

	// registering input of the multiplier
	a_int <= a;
	b_int <= b;
	
	// 'level' levels of registers to be inferred at the output
	// of the multiplier
	product_int[0] <= a_int * b_int;
	for( i=1 ; i<DEPTH ; i=i+1)
		product_int [i] <= product_int [i-1];

end

endmodule