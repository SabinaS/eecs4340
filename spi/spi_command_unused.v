`timescale 1ns/1ns
module spi_command (
    clk, sclk_pos_edge, rst,
    mosi, miso,
    do_command_i, command_i, command_len_i,
    dat_i, dat_valid_i, input_active,
    dat_o, dat_valid_o, output_active,
);

// Sending out commands
parameter COMMAND_WIDTH = 6 * 8;
parameter INTERNAL_DAT_WIDTH = 8;

parameter BUF_SIZE = INTERNAL_DAT_WIDTH;

parameter COMMAND_LEN_WIDTH = $clog2(COMMAND_WIDTH + 1);
parameter BUF_POS_WIDTH = $clog2(BUF_SIZE);

// Synchronous signals
input clk, sclk_pos_edge, rst;

// SPI interface
input miso;
output mosi;

// spi_ module communication
input do_command_i;
input [COMMAND_WIDTH-1:0] command_i;
input [COMMAND_LEN_WIDTH-1:0] command_len_i;
input [INTERNAL_DAT_WIDTH-1:0] dat_i;
input dat_valid_i;
output [INTERNAL_DAT_WIDTH-1:0] dat_o;
output dat_valid_o;

// For sending out commmands
logic [COMMAND_WIDTH-1:0] command;
logic [COMMAND_LEN_WIDTH-1:0] command_len;
logic [COMMAND_WIDTH-1:0] command_shift_position;

// For holding data to read/write
logic [BUF_SIZE-1:0] buffer;
logic [BUF_POS_WIDTH-1:0] buffer_pos;

enum {
	IDLE,
	COMMAND_RECV,
	AWAIING_RSP
} state;

always_ff @(posedge clk) begin
	if(rst) begin
		// Set all outputs to zero
		dat_o <= '0;
		dat_valid_o <= '0;
		// Except for MOSI
		mosi <= '1;

		// Zero all registers
		command <= '0;
		command_shift_position <= '0;
		buffer <= '0;
		buffer_pos <= '0;

		// Initialize state
		state <= IDLE;
	end else begin
		case (state)
			IDLE : begin
				// Reset all outputs
				dat_o <= '0;
				dat_valid_o <= '0;
				mosi <= '1;
				buffer <= '0;
				buffer_pos <= '0;
				// As well as logic states
				command_shift_position <= '0;

				// Check for a command
				state <= do_command_i ? COMMAND_RECV : IDLE;
				command <= do_command_i ? command_i : command;
			end
			// We received a command. Shift it out
			COMMAND_RECV : begin
				mosi <= command[COMMAND_WIDTH-1];
				command <= command << 1;
				command_shift_position <= command_shift_position + 1'b1;

				state <= command_shift_position == COMMAND_WIDTH - 1 ? AWAIING_RSP : COMMAND_RECV;
			end
		endcase
	end
end

endmodule
