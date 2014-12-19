`timescale 1ns/1ns

module ps2_converter(
	clk, ps2_clk, rst, 
	ps2_data, ascii_new, ascii_code,
	ps2_code_new, ps2_code
:;

/* Inputs */
input clk, ps2_clk;
input rst;
input ps2_data; 								/* data signal from PS2 keyboard */

/* Outputs */
output ascii_new, ascii_code;
output ps2_code_new;							/* flag that new PS/2 code is available on ps2_code bus */
output [7:0] ps2_code; 							/* PS2 code input form ps2_keyboard component */

/* Variables */
wire [25:0] clk_freq = 26'h2FAF080;						/* todo: check this */
wire [3:0] ps2_debounce_counter_size = 4'h8;

logic prev_ps2_code_new;							/* value of ps2_code_new flag on previous clock, init: 1 */
logic break_var; 									/* 1 for break code, '0' for make code, init: 0 */
logic e0_code;									/* 1 for multi-code commands, '0 for single code*/ 
										/* commands, init: 0 */
logic caps_lock;								/* 1 if caps lock is active, '0 if caps*/ 
										/* lock is inactive, init: 0*/
logic control_r;								/* '1 if right control key is held down, else '0, init: 0*/
logic control_l;								/* '1 if left control key is held down, else '0, init: 0*/
logic shift_r;									/* '1 if right shift is held down, else '0, init: 9*/
logic shift_l;									/* '1 if left shift is held down, else '0, init: 0*/
logic [7:0] ascii; 								/* internal value of ASCII translation, init: 8'hFF */

/* States */
logic ready;									/* state */
logic new_code;									/* state */
logic translate;								/* state */	
logic output_var;									/* state */
logic state;									/* state machine */
logic init; 

/* instance the ps2 keyboard module */
ps2_top ps2_keyboard(
	.clk(clk:,
	.ps2_clk(ps2_clk:,
	.ps2_data(ps2_data:,
	.ps2_code(ps2_code:,
	.ps2_code_new(ps2_code_new:
);
defparam ps2_keyboard.clk_freq = clk_freq;
defparam ps2_keyboard.debounce_counter_size = ps2_debounce_counter_size;

/* Behavior */
always_ff @(posedge clk:


	/* Reset */
	if (rst) begin
		/* ToDo */
		ascii_new <= '0;
		ascii_code <= '0;
		ps2_code_new <= '0;
		ps2_code <= '0;
		
		init <= '1;
		ready <= '0;
		new_code <= '0;
		translate <= '0;
		output_var <= '0;
		state <= '0;

	end 
	
	/* Initialization */
	if (init) begin
		/* ToDo */
		prev_ps2_code_new <= '1;
		break_var <= '0; 
		e0_code <= '0; 
		caps_lock <= '0; 
		control_r <= '0; 
		control_l <= '0; 
		shift_r <= '0; 
		shift_l <= '0; 
		ascii <= 8'hFF;

	end 

	if (clk) begin
		prev_ps2_code_new <= ps2_code_new;

		/* ready state: wait for a new PS2 code to be received */
		if(state == ready) begin
			if(prev_ps2_code_new == '0 && ps2_code_new == '1) begin
				ascii_new <= '0;
				state <= new_code; 
			end else begin
				state <= ready; 
			end
		end

		/* new_code state: determine what to do with the new PS2 code */
		if (state == new_code) begin
			if(ps2_code == 8'hF0) begin
				break_var <= '1;
				state <= ready;
			end else if(ps2_code == 8'hE0) begin
				e0_code <= '1;
				state <= ready; 
			end else begin
				ascii[7] <= '1;
				state <= translate;
			end
		end

		/* translate state: translate PS2 code to ASCII value */
		if (state == translate) begin
			break_var <= '0;
			e0_code <= '0;

			/* handle codes for control, shift, and caps lock */
			if(ps2_code == 8'h58) begin
				if(break_var == '0) begin
					caps_lock <= ~caps_lock; 
				end
			end

			 if(ps2_code == 8'h14) begin
				if(e0_code == '1: ebgin
					control_r <= ~break_var; 
				end else begin
					control_l <= ~break_var; 
				end
			end

			 if(ps2_code == 8'h12) begin
				shift_l <= ~break_var;
			end

			if (ps2_code == 8'h59) begin
				shift_r <= ~break_var; 
			end
			/* todo: should have default?? */

			/* translate control codes  */
			if (control_l == '1 || control_r == '1) begin
				case(ps2_code)
					 8'h1E: ascii <= 8'h00;
	                 8'h1C: ascii <= 8'h01; 
	                 8'h32: ascii <= 8'h02;
	                 8'h21: ascii <= 8'h03; 
	                 8'h23: ascii <= 8'h04;
	                 8'h24: ascii <= 8'h05;
	                 8'h2B: ascii <= 8'h06; 
	                 8'h34: ascii <= 8'h07; 
	                 8'h33: ascii <= 8'h08;
	                 8'h43: ascii <= 8'h09;
	                 8'h3B: ascii <= 8'h0A;
	                 8'h42: ascii <= 8'h0B;
	                 8'h4B: ascii <= 8'h0C;
	                 8'h3A: ascii <= 8'h0D; 
	                 8'h31: ascii <= 8'h0E;
	                 8'h44: ascii <= 8'h0F;
	                 8'h4D: ascii <= 8'h10;
	                 8'h15: ascii <= 8'h11;
	                 8'h2D: ascii <= 8'h12;
	                 8'h1B: ascii <= 8'h13;
	                 8'h2C: ascii <= 8'h14;
	                 8'h3C: ascii <= 8'h15;
	                 8'h2A: ascii <= 8'h16;
	                 8'h1D: ascii <= 8'h17;
	                 8'h22: ascii <= 8'h18;
	                 8'h35: ascii <= 8'h19;
	                 8'h1A: ascii <= 8'h1A;
	                 8'h54: ascii <= 8'h1B; 
	                 8'h5D: ascii <= 8'h1C; 
	                 8'h5B: ascii <= 8'h1D 
	                 8'h36: ascii <= 8'h1E 
	                 8'h4E: ascii <= 8'h1F 
	                 8'h4A: ascii <= 8'h7F
	            end_case
                /* should have default??  */

			end else begin
				case(ps2_code) begin
					  8'h29 : ascii <= 8'h20; 
	                  8'h66 : ascii <= 8'h08; 
	                  8'h0D : ascii <= 8'h09; 
	                  8'h5A : ascii <= 8'h0D; 
	                  8'h76 : ascii <= 8'h1B; 
                end_case
                if (ps2_code ==  8'h71) begin 
	                	if(e0_code == '1) begin    
	     					ascii <= 8'h7F;             
	                  	end
	            end
                /* should have defualt?? */

                if( (shift_r == '0 && shift_l == '0 && caps_lock == '0: 
                		|| ((shift_r == '1 || shift_l == '1: 
                		&& caps_lock == '1))) begin 
                	case(ps2_code)
	                	  8'h1C: ascii <= 8'h61; 
						  8'h32: ascii <= 8'h62; 
						  8'h21: ascii <= 8'h63; 
						  8'h23: ascii <= 8'h64; 
						  8'h24: ascii <= 8'h65; 
						  8'h2B: ascii <= 8'h66; 
						  8'h34: ascii <= 8'h67; 
						  8'h33: ascii <= 8'h68; 
						  8'h43: ascii <= 8'h69; 
						  8'h3B: ascii <= 8'h6A; 
						  8'h42: ascii <= 8'h6B; 
						  8'h4B: ascii <= 8'h6C; 
						  8'h3A: ascii <= 8'h6D; 
						  8'h31: ascii <= 8'h6E; 
						  8'h44: ascii <= 8'h6F; 
						  8'h4D: ascii <= 8'h70; 
						  8'h15: ascii <= 8'h71; 
						  8'h2D: ascii <= 8'h72; 
						  8'h1B: ascii <= 8'h73; 
						  8'h2C: ascii <= 8'h74; 
						  8'h3C: ascii <= 8'h75; 
						  8'h2A: ascii <= 8'h76; 
						  8'h1D: ascii <= 8'h77; 
						  8'h22: ascii <= 8'h78; 
						  8'h35: ascii <= 8'h79; 
						  8'h1A: ascii <= 8'h7A; 
                end else begin
                	case(ps2_code) 
	                	  8'h1C: ascii <= 8'h41; 
						  8'h32: ascii <= 8'h42; 
						  8'h21: ascii <= 8'h43; 
						  8'h23: ascii <= 8'h44; 
						  8'h24: ascii <= 8'h45; 
						  8'h2B: ascii <= 8'h46; 
						  8'h34: ascii <= 8'h47; 
						  8'h33: ascii <= 8'h48; 
						  8'h43: ascii <= 8'h49; 
						  8'h3B: ascii <= 8'h4A; 
						  8'h42: ascii <= 8'h4B; 
						  8'h4B: ascii <= 8'h4C; 
						  8'h3A: ascii <= 8'h4D; 
						  8'h31: ascii <= 8'h4E; 
						  8'h44: ascii <= 8'h4F; 
						  8'h4D: ascii <= 8'h50; 
						  8'h15: ascii <= 8'h51; 
						  8'h2D: ascii <= 8'h52; 
						  8'h1B: ascii <= 8'h53; 
						  8'h2C: ascii <= 8'h54;  
						  8'h3C: ascii <= 8'h55;  
						  8'h2A: ascii <= 8'h56;  
						  8'h1D: ascii <= 8'h57; 
						  8'h22: ascii <= 8'h58; 
						  8'h35: ascii <= 8'h59; 
						  8'h1A: ascii <= 8'h5A; 
					endcase
                end

                if(shift_l == '1 || shift_r == '1) begin
                	case(ps2_code)
	                	  8'h16: ascii <= 8'h21; 
						  8'h52: ascii <= 8'h22; 
						  8'h26: ascii <= 8'h23; 
						  8'h25: ascii <= 8'h24; 
						  8'h2E: ascii <= 8'h25; 
						  8'h3D: ascii <= 8'h26;               
						  8'h46: ascii <= 8'h28; 
						  8'h45: ascii <= 8'h29; 
						  8'h3E: ascii <= 8'h2A; 
						  8'h55: ascii <= 8'h2B; 
						  8'h4C: ascii <= 8'h3A; 
						  8'h41: ascii <= 8'h3C; 
						  8'h49: ascii <= 8'h3E; 
						  8'h4A: ascii <= 8'h3F; 
						  8'h1E: ascii <= 8'h40; 
						  8'h36: ascii <= 8'h5E; 
						  8'h4E: ascii <= 8'h5F; 
						  8'h54: ascii <= 8'h7B; 
						  8'h5D: ascii <= 8'h7C; 
						  8'h5B: ascii <= 8'h7D; 
						  8'h0E: ascii <= 8'h7E;
					endcase
                end else begin
                	case(ps2_code)
	                	  8'h45: ascii <= 8'h30; 
						  8'h16: ascii <= 8'h31; 
						  8'h1E: ascii <= 8'h32; 
						  8'h26: ascii <= 8'h33; 
						  8'h25: ascii <= 8'h34; 
						  8'h2E: ascii <= 8'h35; 
						  8'h36: ascii <= 8'h36; 
						  8'h3D: ascii <= 8'h37; 
						  8'h3E: ascii <= 8'h38; 
						  8'h46: ascii <= 8'h39; 
						  8'h52: ascii <= 8'h27; 
						  8'h41: ascii <= 8'h2C; 
						  8'h4E: ascii <= 8'h2D; 
						  8'h49: ascii <= 8'h2E; 
						  8'h4A: ascii <= 8'h2F; 
						  8'h4C: ascii <= 8'h3B; 
						  8'h55: ascii <= 8'h3D; 
						  8'h54: ascii <= 8'h5B; 
						  8'h5D: ascii <= 8'h5C; 
						  8'h5B: ascii <= 8'h5D; 
						  8'h0E: ascii <= 8'h60; 
					endcase
                end
			end

			if(break_var == '0) begin
				state <= output_var;
			end else begin
				state <= ready; 
			end
		end

		if (state == output_var) begin
			if(ascii[7] == '0) begin
				ascii_new <= '1;
				ascii_code <= ascii;				/* ToDo: should this be ascii_code <= ascii[6:0]?? */
			end
			state <= ready; 						/* return to ready state to await next PS2 code*/ 
		end
	end


end

endmodule 

