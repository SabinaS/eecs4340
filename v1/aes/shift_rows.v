module shift_rows( state_in, state_out);
	
 input [0:127] state_in;

 output [0:127] state_out;

 // First row is not shifted
 assign state_out [0:7] = state_in [0:7];
 assign state_out [32:39] = state_in [32:39];
 assign state_out [64:71] = state_in [64:71];
 assign state_out [96:103] = state_in [96:103];

 // Second row shifted by 1
 assign state_out [8:15] = state_in [40:47];
 assign state_out [40:47] = state_in [72:79];
 assign state_out [72:79] = state_in [104:111];
 assign state_out [104:111] = state_in [8:15];

 // Third row shifted by 2
 assign state_out [16:23] = state_in [80:87];
 assign state_out [48:55] = state_in [112:119];
 assign state_out [80:87] = state_in [16:23];
 assign state_out [112:119] = state_in [48:55];

 // Fourth row shifted by 3
 assign state_out [24:31] = state_in [120:127];
 assign state_out [56:63] = state_in [24:31];
 assign state_out [88:95] = state_in [56:63];
 assign state_out [120:127] = state_in [88:95];

	
endmodule



///////////////////////////////
///// Test Module /////////////
///////////////////////////////

/*

module shift_rows_tester();

reg [0:127] state_in;

reg [0:31] s1, s2, s3, s4; // each row of the state
reg [0:31] s_in1, s_in2, s_in3, s_in4;

wire [0:127] state_out;

shift_rows srows (.state_in(state_in), .state_out(state_out));

initial begin
	$dumpfile ("shift_rows.dump");
	$dumpvars (0, shift_rows_tester);
end


initial begin

	state_in = 128'h00112233445566778899aabbccddeeff;

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

	$display("%h", s1);
	$display("%h", s2);
	$display("%h", s3);
	$display("%h", s4);



	//$display("State_in = %h", state_in);
	//$display("State out = %h", state_out);
end


endmodule

*/

