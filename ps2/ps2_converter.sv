`timescale 1ns/1ns

module ps2_converter(
	clk, ps2_clk, rst, 
	ps2_data, ascii_new, ascii_code,
	ps2_code_new, ps2_code
);

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
	.clk(clk),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_data),
	.ps2_code(ps2_code),
	.ps2_code_new(ps2_code_new)
);
defparam ps2_keyboard.clk_freq = clk_freq;
defparam ps2_keyboard.debounce_counter_size = ps2_debounce_counter_size;

/* Behavior */
always_ff @(posedge clk) begin


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
		case (state == ready)
			if(prev_ps2_code_new == '0 && ps2_code_new == '1) begin
				ascii_new <= '0;
				state <= new_code; 
			end else begin
				state <= ready; 
			end
		endcase

		/* new_code state: determine what to do with the new PS2 code */
		case (state == new_code)
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
		endcase

		/* translate state: translate PS2 code to ASCII value */
		case (state == translate)
			break_var <= '0;
			e0_code <= '0;

			/* handle codes for control, shift, and caps lock */
			case (ps2_code == 8'h58) begin
				if(break_var == '0) begin
					caps_lock <= ~caps_lock; 
				end
			end

			case (ps2_code == 8'h14) begin
				if(e0_code == '1) ebgin
					control_r <= ~break_var; 
				end else begin
					control_l <= ~break_var; 
				end
			end

			case (ps2_code == 8'h12) begin
				shift_l <= ~break_var;
			end

			case (ps2_code <= 8'h59) begin
				shift_r <= ~break_var; 
			end
			/* todo: should have default?? */

			/* translate control codes  */
			if (control_l == '1 || control_r == '1) begin
				case(ps2_code == 8'h1E) begin 
					ascii <= 8'h00;
				endcase
                case(ps2_code == 8'h1C) begin
                	ascii <= 8'h01;  /*^A  SOH */
                endcase
                case(ps2_code == 8'h32) begin
                	ascii <= 8'h02; /*^B  STX */
                endcase
                case(ps2_code == 8'h21 ) begin   
                	ascii <= 8'h03; 
                endcase
                case(ps2_code == 8'h23 ) begin   
                	ascii <= 8'h04;
                endcase
                case(ps2_code == 8'h24 ) begin   
                	ascii <= 8'h05;
                endcase
                case(ps2_code == 8'h2B ) begin   
                	ascii <= 8'h06;
                endcase
                case(ps2_code == 8'h34 ) begin   
                	ascii <= 8'h07;
                endcase
                case(ps2_code == 8'h33 ) begin   
                	ascii <= 8'h08;
                endcase
                case(ps2_code == 8'h43 ) begin   
                	ascii <= 8'h09;
                endcase
                case(ps2_code == 8'h3B ) begin   
                	ascii <= 8'h0A;
                endcase 
                case(ps2_code == 8'h42 ) begin   
                	ascii <= 8'h0B;
                endcase 
                case(ps2_code == 8'h4B ) begin   
                	ascii <= 8'h0C;
                endcase 
                case(ps2_code == 8'h3A ) begin   
                	ascii <= 8'h0D;
                endcase  
                case(ps2_code == 8'h31 ) begin   
               		ascii <= 8'h0E;
               	endcase  
                case(ps2_code == 8'h44 ) begin   
                	ascii <= 8'h0F;
                endcase  
                case(ps2_code == 8'h4D ) begin   
                	ascii <= 8'h10;
                endcase 
                case(ps2_code == 8'h15 ) begin   
               		ascii <= 8'h11;
               	endcase 
                case(ps2_code == 8'h2D ) begin  	
                	ascii <= 8'h12;
                endcase 
                case(ps2_code == 8'h1B ) begin   
                	ascii <= 8'h13;
                endcase 
                case(ps2_code == 8'h2C ) begin   
                	ascii <= 8'h14;
                endcase  
                case(ps2_code == 8'h3C ) begin   
                	ascii <= 8'h15;
                endcase  
                case(ps2_code == 8'h2A ) begin   
                	ascii <= 8'h16;
                endcase  
                case(ps2_code == 8'h1D ) begin   
                	ascii <= 8'h17;
                endcase 
                case(ps2_code == 8'h22 ) begin   
               		ascii <= 8'h18;
               	endcase 
                case(ps2_code == 8'h35 ) begin   
                	ascii <= 8'h19;
                endcase  
                case(ps2_code == 8'h1A ) begin   
                	ascii <= 8'h1A;
                endcase  
                case(ps2_code == 8'h54 ) begin   
                	ascii <= 8'h1B;
                endcase  
                case(ps2_code == 8'h5D ) begin   
                	ascii <= 8'h1C; 
                case(ps2_code == 8'h5B ) begin   
               		ascii <= 8'h1D 
               	endcase
                case(ps2_code == 8'h36 ) begin   
                	ascii <= 8'h1E 
                endcase
                case(ps2_code == 8'h4E ) begin   
                	ascii <= 8'h1F 
                endcase
                case(ps2_code == 8'h4A ) begin   
                	ascii <= 8'h7F
                endcase
                /* should have default??  */

			end else begin
				case (ps2_code ==  8'h29 ) begin ascii <= 8'h20; endcase
                case (ps2_code ==  8'h66 ) begin ascii <= 8'h08; endcase
                case (ps2_code ==  8'h0D ) begin ascii <= 8'h09; endcase
                case (ps2_code ==  8'h5A ) begin ascii <= 8'h0D; endcase
                case (ps2_code ==  8'h76 ) begin ascii <= 8'h1B; endcase
                case (ps2_code ==  8'h71 ) begin 
                	if(e0_code == '1) begin      
     					ascii <= 8'h7F;             
                  	end
                endcase
                /* should have defualt?? */

                if( (shift_r == '0 && shift_l == '0 && caps_lock == '0) 
                		|| ((shift_r == '1 || shift_l == '1) 
                		&& caps_lock == '1) ) begin
                	case (ps2_code ==  8'h1C) ascii <= 8'h61; endcase
					case (ps2_code ==  8'h32) ascii <= 8'h62; endcase
					case (ps2_code ==  8'h21) ascii <= 8'h63; endcase
					case (ps2_code ==  8'h23) ascii <= 8'h64; endcase
					case (ps2_code ==  8'h24) ascii <= 8'h65; endcase
					case (ps2_code ==  8'h2B) ascii <= 8'h66; endcase
					case (ps2_code ==  8'h34) ascii <= 8'h67; endcase
					case (ps2_code ==  8'h33) ascii <= 8'h68; endcase
					case (ps2_code ==  8'h43) ascii <= 8'h69; endcase
					case (ps2_code ==  8'h3B) ascii <= 8'h6A; endcase
					case (ps2_code ==  8'h42) ascii <= 8'h6B; endcase
					case (ps2_code ==  8'h4B) ascii <= 8'h6C; endcase
					case (ps2_code ==  8'h3A) ascii <= 8'h6D; endcase
					case (ps2_code ==  8'h31) ascii <= 8'h6E; endcase
					case (ps2_code ==  8'h44) ascii <= 8'h6F; endcase
					case (ps2_code ==  8'h4D) ascii <= 8'h70; endcase
					case (ps2_code ==  8'h15) ascii <= 8'h71; endcase
					case (ps2_code ==  8'h2D) ascii <= 8'h72; endcase
					case (ps2_code ==  8'h1B) ascii <= 8'h73; endcase
					case (ps2_code ==  8'h2C) ascii <= 8'h74; endcase
					case (ps2_code ==  8'h3C) ascii <= 8'h75; endcase
					case (ps2_code ==  8'h2A) ascii <= 8'h76; endcase
					case (ps2_code ==  8'h1D) ascii <= 8'h77; endcase
					case (ps2_code ==  8'h22) ascii <= 8'h78; endcase
					case (ps2_code ==  8'h35) ascii <= 8'h79; endcase
					case (ps2_code ==  8'h1A) ascii <= 8'h7A; endcase
                end else begin
                	case (ps2_code ==  8'h1C) ascii <= 8'h41; endcase
					case (ps2_code ==  8'h32) ascii <= 8'h42; endcase
					case (ps2_code ==  8'h21) ascii <= 8'h43; endcase
					case (ps2_code ==  8'h23) ascii <= 8'h44; endcase
					case (ps2_code ==  8'h24) ascii <= 8'h45; endcase
					case (ps2_code ==  8'h2B) ascii <= 8'h46; endcase
					case (ps2_code ==  8'h34) ascii <= 8'h47; endcase
					case (ps2_code ==  8'h33) ascii <= 8'h48; endcase
					case (ps2_code ==  8'h43) ascii <= 8'h49; endcase
					case (ps2_code ==  8'h3B) ascii <= 8'h4A; endcase
					case (ps2_code ==  8'h42) ascii <= 8'h4B; endcase
					case (ps2_code ==  8'h4B) ascii <= 8'h4C; endcase
					case (ps2_code ==  8'h3A) ascii <= 8'h4D; endcase
					case (ps2_code ==  8'h31) ascii <= 8'h4E; endcase
					case (ps2_code ==  8'h44) ascii <= 8'h4F; endcase
					case (ps2_code ==  8'h4D) ascii <= 8'h50; endcase
					case (ps2_code ==  8'h15) ascii <= 8'h51; endcase
					case (ps2_code ==  8'h2D) ascii <= 8'h52; endcase
					case (ps2_code ==  8'h1B) ascii <= 8'h53; endcase
					case (ps2_code ==  8'h2C) ascii <= 8'h54; endcase 
					case (ps2_code ==  8'h3C) ascii <= 8'h55; endcase 
					case (ps2_code ==  8'h2A) ascii <= 8'h56; endcase 
					case (ps2_code ==  8'h1D) ascii <= 8'h57; endcase
					case (ps2_code ==  8'h22) ascii <= 8'h58; endcase
					case (ps2_code ==  8'h35) ascii <= 8'h59; endcase
					case (ps2_code ==  8'h1A) ascii <= 8'h5A; endcase
                end

                if(shift_l == '1 || shift_r == '1) begin
                	case (ps2_code ==  8'h16) ascii <= 8'h21; endcase
					case (ps2_code ==  8'h52) ascii <= 8'h22; endcase
					case (ps2_code ==  8'h26) ascii <= 8'h23; endcase
					case (ps2_code ==  8'h25) ascii <= 8'h24; endcase
					case (ps2_code ==  8'h2E) ascii <= 8'h25; endcase
					case (ps2_code ==  8'h3D) ascii <= 8'h26; endcase              
					case (ps2_code ==  8'h46) ascii <= 8'h28; endcase
					case (ps2_code ==  8'h45) ascii <= 8'h29; endcase
					case (ps2_code ==  8'h3E) ascii <= 8'h2A; endcase
					case (ps2_code ==  8'h55) ascii <= 8'h2B; endcase
					case (ps2_code ==  8'h4C) ascii <= 8'h3A; endcase
					case (ps2_code ==  8'h41) ascii <= 8'h3C; endcase
					case (ps2_code ==  8'h49) ascii <= 8'h3E; endcase
					case (ps2_code ==  8'h4A) ascii <= 8'h3F; endcase
					case (ps2_code ==  8'h1E) ascii <= 8'h40; endcase
					case (ps2_code ==  8'h36) ascii <= 8'h5E; endcase
					case (ps2_code ==  8'h4E) ascii <= 8'h5F; endcase
					case (ps2_code ==  8'h54) ascii <= 8'h7B; endcase
					case (ps2_code ==  8'h5D) ascii <= 8'h7C; endcase
					case (ps2_code ==  8'h5B) ascii <= 8'h7D; endcase
					case (ps2_code ==  8'h0E) ascii <= 8'h7E; endcase
                end else begin
                	case (ps2_code ==  8'h45) ascii <= 8'h30; endcase
					case (ps2_code ==  8'h16) ascii <= 8'h31; endcase
					case (ps2_code ==  8'h1E) ascii <= 8'h32; endcase
					case (ps2_code ==  8'h26) ascii <= 8'h33; endcase
					case (ps2_code ==  8'h25) ascii <= 8'h34; endcase
					case (ps2_code ==  8'h2E) ascii <= 8'h35; endcase
					case (ps2_code ==  8'h36) ascii <= 8'h36; endcase
					case (ps2_code ==  8'h3D) ascii <= 8'h37; endcase
					case (ps2_code ==  8'h3E) ascii <= 8'h38; endcase
					case (ps2_code ==  8'h46) ascii <= 8'h39; endcase
					case (ps2_code ==  8'h52) ascii <= 8'h27; endcase
					case (ps2_code ==  8'h41) ascii <= 8'h2C; endcase
					case (ps2_code ==  8'h4E) ascii <= 8'h2D; endcase
					case (ps2_code ==  8'h49) ascii <= 8'h2E; endcase
					case (ps2_code ==  8'h4A) ascii <= 8'h2F; endcase
					case (ps2_code ==  8'h4C) ascii <= 8'h3B; endcase
					case (ps2_code ==  8'h55) ascii <= 8'h3D; endcase
					case (ps2_code ==  8'h54) ascii <= 8'h5B; endcase
					case (ps2_code ==  8'h5D) ascii <= 8'h5C; endcase
					case (ps2_code ==  8'h5B) ascii <= 8'h5D; endcase
					case (ps2_code ==  8'h0E) ascii <= 8'h60; endcase
                end
			end

			if(break_var == '0) begin
				state <= output_var;
			end else begin
				state <= ready; 
			end
		endcase

		case (state == output_var)
			if(ascii[7] == '0) begin
				ascii_new <= '1;
				ascii_code <= ascii;				/* ToDo: should this be ascii_code <= ascii[6:0]?? */
			end
			state <= ready; 						/* return to ready state to await next PS2 code*/ 
		endcase
	end


end

endmodule 

