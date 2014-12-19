module add_roundkey( state_in, key, state_out);
	
 input [0:127] state_in;
 input [0:127] key;

 output [0:127] state_out;


 // possible implementation to reduce x's in output?

 // assign state_out = (state_in != 0) ? (state_in ^ key) : 127'b0;

assign state_out = (state_in ^ key);


endmodule

/*
module addkey_tester();


reg [0:127] state_in, key;

reg [0:31] s1, s2, s3, s4; // each row of the state
reg [0:31] s_in1, s_in2, s_in3, s_in4;

wire [0:127] state_out;

add_roundkey addkey(.state_in(state_in), .key(key), .state_out(state_out));

initial begin
	$dumpfile ("dumpfiles/add_roundkey.dump");
	$dumpvars (0, addkey_tester);
end

initial begin

	state_in = 128'h00112233445566778899aabbccddeeff;

	key = 128'haaaabbbbccccddddeeeeffff00223344;


	s_in1 = {state_in[0:7], state_in[32:39], state_in[64:71], state_in[96:103]};
	s_in2 = {state_in[8:15], state_in[40:47], state_in[72:79], state_in[104:111]};
	s_in3 = {state_in[16:23], state_in[48:55], state_in[80:87], state_in[112:119]};
	s_in4 = {state_in[24:31], state_in[56:63], state_in[88:95], state_in[120:127]};

	s1 = {state_out[0:7], state_out[32:39], state_out[64:71], state_out[96:103]};
	s2 = {state_out[8:15], state_out[40:47], state_out[72:79], state_out[104:111]};
	s3 = {state_out[16:23], state_out[48:55], state_out[80:87], state_out[112:119]};
	s4 = {state_out[24:31], state_out[56:63], state_out[88:95], state_out[120:127]};

	$display ("Key: %h", key);

	$display("%h", s_in1);
	$display("%h", s_in2);
	$display("%h", s_in3);
	$display("%h", s_in4);

	$display(" ");

	$display("%h", s1);
	$display("%h", s2);
	$display("%h", s3);
	$display("%h", s4);
	
end 
endmodule
*/

