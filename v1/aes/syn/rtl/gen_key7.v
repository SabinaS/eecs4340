// gen_key :: Round 7
// rcon = 32'40000000


module gen_key7(/*AUTOARG*/
   // Outputs
   next_key,
   // Inputs
   prev_key

   );
	
 parameter rcon = 32'h40000000; // must be different for each round!

 input [0:127] prev_key;

 output [0:127] next_key;

 reg [0:31] w0, w1, w2, w3; // to store input (previous) round key as 4-byte chunks

 wire [0:31] y0, y1, y2, y3; // the components of the output (next) round key

 wire [0:31] w_after_rot;
 wire [0:31] w_after_sub;
 wire [0:31] w_after_rcon;


always @*
	begin

	w0 = prev_key [0:31];
	w1 = prev_key [32:63];
	w2 = prev_key [64:95];
	w3 = prev_key [96:127];

	end

 rotword rotate(.in_word(w3), .out_word(w_after_rot)); // rotate w3
	
 // perform substitution on each byte

 sbox sub0(.index(w_after_rot[0:7]), .result(w_after_sub[0:7])); 
 sbox sub1(.index(w_after_rot[8:15]), .result(w_after_sub[8:15])); 
 sbox sub2(.index(w_after_rot[16:23]), .result(w_after_sub[16:23])); 
 sbox sub3(.index(w_after_rot[24:31]), .result(w_after_sub[24:31])); 


 assign w_after_rcon = (w_after_sub ^ rcon);
	
 assign y0 = (w0 ^ w_after_rcon); // produce 1st byte of the next key
 assign y1 = (w1 ^ y0); // produce 2nd byte of the next key
 assign y2 = (w2 ^ y1); // produce 3rd byte of the next key
 assign y3 = (w3 ^ y2); // produce 4th byte of the next key

 assign next_key = {y0, y1, y2, y3}; // concatenate bytes


	
endmodule



