`timescale 1ns/1ns

class transaction;
	/* ToDo */

	rand bit reset;

	function bit check_reset(logic [7:0] ps2_code, logic ps2_code_new, logic valid);
		ps2_code = '0;
		ps2_code_new = '0;
		valid = '0;

		return ( (ps2_code == '0) && (ps2_code_new == '0) && (valid == '0) );
	endfunction

	function void golden_result();
		/* ToDo */
	endfunction

endclass

program ps2_tb (ps2_ifc.bench ds);

	transaction t;

	integer i, seed;
	logic [7:0] rand_num;
	initial begin
		t = new();
		$display("ps2_tb after intial");
		ds.cb.rst <= 1'b1;
		@(ds.cb);
		ds.cb.rst <= 1'b0;
		@(ds.cb);

		seed = 1'b0; 
		/*for(i=0; i< 100; i = i+1) begin*/
			$srandom(10);
			$display("rand_num %d", $urandom_range(10,1));
			/*#1ns*/
		/*end*/


		/* write a series of hex to the keyboard module */
		/* check that you are getting the correct ascii codes back */

	end


endprogram
