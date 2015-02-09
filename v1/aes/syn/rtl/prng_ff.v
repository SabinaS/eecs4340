/**Columbia University EECS 4340 Computer Hardware Design**/
/**Fall 2010 Final Project**/
/**Scott Rogowski, Hsin-Tien Shen, Yipeng Huang**/
/**AESelerator**/

/*Basically a SR-flipflop with an enable bit so that the flipflop cannot be changed without first being enabled.  Reset of course still changes the flipflop to 0.*/

module prng_ff (clk, reset, enable, set, q);

	input clk;
	input reset;
	input enable;
	input set;
	
	output q;

	//flipflops store a value
	reg b;

	//change the value on the clock edge
	always @(posedge clk) begin
		if(reset)
			b <= 0;
		else if (enable)
			b <= set;
	end

	//q is always bit
	assign q = b;
			
endmodule