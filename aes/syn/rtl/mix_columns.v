module mix_columns(/*AUTOARG*/
   // Outputs
   state_out,
   // Inputs
   state_in
   );
	
 input [0:127] state_in;

 output [0:127] state_out;

 reg [0:31] col1, col2, col3, col4; // input columns
 wire [0:31] m1, m2, m3, m4; // mixed columns

// MATRIX //

// 02 03 01 01 //
// 01 02 03 01 //
// 01 01 02 03 //
// 03 01 01 02 //

 always @*
	begin
		col1 = state_in [0:31];
		col2 = state_in [32:63];
		col3 = state_in [64:95];
		col4 = state_in [96:127];
	end


		doColumns column1 (.col_in(col1), .col_out(m1));
		doColumns column2 (.col_in(col2), .col_out(m2));
		doColumns column3 (.col_in(col3), .col_out(m3));
		doColumns column4 (.col_in(col4), .col_out(m4));

	assign state_out [0:31] = m1;
	assign state_out [32:63] = m2;
	assign state_out [64:95] = m3;
	assign state_out [96:127] = m4;

endmodule


module doColumns (/*AUTOARG*/
   // Outputs
   col_out,
   // Inputs
   col_in
   ); // performs operation

input [0:31] col_in;

output [0:31] col_out;


reg [0:7] a0, a1, a2, a3; // bytes before transform
reg [0:7] r0, r1, r2, r3; // bytes after transform

// regs for values returned from lookup tables
// r(row_number)_(multipliedby), e.g. r0_3 => row 0, multiplied by 3

wire [0:7] r0_2, r0_3;
wire [0:7] r1_2, r1_3;
wire [0:7] r2_2, r2_3;
wire [0:7] r3_2, r3_3;

//////////////////////////////
// Equations for reference ///
//////////////////////////////


   // r0 = 2*a0 + 3*a1 + 1*a2 + 1*a3
   // r1 = 1*a0 + 2*a1 + 3*a2 + 1*a3
   // r2 = 1*a0 + 1*a1 + 2*a2 + 3*a3
   // r3 = 3*a0 + 1*a1 + 1*a2 + 2*a3  


	mult_by2 row0_2 (.index(a0), .product(r0_2));  
	mult_by3 row0_3 (.index(a0), .product(r0_3));

	mult_by2 row1_2 (.index(a1), .product(r1_2));
	mult_by3 row1_3 (.index(a1), .product(r1_3));

	mult_by2 row2_2 (.index(a2), .product(r2_2));
	mult_by3 row2_3 (.index(a2), .product(r2_3));

	mult_by2 row3_2 (.index(a3), .product(r3_2));
	mult_by3 row3_3 (.index(a3), .product(r3_3));


always @*
	begin
	
	a0 = col_in [0:7];
	a1 = col_in [8:15];
	a2 = col_in [16:23];
	a3 = col_in [24:31];

	// calculate rows by performing xor

	r0 = (r0_2 ^ r1_3 ^ a2 ^ a3);
	r1 = (r1_2 ^ r2_3 ^ a0 ^ a3);	
	r2 = (r2_2 ^ r3_3 ^ a0 ^ a1);
	r3 = (r0_3 ^ r3_2 ^ a1 ^ a2);

	end // end always block




	assign col_out [0:7] = r0; //(r0_2 ^ r1_3 ^ a2 ^ a3);
	assign col_out [8:15] = r1; //(r1_2 ^ r2_3 ^ a0 ^ a3);	
	assign col_out [16:23] = r2; //(r2_2 ^ r3_3 ^ a0 ^ a1);
	assign col_out [24:31] = r3; //(r0_3 ^ r3_2 ^ a1 ^ a2);

endmodule


///////////////////////////////
///// Test Module /////////////
///////////////////////////////


/*
module mix_columns_tester();

reg [0:127] state_in;

reg [0:31] s1, s2, s3, s4; // each row of the state
reg [0:31] s_in1, s_in2, s_in3, s_in4;

wire [0:127] state_out;

wire [0:7] prod;

mix_columns mcolumns (.state_in(state_in), .state_out(state_out));

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


module docoltest();


wire [0:31] col_out;
reg [0:31] col_in;

doColumns column (.col_in(col_in), .col_out(col_out));

initial begin
col_in = 32'hd4bf5d30;

#2 $display ("column value");
$display (" ");
$display ("%h", col_out[0:7]);
$display ("%h", col_out[8:15]);
$display ("%h", col_out[16:23]);
$display ("%h", col_out[24:31]);

end







endmodule
*/



