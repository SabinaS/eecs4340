'timescale 1ns/1ns

module ps2_top (
	clk, rst, ps2_clk, ps2_data,
	ps2_code, ps2_code_new, valid

);

/* Inputs */
/* ps2_clk is the PS2 clock for the keyboard
 * ps2_data is the data signal from ps2
 * clk is the global signal
 */
input clk, rst;
intput ps2_clk;
input ps2_data; 

/* Outputs */
/* ps2_code is the code received from PS/2
 * ps2_code_new is the flag that new PS/2 code is available on ps2_code bus
 */
output [7:0] ps2_code;
output ps2_code_new;
output valid; 

/* Variables */
logic [25:0] clk_freq = 26'h2FAF080;
logic [3:0] debounce_counter_size = 4'h8; 
logic [1:0] sync_ffs;
logic ps2_clk_int;
logic ps2_data_int;
logic [10:0] ps2_word;
logic error;
logic [15:0] count_idle;  					/* todo: check */


/* Behavior */
always_ff @(posedge clk) begin

	/* Reset */
	if (rst) begin
		/* ToDo */
		ps2_code <= '0;
		ps2_code_new <= '0;
		valid <= '0;

	end 

	/* synchronize the flipflops */
	if(clk) begin
		sync_ffs[0] <= ps2_clk;
		sync_ffs[1] <= ps2_data; 
	end

	/* instancing debounce */
	debounce debounce_ps2_clk(
		.clk(clk),
		.button(sync_ffs[0]),
		.result(ps2_clk_int)
	);
	defparam debouce_ps2_clk.counter_size = debounce_counter_size;

	debounce debounce_ps2_data(
		.clk(clk),
		.button(sync_ffs[1]),
		.result(ps2_data_int)
	);
	defparam debouce_ps2_data.counter_size = debounce_counter_size;

	/* input ps2 data */
	if (ps2_clk_int == '0) begin
		ps2_word <= ps2_data_int & ps2_word[10:1];
	end

	/* verify that parity, start, and stop bits are all correct */
	if( !(~ps2_word[0] && ps2_word[10] && (ps2_word[9] ^ ps2_word[8] ^
        ps2_word[7] ^ ps2_word[6] ^ ps2_word[5] ^ ps2_word[4] ^ ps2_word[3] ^ 
        ps2_word[2] ^ ps2_word[1]) ) begin
        error = 1'h1; 
    end

    if (clk) begin
    	if(ps2_clk_int == '0) begin
    		count_idle <= '0;
    	end else if (count_idle  != 16'hADA) begin 		/* todo: check this */
    		count_idle <= count_idle + 1'h1; 
    	end

    	if(count_idle == 16'hADA && error == '0) begin
    		ps2_code_new <= '1;
    		ps2_code <= ps2_word[8:1];
    		valid = '1;
    	end else begin
    		ps2_code_new <= '0; 
    	end
    end
	
	 
end

endmodule
