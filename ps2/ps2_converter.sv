'timescale 1ns/1ns

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

logic prev_ps2_code_new;						/* value of ps2_code_new flag on previous clock, init: 1 */
logic break; 									/* '1 for break code, '0' for make code, init: 0*/
logic e0_code;									/* '1 for multi-code commands, '0 for single code 
												 * commands, init: 0
												 */
logic caps_lock;								/* '1 if caps lock is active, '0 if caps 
												 * lock is inactive, init: 0
												 */
logic control_r;								/* '1 if right control key is held down, else '0, init: 0*/
logic control_l;								/* '1 if left control key is held down, else '0, init: 0*/
logic shift_r;									/* '1 if right shift is held down, else '0, init: 9*/
logic shift_l;									/* '1 if left shift is held down, else '0, init: 0*/
logic [7:0] ascii; 								/* internal value of ASCII translation, init: 0xFF */

/* States */
logic ready;									/* state */
logic new_code;									/* state */
logic translate;								/* state */	
logic output;									/* state */
logic state;									/* state machine */
logic init; 


/* Behavior */
always_ff @(posedge clk) begin

	/* instance the ps2 keyboard module */
	ps2_top ps2_keyboard(
		.clk(clk),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data,
		.ps2_code(ps2_code),
		.ps2_code_new(ps2_code_new)
	);
	defparam ps2_keyboard.clk_freq = clk_freq;
	defparam ps2_keyboard.debounce_counter_size = ps2_debounce_counter_size;

	/* Reset */
	if (rst) begin
		/* ToDo */
		ascii_new_o <= '0;
		ascii_code_o <= '0;
		ps2_code_new_o <= '0;
		ps2_code_o <= '0;
		
		init <= '1;
		ready <= '0;
		new_code <= '0;
		translate <= '0;
		output <= '0;
		state <= '0;

	end 
	
	/* Initialization */
	if (init) begin
		/* ToDo */
		wait();
		prev_ps2_code_new <= '1;
		break <= '0; 
		e0_code <= '0; 
		caps_lock <= '0; 
		control_r <= '0; 
		control_l <= '0; 
		shift_r <= '0; 
		shift_l <= '0; 
		ascii <= 0xFF;

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
			if(ps2_code == 0xF0) begin
				break <= '1;
				state <= ready;
			end else if(ps2_code == 0xE0) begin
				e0_code <= '1;
				state <= ready; 
			end else begin
				ascii[7] <= '1;
				state <= translate;
			end
		endcase

		/* translate state: translate PS2 code to ASCII value */
		case (state == translate)
			break <= '0;
			e0_code <= '0;

			/* handle codes for control, shift, and caps lock */
			case (ps2_code == 0x58) begin
				if(break == '0) begin
					caps_lock <= ~caps_lock; 
				end
			end

			case (ps2_code == 0x14) begin
				if(e0_code == '1) ebgin
					control_r <= ~break; 
				end else begin
					control_l <= ~break; 
				end
			end

			case (ps2_code == 0x12) begin
				shift_l <= ~break;
			end

			case (ps2_code <= 0x59) begin
				shift_r <= ~break; 
			end
			/* todo: should have default?? */

			/* translate control codes  */
			if (control_l == '1 || control_r == '1) begin
				case(ps2_code == 0x1E) begin 
					ascii <= 0x00;
				endcase
                case(ps2_code == 0x1C) begin
                	ascii <= 0x01;  /*^A  SOH */
                endcase
                case(ps2_code == 0x32) begin
                	ascii <= 0x02; /*^B  STX */
                endcase
                case(ps2_code == 0x21 ) begin   
                	ascii <= 0x03; 
                endcase
                case(ps2_code == 0x23 ) begin   
                	ascii <= 0x04;
                endcase
                case(ps2_code == 0x24 ) begin   
                	ascii <= 0x05;
                endcase
                case(ps2_code == 0x2B ) begin   
                	ascii <= 0x06;
                endcase
                case(ps2_code == 0x34 ) begin   
                	ascii <= 0x07;
                endcase
                case(ps2_code == 0x33 ) begin   
                	ascii <= 0x08;
                endcase
                case(ps2_code == 0x43 ) begin   
                	ascii <= 0x09;
                endcase
                case(ps2_code == 0x3B ) begin   
                	ascii <= 0x0A;
                endcase 
                case(ps2_code == 0x42 ) begin   
                	ascii <= 0x0B;
                endcase 
                case(ps2_code == 0x4B ) begin   
                	ascii <= 0x0C;
                endcase 
                case(ps2_code == 0x3A ) begin   
                	ascii <= 0x0D;
                endcase  
                case(ps2_code == 0x31 ) begin   
               		ascii <= 0x0E;
               	endcase  
                case(ps2_code == 0x44 ) begin   
                	ascii <= 0x0F;
                endcase  
                case(ps2_code == 0x4D ) begin   
                	ascii <= 0x10;
                endcase 
                case(ps2_code == 0x15 ) begin   
               		ascii <= 0x11;
               	endcase 
                case(ps2_code == 0x2D ) begin  	
                	ascii <= 0x12;
                endcase 
                case(ps2_code == 0x1B ) begin   
                	ascii <= 0x13;
                endcase 
                case(ps2_code == 0x2C ) begin   
                	ascii <= 0x14;
                endcase  
                case(ps2_code == 0x3C ) begin   
                	ascii <= 0x15;
                endcase  
                case(ps2_code == 0x2A ) begin   
                	ascii <= 0x16;
                endcase  
                case(ps2_code == 0x1D ) begin   
                	ascii <= 0x17;
                endcase 
                case(ps2_code == 0x22 ) begin   
               		ascii <= 0x18;
               	endcase 
                case(ps2_code == 0x35 ) begin   
                	ascii <= 0x19;
                endcase  
                case(ps2_code == 0x1A ) begin   
                	ascii <= 0x1A;
                endcase  
                case(ps2_code == 0x54 ) begin   
                	ascii <= 0x1B;
                endcase  
                case(ps2_code == 0x5D ) begin   
                	ascii <= 0x1C; 
                case(ps2_code == 0x5B ) begin   
               		ascii <= 0x1D 
               	endcase
                case(ps2_code == 0x36 ) begin   
                	ascii <= 0x1E 
                endcase
                case(ps2_code == 0x4E ) begin   
                	ascii <= 0x1F 
                endcase
                case(ps2_code == 0x4A ) begin   
                	ascii <= 0x7F
                endcase
                /* should have default??  */

			end else begin
				case (ps2_code ==  0x29 ) begin ascii <= 0x20; endcase
                case (ps2_code ==  0x66 ) begin ascii <= 0x08; endcase
                case (ps2_code ==  0x0D ) begin ascii <= 0x09; endcase
                case (ps2_code ==  0x5A ) begin ascii <= 0x0D; endcase
                case (ps2_code ==  0x76 ) begin ascii <= 0x1B; endcase
                case (ps2_code ==  0x71 ) begin 
                	if(e0_code == '1) begin      
     					ascii <= 0x7F;             
                  	end
                endcase
                /* should have defualt?? */

                if( (shift_r == '0 && shift_l == '0 && caps_lock == '0) 
                		|| ((shift_r == '1 || shift_l == '1) 
                		&& caps_lock == '1) ) begin
                	case (ps2_code ==  0x1C) ascii <= 0x61; endcase
					case (ps2_code ==  0x32) ascii <= 0x62; endcase
					case (ps2_code ==  0x21) ascii <= 0x63; endcase
					case (ps2_code ==  0x23) ascii <= 0x64; endcase
					case (ps2_code ==  0x24) ascii <= 0x65; endcase
					case (ps2_code ==  0x2B) ascii <= 0x66; endcase
					case (ps2_code ==  0x34) ascii <= 0x67; endcase
					case (ps2_code ==  0x33) ascii <= 0x68; endcase
					case (ps2_code ==  0x43) ascii <= 0x69; endcase
					case (ps2_code ==  0x3B) ascii <= 0x6A; endcase
					case (ps2_code ==  0x42) ascii <= 0x6B; endcase
					case (ps2_code ==  0x4B) ascii <= 0x6C; endcase
					case (ps2_code ==  0x3A) ascii <= 0x6D; endcase
					case (ps2_code ==  0x31) ascii <= 0x6E; endcase
					case (ps2_code ==  0x44) ascii <= 0x6F; endcase
					case (ps2_code ==  0x4D) ascii <= 0x70; endcase
					case (ps2_code ==  0x15) ascii <= 0x71; endcase
					case (ps2_code ==  0x2D) ascii <= 0x72; endcase
					case (ps2_code ==  0x1B) ascii <= 0x73; endcase
					case (ps2_code ==  0x2C) ascii <= 0x74; endcase
					case (ps2_code ==  0x3C) ascii <= 0x75; endcase
					case (ps2_code ==  0x2A) ascii <= 0x76; endcase
					case (ps2_code ==  0x1D) ascii <= 0x77; endcase
					case (ps2_code ==  0x22) ascii <= 0x78; endcase
					case (ps2_code ==  0x35) ascii <= 0x79; endcase
					case (ps2_code ==  0x1A) ascii <= 0x7A; endcase
                end else begin
                	case (ps2_code ==  0x1C) ascii <= 0x41; endcase
					case (ps2_code ==  0x32) ascii <= 0x42; endcase
					case (ps2_code ==  0x21) ascii <= 0x43; endcase
					case (ps2_code ==  0x23) ascii <= 0x44; endcase
					case (ps2_code ==  0x24) ascii <= 0x45; endcase
					case (ps2_code ==  0x2B) ascii <= 0x46; endcase
					case (ps2_code ==  0x34) ascii <= 0x47; endcase
					case (ps2_code ==  0x33) ascii <= 0x48; endcase
					case (ps2_code ==  0x43) ascii <= 0x49; endcase
					case (ps2_code ==  0x3B) ascii <= 0x4A; endcase
					case (ps2_code ==  0x42) ascii <= 0x4B; endcase
					case (ps2_code ==  0x4B) ascii <= 0x4C; endcase
					case (ps2_code ==  0x3A) ascii <= 0x4D; endcase
					case (ps2_code ==  0x31) ascii <= 0x4E; endcase
					case (ps2_code ==  0x44) ascii <= 0x4F; endcase
					case (ps2_code ==  0x4D) ascii <= 0x50; endcase
					case (ps2_code ==  0x15) ascii <= 0x51; endcase
					case (ps2_code ==  0x2D) ascii <= 0x52; endcase
					case (ps2_code ==  0x1B) ascii <= 0x53; endcase
					case (ps2_code ==  0x2C) ascii <= 0x54; endcase 
					case (ps2_code ==  0x3C) ascii <= 0x55; endcase 
					case (ps2_code ==  0x2A) ascii <= 0x56; endcase 
					case (ps2_code ==  0x1D) ascii <= 0x57; endcase
					case (ps2_code ==  0x22) ascii <= 0x58; endcase
					case (ps2_code ==  0x35) ascii <= 0x59; endcase
					case (ps2_code ==  0x1A) ascii <= 0x5A; endcase
                end

                if(shift_l == '1 || shift_r == '1) begin
                	case (ps2_code ==  0x16) ascii <= 0x21; endcase
					case (ps2_code ==  0x52) ascii <= 0x22; endcase
					case (ps2_code ==  0x26) ascii <= 0x23; endcase
					case (ps2_code ==  0x25) ascii <= 0x24; endcase
					case (ps2_code ==  0x2E) ascii <= 0x25; endcase
					case (ps2_code ==  0x3D) ascii <= 0x26; endcase              
					case (ps2_code ==  0x46) ascii <= 0x28; endcase
					case (ps2_code ==  0x45) ascii <= 0x29; endcase
					case (ps2_code ==  0x3E) ascii <= 0x2A; endcase
					case (ps2_code ==  0x55) ascii <= 0x2B; endcase
					case (ps2_code ==  0x4C) ascii <= 0x3A; endcase
					case (ps2_code ==  0x41) ascii <= 0x3C; endcase
					case (ps2_code ==  0x49) ascii <= 0x3E; endcase
					case (ps2_code ==  0x4A) ascii <= 0x3F; endcase
					case (ps2_code ==  0x1E) ascii <= 0x40; endcase
					case (ps2_code ==  0x36) ascii <= 0x5E; endcase
					case (ps2_code ==  0x4E) ascii <= 0x5F; endcase
					case (ps2_code ==  0x54) ascii <= 0x7B; endcase
					case (ps2_code ==  0x5D) ascii <= 0x7C; endcase
					case (ps2_code ==  0x5B) ascii <= 0x7D; endcase
					case (ps2_code ==  0x0E) ascii <= 0x7E; endcase
                end else begin
                	case (ps2_code ==  0x45) ascii <= 0x30; endcase
					case (ps2_code ==  0x16) ascii <= 0x31; endcase
					case (ps2_code ==  0x1E) ascii <= 0x32; endcase
					case (ps2_code ==  0x26) ascii <= 0x33; endcase
					case (ps2_code ==  0x25) ascii <= 0x34; endcase
					case (ps2_code ==  0x2E) ascii <= 0x35; endcase
					case (ps2_code ==  0x36) ascii <= 0x36; endcase
					case (ps2_code ==  0x3D) ascii <= 0x37; endcase
					case (ps2_code ==  0x3E) ascii <= 0x38; endcase
					case (ps2_code ==  0x46) ascii <= 0x39; endcase
					case (ps2_code ==  0x52) ascii <= 0x27; endcase
					case (ps2_code ==  0x41) ascii <= 0x2C; endcase
					case (ps2_code ==  0x4E) ascii <= 0x2D; endcase
					case (ps2_code ==  0x49) ascii <= 0x2E; endcase
					case (ps2_code ==  0x4A) ascii <= 0x2F; endcase
					case (ps2_code ==  0x4C) ascii <= 0x3B; endcase
					case (ps2_code ==  0x55) ascii <= 0x3D; endcase
					case (ps2_code ==  0x54) ascii <= 0x5B; endcase
					case (ps2_code ==  0x5D) ascii <= 0x5C; endcase
					case (ps2_code ==  0x5B) ascii <= 0x5D; endcase
					case (ps2_code ==  0x0E) ascii <= 0x60; endcase
                end
			end

			if(break == '0) begin
				state <= output;
			end else begin
				state <= ready; 
			end
		endcase

		case (state == output)
			if(ascii[7] == '0) begin
				ascii_new <= '1;
				ascii_code <= ascii;				/* ToDo: should this be ascii_code <= ascii[6:0]?? */
			end
			state <= ready; 						/* return to ready state to await next PS2 code*/ 
		endcase
	end


end

endmodule 

