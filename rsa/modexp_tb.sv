class transaction;
	// vars
	rand logic [4095:0] exp, mod;
	rand logic [127:0] key_i; /* really padded with zeros */
	logic [4095:0] key_o;
	logic [8191:0] intermediate;

	function void generate_data();
		int i;

		intermediate = '1;
		for(i = 4095; i >= 0; --i) begin
			if (exp[i] == 1) begin
				intermediate = (key_i * intermediate) % mod;
			end
			if (i != 0) begin
				intermediate = (intermediate * intermediate) % mod;
			end
		end

		key_o = intermediate[4095:0];
	endfunction

	function bit verify_data(logic[127:0] recieved);
		return (recieved == key_o);
	endfunction

	// Checking the reset functionality
	function bit check_reset(bit done);
		return (done == '0);
	endfunction
endclass 


class testing_env;
	rand int unsigned reset_rn;
	rand int unsigned stall_rn;

	bit reset;

	int iter;
	int reset_thresh;
	int stall_thresh;

	function void read_config(string filename);
		int file, chars_returned, seed, value;
		string param;
		file = $fopen(filename, "r");

		while(!$feof(file)) begin
			chars_returned = $fscanf(file, "%s %d", param, value);
			if("RANDOM_SEED" == param) begin
				seed = value;
				$srandom(seed);
			end else if("ITERATIONS" == param) begin
				iter = value;
			end else if("RESET_PROB" == param) begin
				reset_thresh = value;
			end else if("STALL_PROB" == param) begin
				stall_thresh = value;
			end else begin
				$display("Unused parameter %s", param);
			end
		end
	endfunction

	function void handle_reset();
		randomize();
	endfunction

	function bit get_reset();
		return ((reset_rn % 10000) < reset_thresh);
	endfunction

	function bit get_stall();
		return ((stall_rn % 10000) < stall_thresh);
	endfunction

endclass


program modexp_tb (modexp_ifc.bench ds);

	transaction t; 
	testing_env v;

	int failures = 0;
	bit reset;
	bit should_initiate;
	bit force_reset = '0;
	initial begin
		t = new();
		v = new();
		v.read_config("modexp_config.txt");
		v.handle_reset();

		// run reset for a little bit
		repeat(10) begin
			ds.cb.rst <= 1'b1;
			@(ds.cb);
		end

		ds.cb.rst <= 1'b0;
		@(ds.cb);

		should_initiate = '1;
		// Iterate iter number of cycles
		repeat (v.iter) begin
			v.randomize();
			if(v.get_reset() || force_reset) begin
				ds.cb.rst <= 1'b1;
				$display("%t : %s \n", $realtime, "Driving Reset");
				should_initiate <= '1; /* start data transfer next cycle */
			end else begin
				ds.cb.rst <= 1'b0;
				if (v.get_stall()) begin
					/* not sure if I care */
					$display("%t : %s \n", $realtime, "Driving Stall");
				end else if (should_initiate) begin
					ds.cb.stall<= '0;
					$display("%t : %s \n", $realtime, "Driving Data");
					t.randomize();
					t.generate_data();
					ds.cb.mod <= t.mod;
					ds.cb.exp <= t.exp;
					ds.cb.data_i <= t.key_i;
					ds.cb.start <= '1;
					should_initiate <= '0;
				end else begin
					ds.cb.start <= '0;
				end
			end

			@(ds.cb);

			if(v.get_reset() || force_reset) begin
				$display("%t : %s \n", $realtime,
					t.check_reset(ds.cb.done)
					? "Pass-reset" : "Fail-reset");
				v.handle_reset();
				force_reset <= '0;
			end else begin
				if (v.get_stall()) begin
					/* don't think I care */
					$display("%t : %s \n", $realtime, "Pass-stall");
				end else if (ds.cb.done) begin
					if (t.verify_data(ds.cb.data_o)) begin
						$display("%t : %s \n", $realtime, "Pass-data");
					end else begin
						$display("\nFail-data: %d %d\n\n", ds.cb.data_o, t.key_o);
					end
					force_reset <= '1;
				end
			end

			/* finished with this iteration */
		end
	end
endprogram
