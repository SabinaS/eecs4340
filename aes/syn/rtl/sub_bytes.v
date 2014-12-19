
// Sub Bytes Module



module sub_bytes(/*AUTOARG*/
   // Outputs
   state_out,
   // Inputs
   state_in
   );
	
 input [0:127] state_in;

 output [0:127] state_out;


 // reg's to hold state_in
 reg [0:7] a0, a1, a2, a3; // first column
 reg [0:7] a4, a5, a6, a7; // second column
 reg [0:7] a8, a9, a10, a11; // third column
 reg [0:7] a12, a13, a14, a15; // fourth column

// wires for state_out

 wire [0:7] b0, b1, b2, b3; // first column
 wire [0:7] b4, b5, b6, b7; // second column
 wire [0:7] b8, b9, b10, b11; // third column
 wire [0:7] b12, b13, b14, b15; // fourth column


always @*
	begin
		a0 = state_in [0:7];
		a1 = state_in [8:15];
		a2 = state_in [16:23];
		a3 = state_in [24:31];

		a4 = state_in [32:39];
		a5 = state_in [40:47];
		a6 = state_in [48:55];
		a7 = state_in [56:63];

		a8 = state_in [64:71];
		a9 = state_in [72:79];
		a10 = state_in [80:87];
		a11 = state_in [88:95];

		a12 = state_in [96:103];
		a13 = state_in [104:111];
		a14 = state_in [112:119];
		a15 = state_in [120:127];
	end



 sbox byte0 (.index(a0), .result(b0));
 sbox byte1 (.index(a1), .result(b1));
 sbox byte2 (.index(a2), .result(b2));
 sbox byte3 (.index(a3), .result(b3));

 sbox byte4 (.index(a4), .result(b4));
 sbox byte5 (.index(a5), .result(b5));
 sbox byte6 (.index(a6), .result(b6));
 sbox byte7 (.index(a7), .result(b7));

 sbox byte8 (.index(a8), .result(b8));
 sbox byte9 (.index(a9), .result(b9));
 sbox byte10 (.index(a10), .result(b10));
 sbox byte11 (.index(a11), .result(b11));

 sbox byte12 (.index(a12), .result(b12));
 sbox byte13 (.index(a13), .result(b13));
 sbox byte14 (.index(a14), .result(b14));
 sbox byte15 (.index(a15), .result(b15));

 	

	assign state_out [0:7] 	 = b0;
 	assign state_out [8:15]  = b1;
	assign state_out [16:23] = b2;
	assign state_out [24:31] = b3;

	assign state_out [32:39] = b4;
	assign state_out [40:47] = b5;
	assign state_out [48:55] = b6;
	assign state_out [56:63] = b7;
 
	assign state_out [64:71] = b8;
	assign state_out [72:79] = b9;
	assign state_out [80:87] = b10;
	assign state_out [88:95] = b11;

	assign state_out [96:103] = b12;
	assign state_out [104:111] = b13;
	assign state_out [112:119] = b14;
	assign state_out [120:127] = b15;

endmodule


///////////////////////////////
///// Test Module /////////////
///////////////////////////////
/*


module subbytes_tester();

reg [0:127] state_in;

reg [0:31] s1, s2, s3, s4; // each row of the state
reg [0:31] s_in1, s_in2, s_in3, s_in4;

wire [0:127] state_out;

wire [0:7] prod;

sub_bytes subbyte (.state_in(state_in), .state_out(state_out));

//mult_by2 by_two (.index(8'hd4), .product(prod));

initial begin

	state_in = 128'hd4bf5d30d4bf5d30d4bf5d30d4bf5d30;
#10
	$display(" ");
	$display("INPUT STATE");
	$display("-------------");
	
	s_in1 = {state_in[0:7], state_in[32:39], state_in[64:71], state_in[96:103]};
	s_in2 = {state_in[8:15], state_in[40:47], state_in[72:79], state_in[104:111]};
	s_in3 = {state_in[16:23], state_in[48:55], state_in[80:87], state_in[112:119]};
	s_in4 = {state_in[24:31], state_in[56:63], state_in[88:95], state_in[120:127]};

	s1 = {state_out[0:7], state_out[32:39], state_out[64:71], state_out[96:103]};
	s2 = {state_out[8:15], state_out[40:47], state_out[72:79], state_out[104:111]};
	s3 = {state_out[16:23], state_out[48:55], state_out[80:87], state_out[112:119]};
	s4 = {state_out[24:31], state_out[56:63], state_out[88:95], state_out[120:127]};

	$display("%h", s_in1);
	$display("%h", s_in2);
	$display("%h", s_in3);
	$display("%h", s_in4);

	$display(" ");
	$display("OUTPUT STATE");
	$display("-------------");

	$display("%h", s1);
	$display("%h", s2);
	$display("%h", s3);
	$display("%h", s4);

	
	//$display("State_in = %h", state_in);
	//$display("State out = %h", state_out);
end


endmodule
*/

