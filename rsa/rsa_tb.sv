import "DPI" function longint md5hash(input string src, res, int in_len);

class transaction;
	// vars
	rand bit reset;

	// Checking the reset functionality
	function bit check_reset(logic out_valid_o, rsa_ready_o, aes_ready_o,
			led_pass_o, led_fail_o);

		return ((out_valid_o == '0) &&
				(rsa_ready_o == '1) &&
				(aes_ready_o == '1) &&
				(led_pass_o == '1) && /* both LEDS on during reset */
				(led_fail_o == '1));
	endfunction

	function bit check_stall(logic aes_ready_o, rsa_ready_o);
		return ((aes_ready_o == '0) &&
				(rsa_ready_o == '0));
	endfunction

	function void golden_result();
		// TODO later
	endfunction


endclass 


class testing_env;
	rand int unsigned rn;
	rand int unsigned rn2;

	bit reset;

	int reset_thresh;
	int stall_thresh;
	int passphrase_thresh;

	int iter;

	integer in_file;
	integer out_file;

	string correct_passphrase;
	string use_passphrase;
	int passphrase_length;
	int use_pp_length;

	/* make sure there's space for the md5 hash */
	logic [127:0] passphrase_md5 = "0123456789ABCDEFh";
	rand logic [127:0] random_md5_pad;

	logic [383:0] key_header;
	logic [255:0] key_aes_rsa;
	logic [8191:0] rsa_info;
	logic [8575:0] full_data;

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
			end else if ("CORRECT_PASSPHRASE" == param) begin
				passphrase_thresh = value;
			end else begin
				$display("Invalid parameter");
				$exit();
			end
		end
	endfunction

	function void setup_keys_passphrases();
		int i;
		correct_passphrase = "";
		for (i = 56; i>=0; i=i-1) begin
		    begin
		        correct_passphrase = {string'($random), correct_passphrase};
		    end
		end

		passphrase_length = $random % 56;
		/* effectively end it early */
		correct_passphrase[passphrase_length] = "\n";

		if (get_correct_pp()) begin
			use_passphrase = correct_passphrase;
		end else begin
			int i;
			use_passphrase = "";
			for (i = 56; i>=0; i=i-1) begin
			    begin
			        use_passphrase = {string'($random), use_passphrase};
			    end
			end

			use_pp_length = $random % 56;
			/* effectively end it early */
			use_passphrase[use_pp_length] = "\n";
		end
	endfunction

	function void generate_key_header();
		logic [127:0] zero_padding = '0;
		logic [255:0] to_encrypt;
		logic [255:0] encrypted_message;

		md5hash(correct_passphrase, passphrase_md5, correct_passphrase.len());
		key_aes_rsa = {passphrase_md5, random_md5_pad};
		to_encrypt = {passphrase_md5, zero_padding};
		/* TODO aes encrypt to_encrypt with key_aes_rsa ==> encrypted_message */
		key_header = {encrypted_message, random_md5_pad};
	endfunction

	function void generate_rsa_key();
		logic [4095:0] n; /* modulus */
		logic [4095:0] d; /* private exponent */
		logic [4095:0] e; /* public exponent */
		/* TODO implementation */
		rsa_info = {n, d};
	endfunction

	function bit get_reset();
		return ((rn % 1000) < reset_thresh);
	endfunction

	function bit get_stall();
		return ((rn2 % 1000) < stall_thresh);
	endfunction

	function bit get_correct_pp();
		return ((rn2 % 1000) < passphrase_thresh);
	endfunction

endclass


program rsa_tb (rsa_ifc.bench ds);

	transaction t; 
	testing_env v;

	int failures = 0;
	bit reset;

	int data_selector = 0;
	int keyboard_data_selector = 0;
	bit keyboard_done = '0;

	initial begin
		t = new();
		v = new();
		v.read_config("config.txt");
		v.setup_keys_passphrases();
		v.generate_key_header();
		v.generate_rsa_key();
		v.full_data = {v.rsa_info, v.key_header};
		/* ORDERING OF DATA MAY CAUSE PROBLEMS.  CHECK HERE DURING DEBUG */

		// Drive inputs for next cycles
		ds.cb.rst <= t.reset;

		// run reset for a little bit
		repeat(10) begin
		ds.cb.rst <= 1'b1;
		@(ds.cb);
		end

		ds.cb.rst <= 1'b0;
		@(ds.cb);

		// Iterate iter number of cycles
		repeat (v.iter) begin
			v.randomize();
			if(v.get_reset()) begin
				ds.cb.rst <= 1'b1;
				$display("%t : %s \n", $realtime, "Driving Reset");
			end else begin
				ds.cb.rst <= 1'b0;
				if (v.get_stall()) begin
					ds.cb.stall <= 1'b1;
					/* necessary? */
					ds.cb.rsa_valid_i <= 1'b0;
					ds.cb.aes_valid_i <= 1'b0;
					ds.cb.ps2_valid_i <= 1'b0;
				end else begin
					ds.cb.stall <= 1'b0;
					/* send data if necessary */
					if (ds.cb.rsa_ready_o) begin
						ds.cb.rsa_data_i <=
							v.full_data[32*data_selector +: 32];
						ds.cb.rsa_valid_i <= 1'b1;
						data_selector = data_selector + 1;
					end else begin
						ds.cb.rsa_valid_i <= 1'b0;
					end

					/* handle aes */
					if (ds.cb.aes_ready_o) begin
						/* TODO make real */
						ds.cb.aes_data_i <= '0;
						ds.cb.aes_valid_i <= 1'b1;
					end else begin
						ds.cb.aes_valid_i <= 1'b0;
					end

					/* handle keyboard */
					/* TODO add reset functionality */
					if (!keyboard_done) begin
						if (v.use_passphrase.substr(
									8*(keyboard_data_selector + 1),
									8*keyboard_data_selector) ==
								"\n") begin
							ds.cb.ps2_done <= 1'b1;
							ds.cb.ps2_valid_i <= 1'b0;
							keyboard_done = 1;
						end else begin
							ds.cb.ps2_data_i <=
								//v.use_passphrase[8*keyboard_data_selector +: 8];
								v.use_passphrase.substr(
									8*(keyboard_data_selector + 1),
									8*keyboard_data_selector);
							ds.cb.ps2_valid_i <= 1'b1;
							keyboard_data_selector = keyboard_data_selector + 1;
						end
					end
				end
			end

			@(ds.cb);

			if(v.get_reset()) begin
				$display("%t : %s \n", $realtime,
					t.check_reset(ds.cb.out_valid_o,
						ds.cb.rsa_ready_o, ds.cb.aes_ready_o,
						ds.cb.led_pass_o, ds.cb.led_fail_o)
					? "Pass-reset" : "Fail-reset");
			end else begin
				if (v.get_stall()) begin
					$display("%t : %s \n", $realtime,
						t.check_stall(ds.cb.aes_ready_o, ds.cb.rsa_ready_o)
						? "Pass-stall" : "Fail-stall");
				end else begin
				/* data checks */
					if (ds.cb.out_valid_o) begin

					end
				end
			end

			/* TODO: golden_output */
		end
	end
endprogram
