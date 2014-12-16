`timescale 1ns/1ns

module aes_kb(
	clk, rst, stall,
	in_buf, kb, start,
	key, valid, done
);
	input clk, rst, stall;
	input [383:0] in_buf; //stuff to decrypt 
	input [447:0] kb; //md5 to make key
	input start;
	output [127:0] key; //output valid AES key
	output valid, done;


	/* wires to md5 module */
	logic md5_start; //md5.start
	logic md5_done; //md5.done
	logic [31:0] md5_data; //md5.writedata
	logic [3:0] md5_wa; //md5.writeaddr
	logic md5_w; //md5.write


	/* wires to aes module */
	logic [127:0] aes_key;
	logic [127:0] data;
	logic [127:0] aes_key_d;


	//kb is 448 bits, need to append 1000...000 to it
	logic [511:0] kbd; 
	assign kbd = {64'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000, kb};

	md5 md5_inst(.writeaddr(md5_wa), .writedata(md5_data),.write(md5_w),
		.start(md5_start),.done(md5_done),.digest0(aes_key),*);
	aes aes_inst(.aes_in(data), .key(aes_key), .data_out(aes_key_d), .*;


	/* when start goes high, run the AES decryption
	 * when done, raise the output done signal
	 * if valid, also raise valid, otherwise dont
	 */

	 integer count; //counts time to process md5/aes
    /* AES takes 38 cycles */

    always_ff @(posedge clk) begin
    	if(rst) begin

    	end else begin
    		/* feed md5 data to md5 unit, wait for done */

    		/* when md5 done, put in AES and run for 38 cycles */

    		/* after 38 cycles, compare to expected */
    	end
    end


endmodule
