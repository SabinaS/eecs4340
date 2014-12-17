'timescale 1ns/1ns

module ps2_top (
	clk, rst,
	done_o, rst_o, data_o, valid_o,
	ps2_clk, stall

);

/* Inputs */
/* ps2_clk is the PS2 clock for the keyboard.
 * stall is the Stall from the File System out.
 * rst and clk are the global signals.
 */
input clk, ps2_clk, rst, stall;

/* Outputs */
/* data_o is the 8 bit data from the keyboard.
 * valid_o is the singal ensuring our character is valid.
 * done_o signifies to process the user passphrase.
 * rst_o signifies to reset the keyboard buffer.
 */
output [7:0] data_o;
output valid_o;
output done_o, rst_o; 

/* State Registers */
logic count;
logic[7:0] data; 
logic init, shift, outpt, convert; 

/* Behavior */
always_ff @(posedge clk) begin

	/* Reset */
	if (rst) begin
		/* ToDo */
		done_o <= '0;
		rst_o <= '0;
		valid_o <= '0;
		data_o <= '0;
		
		init <= '1;
		shift <= '0;
		outpt <= '0;
		convert <= '0; 
	end 
	
	/* Initialization */
	if (init) begin
		/* ToDo */
		wait();
	end 
	if (shift) begin
		/* ToDo */
		data[count] = dat;
		count = count + '1;
	end
	
	 
end

endmodule
