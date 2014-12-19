'timescale 1ns/1ns

module ps2_converter(
	clk, ps2_clk, rst, 
	ps2_data_i, ascii_new_o, ascii_code_o,
	ps2_code_new_o, ps2_code_o
);

/* Inputs */
input clk, ps2_clk;
input rst;
input ps2_data_i; 								/* data signal from PS2 keyboard */

/* Outputs */
output ascii_new_o, ascii_code_o;
output ps2_code_new_o;							/* flag that new PS/2 code is available on ps2_code bus */
output [7:0] ps2_code_o; 							/* PS2 code input form ps2_keyboard component */

/* Variables */
logic clk_freq = 0x50000000;
logic ps2_debounce_counter_size = 0x8;

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
logic [7:0] ascii 								/* internal value of ASCII translation, init: 0xFF */

/* States */
logic ready;									/* state */
logic new_code;									/* state */
logic translate;								/* state */	
logic output;									/* state */
logic state;									/* state machine */
logic init; 


/* Behavior */
always_ff @(posedge clk) begin

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

		case (state == ready)

		endcase

		case (state == new_code)
			
		endcase

		case (state == translate)
			
		endcase

		case (state == output)
			if(ascii[7] == '0) begin
				ascii_new <= '1;
				ascii_code <= ascii[];
			end
			state <= ready; 						/* return to ready state to await next PS2 code*/ 
		endcase
	end


end

endmodule 

