`timescale 1ns/1ns
module status_driver(
	input rst,

	input done_failed_i,
	input done_passed_i,
	input pass_failed_i,
	input pass_passed_i,
	input processing_i,
	input ready_i,

	output [6:0] status_leds
);

endmodule
