/**Columbia University CASTL**/
/**Spring 2011**/
/**Yipeng Huang, Rachid Jeitani**/
/**AES Research*/

/*
A pseudo random number generator
Takes a 128-bit entropy seed, and outputs a 128-bit random number
This random number will be XORed with the AES input
The a_const and c_const used for this linear congruential generator are taken from Donald Knuth
This algorithm is selected for its simplicity, its good distribution of generated random numbers
The algorithm generates 128-bit random numbers by generating four 32-bit random keys.
TODO: we should evaluate quality of the random key
TODO: metrics include uniform distribution, repetition
*/
module prng_single (
	/*AUTOARG*/
   // Outputs
   key,
   // Inputs
   clk, enable, reset, seed
   );

//Basic inputs
input clk, enable, reset;

//The 128-bit seed
input [127:0] seed;

//The 128-bit key
output [127:0] key;

//Constants needed for random number generation
wire [31:0] a_const;
wire [31:0] c_const;
assign a_const = 32'd1103515245;
assign c_const = 32'd12345;

//Wires that will carry the front and back halfs of the current key
reg [31:0] key_curr_0;
reg [31:0] key_curr_1;
reg [31:0] key_curr_2;
reg [31:0] key_curr_3;

//Wires that will carry the front and back halfs of the previous key
wire [31:0] key_prev_0;
wire [31:0] key_prev_1;
wire [31:0] key_prev_2;
wire [31:0] key_prev_3;

//Memory elements for key
prng_register key_reg_0 (.clk(clk), .reset(reset), .enable(enable), .set(key_curr_0), .q(key_prev_0));
prng_register key_reg_1 (.clk(clk), .reset(reset), .enable(enable), .set(key_curr_1), .q(key_prev_1));
prng_register key_reg_2 (.clk(clk), .reset(reset), .enable(enable), .set(key_curr_2), .q(key_prev_2));
prng_register key_reg_3 (.clk(clk), .reset(reset), .enable(enable), .set(key_curr_3), .q(key_prev_3));

//Carry out the multiplication in a pipelined multiplier
wire [63:0] product_temp_0;
wire [63:0] product_temp_1;
wire [63:0] product_temp_2;
wire [63:0] product_temp_3;
prng_pip_mult mult_0 (.product(product_temp_0), .clk(clk), .a(key_prev_0), .b(a_const));
prng_pip_mult mult_1 (.product(product_temp_1), .clk(clk), .a(key_prev_1), .b(a_const));
prng_pip_mult mult_2 (.product(product_temp_2), .clk(clk), .a(key_prev_2), .b(a_const));
prng_pip_mult mult_3 (.product(product_temp_3), .clk(clk), .a(key_prev_3), .b(a_const));

//The function that carries out pseudo-random number generation each round
wire [63:0] key_temp_0;
wire [63:0] key_temp_1;
wire [63:0] key_temp_2;
wire [63:0] key_temp_3;
assign key_temp_0 = product_temp_0 + c_const;
assign key_temp_1 = product_temp_1 + c_const;
assign key_temp_2 = product_temp_2 + c_const;
assign key_temp_3 = product_temp_3 + c_const;

//Depending on if it's the first round with the reset signal, use seed or use new key
always @(posedge clk) begin
	if(reset) begin
		key_curr_0 <= seed [127:96];
		key_curr_1 <= seed [95:64];
		key_curr_2 <= seed [63:32];
		key_curr_3 <= seed [31:0];
	end
	else begin
		key_curr_0 <= key_temp_0 [31:0];
		key_curr_1 <= key_temp_1 [31:0];
		key_curr_2 <= key_temp_2 [31:0];
		key_curr_3 <= key_temp_3 [31:0];
	end
end

assign key = {key_curr_0, key_curr_1, key_curr_2, key_curr_3};

endmodule