

module aespipe (/*AUTOARG*/
   // Outputs
   aesdata,
   // Inputs
   clk, rst, data_in, key
   );
  input clk;
  input rst;
  input [0:127] key; // encryption key

  input [0:127] data_in; // input cleartext
 // input start;


  output [0:127] aesdata; // output cyphertext
 
  // roundkey wiring

   wire [0:127] roundkey_0, roundkey_1, roundkey_2, roundkey_3,
		roundkey_4, roundkey_5, roundkey_6, roundkey_7, roundkey_8,
   		roundkey_9, roundkey_10;

  // wiring between rounds

  wire [0:127] r1_out,
	       r2_in, r2_out,
	       r3_in, r3_out,
	       r4_in, r4_out,
	       r5_in, r5_out,
	       r6_in, r6_out,
	       r7_in, r7_out,
	       r8_in, r8_out,
	       r9_in, r9_out,
	       r10_in, aes_out;


  key_expansion key_expand(.key(key),
		.clk(clk),
		.rst(rst),
		.roundkey_0(roundkey_0),
		.roundkey_1(roundkey_1),
		.roundkey_2(roundkey_2),
		.roundkey_3(roundkey_3),
		.roundkey_4(roundkey_4),
		.roundkey_5(roundkey_5),
		.roundkey_6(roundkey_6),
		.roundkey_7(roundkey_7),
		.roundkey_8(roundkey_8),
		.roundkey_9(roundkey_9),
		.roundkey_10(roundkey_10));

  // first round
  first_round r1 (.state_in(data_in), 
		  .state_out(r1_out), 
		  .roundkey_0(roundkey_0),
     		  .roundkey_1(roundkey_1),
		  .clk(clk),
		  .rst(rst));

  pipereg pr1(.din(r1_out), 
	      .dout(r2_in), 
              .clk(clk), 
              .rst(rst));


  // second round
  std_round r2 (.state_in(r2_in),
		.state_out(r2_out), 
		.roundkey(roundkey_2),
		.clk(clk),
		.rst(rst));

  pipereg pr2(  .din(r2_out), 
	        .dout(r3_in), 
		.clk(clk), 
		.rst(rst));

  // third round
  std_round r3 (.state_in(r3_in),
		.state_out(r3_out), 
		.roundkey(roundkey_3),
		.clk(clk),
		.rst(rst));

  pipereg pr3(	.din(r3_out),
	 	.dout(r4_in),
		.clk(clk), 
		.rst(rst));

  // fourth round
  std_round r4 (.state_in(r4_in),
 		.state_out(r4_out),
		.roundkey(roundkey_4),
		.clk(clk),
		.rst(rst));
 
  pipereg pr4(  .din(r4_out), 
		.dout(r5_in), 
		.clk(clk), 
		.rst(rst));

  // fifth round
  std_round r5 (.state_in(r5_in),
		.state_out(r5_out), 
		.roundkey(roundkey_5),
		.clk(clk),
		.rst(rst));
	
  pipereg pr5(	.din(r5_out),
		.dout(r6_in),
		.clk(clk),
		.rst(rst));

  // sixth round
  std_round r6 (.state_in(r6_in),
		 .state_out(r6_out),
		 .roundkey(roundkey_6),
		 .clk(clk),
	  	 .rst(rst));

  pipereg pr6(  .din(r6_out), 
		.dout(r7_in), 
		.clk(clk), 
		.rst(rst));

  // seventh round
  std_round r7 (.state_in(r7_in),
		.state_out(r7_out), 
		.roundkey(roundkey_7),
		.clk(clk),
		.rst(rst));

  pipereg pr7(  .din(r7_out), 
		.dout(r8_in), 
		.clk(clk), 
		.rst(rst));

  // eighth round
  std_round r8 (.state_in(r8_in),
		.state_out(r8_out), 
		.roundkey(roundkey_8),
		.clk(clk),
		.rst(rst));

  pipereg pr8(  .din(r8_out), 
		.dout(r9_in),
		.clk(clk),
		.rst(rst));

  // ninth round
  std_round r9 (.state_in(r9_in), 
		.state_out(r9_out), 
		.roundkey(roundkey_9),
		.clk(clk),
		.rst(rst));

  pipereg pr9(  .din(r9_out), 
		.dout(r10_in),
		.clk(clk),
		.rst(rst));

  // tenth (last) round
  last_round r10 (.state_in(r10_in),
		  .state_out(aes_out), 
		  .roundkey(roundkey_10),
		  .clk(clk),
		  .rst(rst));	 


assign aesdata = aes_out;


endmodule

