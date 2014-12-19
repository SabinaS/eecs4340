import "DPI" function void md5hash(input string src,
	output bit[127:0] res,
	input int in_len);
import "DPI" function void aes_encrypt(input bit [128:0] key, 
	input bit [128:0] to_encrypt,
	output bit [128:0] encrypted_message,
	input int in_len);
import "DPI" function void generate_rsa_keys_lib(output bit[4095:0] modulus,
	private_key);
import "DPI" function void rsa_encrypt(input bit[127:0] current_aes_key,
	output [4095:0] encrypted_aes_key);
import "DPI" function void printout_128(input bit[127:0] ptr);
import "DPI" function void printout_256(input bit[255:0] ptr);
import "DPI" function void printout_384(input bit[383:0] ptr);

class transaction;
	// vars
	rand bit reset;
	rand bit[127:0] current_aes_key;
	bit [4095:0] encrypted_aes_key;

	function void generate_new_aes_key();
		randomize();
		rsa_encrypt(current_aes_key, encrypted_aes_key); /* uses statically stored key */
		printout_128(current_aes_key);
	endfunction

	// Checking the reset functionality
	function bit check_reset(logic out_valid_o, rsa_ready_o, aes_ready_o,
			led_pass_o, led_fail_o);

		return ((out_valid_o == '0) &&
				(rsa_ready_o == 'b01) &&
				(aes_ready_o == 'b01) &&
				(led_pass_o == 'b01) && /* both LEDS on during reset */
				(led_fail_o == 'b01));
	endfunction

	function bit check_stall(logic aes_ready_o, rsa_ready_o);
		return ((aes_ready_o == '0) &&
				(rsa_ready_o == '0));
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
	bit [127:0] passphrase_md5 = '0;

	bit [128:0] key_header;
	bit [128:0] key_aes_rsa;
	bit [128:0] key_header_to_encrypt;
	bit [8191:0] rsa_info;
	bit [8319:0] full_data;

	bit [4095:0] modulus = '0; /* modulus */
	bit [4095:0] private_key;

	int data_selector = 0;
	int encrypted_aes_data_selector = 0;
	int incoming_data_selector = 0;
	int keyboard_data_selector = 0;
	bit keyboard_done = '0;
	bit key_send_done = '0;

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
		bit [127:0] encrypted_message = '0;

		md5hash(correct_passphrase, passphrase_md5, passphrase_length);
		key_aes_rsa = {passphrase_md5};
		key_header_to_encrypt = {passphrase_md5};

		aes_encrypt(key_aes_rsa, key_header_to_encrypt, encrypted_message, 16);
		key_header = {encrypted_message};
/*		printout_128(passphrase_md5);
		printout_128(key_aes_rsa);
		printout_128(key_header_to_encrypt);
		printout_128(encrypted_message);
		$display("passphrase_md5: %x", passphrase_md5);
		$display("key_aes_rsa:    %x", key_aes_rsa);
		$display("to_encrypt:     %x", key_header_to_encrypt);
		$display("enc message:    %x", encrypted_message);*/
	endfunction

	function void generate_rsa_key();
		generate_rsa_keys_lib(modulus, private_key);
		rsa_info = {modulus, private_key};
	endfunction

	function void handle_reset();
		randomize();
		setup_keys_passphrases();
		generate_key_header();
		generate_rsa_key();
		full_data = {rsa_info, key_header};
		key_send_done = '0;
		/* ORDERING OF DATA MAY CAUSE PROBLEMS.  CHECK HERE DURING DEBUG */
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
	bit force_reset = 1'b0;

	initial begin
		t = new();
		v = new();
		v.read_config("config.txt");
		v.handle_reset();
		t.generate_new_aes_key();

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
			if(v.get_reset() || force_reset) begin
				//force_reset <= 1'b0;
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
					if (ds.cb.rsa_ready_o && !v.key_send_done) begin
						$display("sent rsa data %d", v.data_selector);
						ds.cb.rsa_data_i <=
							v.full_data[128*v.data_selector +: 128];
						ds.cb.rsa_valid_i <= 1'b1;
						v.data_selector = v.data_selector + 1;
						if (v.data_selector == 65) begin
							v.key_send_done = 0'b1;
						end
					end else begin
						ds.cb.rsa_valid_i <= 1'b0;
					end

					/* handle keyboard */
					/* TODO add reset functionality */
					if (!v.keyboard_done && v.key_send_done) begin
						if (!v.use_passphrase.substr(
									v.keyboard_data_selector,
									v.keyboard_data_selector).compare("\n")) begin
						 $display("kb done asserted");
							ds.cb.ps2_done <= 1'b1;
							ds.cb.ps2_valid_i <= 1'b0;
							v.keyboard_done = 1;
						end else begin
						 $display("sent kb data %d", v.keyboard_data_selector);
							ds.cb.ps2_data_i <=
								v.use_passphrase.substr(
									v.keyboard_data_selector + 1,
									v.keyboard_data_selector);
							ds.cb.ps2_valid_i <= 1'b1;
							v.keyboard_data_selector =
								v.keyboard_data_selector + 1;
						end
					end /* end keyboard */

					/* handle aes */
					if (ds.cb.aes_ready_o) begin
						/* TODO how is data being spit out to AES?
						   How does AES know what to decrypt? */
						 $display("sent aes data %d", v.encrypted_aes_data_selector);
						ds.cb.aes_data_i <=
							t.encrypted_aes_key[128*v.encrypted_aes_data_selector +: 128];
						ds.cb.aes_valid_i <= 1'b1;
						v.encrypted_aes_data_selector = (v.encrypted_aes_data_selector + 1) % 32; /*4096 / 128*/
					end else begin
						ds.cb.aes_valid_i <= 1'b0;
					end
				end
			end /* end reset check */

			@(ds.cb);

			if(v.get_reset() || force_reset) begin
				$display("%t : %s \n", $realtime,
					t.check_reset(ds.cb.out_valid_o,
						ds.cb.rsa_ready_o, ds.cb.aes_ready_o,
						ds.cb.led_pass_o, ds.cb.led_fail_o)
					? "Pass-reset" : "Fail-reset");
				v.handle_reset();
				v.data_selector = 0;
				v.incoming_data_selector = 0;
				v.keyboard_data_selector = 0;
				v.keyboard_done = '0;
				force_reset = 1'b0;
			end else begin
				if (v.get_stall()) begin
					$display("%t : %s \n", $realtime,
						t.check_stall(ds.cb.aes_ready_o, ds.cb.rsa_ready_o)
						? "Pass-stall" : "Fail-stall");
				end else begin
					/* checks data out */
					if (ds.cb.out_valid_o) begin
						$display("%t : %s \n", $realtime,
							t.current_aes_key == ds.cb.out_data_o ?
							"Pass-data" : "Fail-data");
						t.generate_new_aes_key();
					end
				end
			end
		end
	end
endprogram
