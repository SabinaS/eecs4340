`timescale 1ns/1ns

module aes_kb(
	clk, rst, stall,
	in_buf, kb, start,
	key, valid, done
);
    input clk, rst, stall;
    input [127:0] in_buf; //encrypted md5 hash
    input [447:0] kb; //md5 to make key
    input start;
    output logic [127:0] key; //output valid AES key
    output logic valid, done;


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

    logic [127:0] encrypted_hash;
    logic [127:0] hash;

    //kb is 448 bits, need to append 1000...000 to it
    logic [32:0] kbd [0:15];


    /* endianness ???? TODO */
    assign kbd[15] = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
    assign kbd[14] = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    assign kbd[13] = kb[447:416];
    assign kbd[12] = kb[415:384];
    assign kbd[11] = kb[383:352];
    assign kbd[10] = kb[351:320];
    assign kbd[9] = kb[319:288];
    assign kbd[8] = kb[287:256];
    assign kbd[7] = kb[255:224];
    assign kbd[6] = kb[223:192];
    assign kbd[5] = kb[191:160];
    assign kbd[4] = kb[159:128];
    assign kbd[3] = kb[127:96];
    assign kbd[2] = kb[95:64];
    assign kbd[1] = kb[63:32];
    assign kbd[0] = kb[31:0];


    md5 md5_inst(.writeaddr(md5_wa), .writedata(md5_data),.write(md5_w),
    	.start(md5_start),.done(md5_done),.digest0(aes_key),.reset(rst),.*);
    aes aes_inst(.aes_in(data), .key(aes_key), .data_out(aes_key_d), .*);


    /* when start goes high, run the AES decryption
     * when done, raise the output done signal
     * if valid, also raise valid, otherwise dont
     */

     integer count; //counts time to process md5/aes


    /* AES takes 38 cycles */

    logic [1:0] state; 
    /*  0: waiting
		1: run md5
		2: run aes
		3: check 
	*/
 

    always_ff @(posedge clk) begin
    	if(rst) begin
    		state <= 2'b00;
    		count <= 0;
    		md5_start <= 1'b0;
    		md5_wa <= 'b0;
    		md5_data <= 'b0;
    		md5_w <= 1'b0;
    		valid <= 1'b0;
    		done <= 1'b0;
                        data<='b0;
                        hash <= 'b0;
                        encrypted_hash<='b0;
    	end else if(!stall) begin
    		case(state)
    			2'b00: begin
    				if(start) begin
    					state <= 2'b01;
    					count <= 0;
                                                            encrypted_hash <= in_buf;
    				end else begin
    					/* do nothing */
    					done <= 1'b0;
    					valid <= 1'b0;
    				end
    			end

    			2'b01: begin /* feed md5 data to md5 unit, wait for done */
    				if(md5_done) begin
    					state <= 2'b10;
    					count <= 0;
                                                            hash <= aes_key;
                                                            data <= encrypted_hash;
    				end else begin
    					if(count==16) begin
	    					/* wait until done */
	    					if(md5_done) begin //start counting, valid data
	    							        //was just put on AES
	    						state <= 2'b10;
	    						count <= 0; //TODO should this be 1? 
	    					end
    					end else begin
    						/* push data into md5 */
						md5_wa <= count[3:0];
						md5_data <= kbd[count];
						md5_w <= 1'b1;
						count <= count + 1;
    					end
    				end
    			end

    			2'b10: begin /* when md5 done, put in AES and run for 38 cycles */
    				if(count==38) begin
    					state <= 2'b11;
    					count <= 0;
    				end else begin
    					/* wait until done */
    					count <= count + 1;
    				end
    			end

    			2'b11: begin /* after 38 cycles, compare to expected */
    				/* make comparison */


    				/* TODO output key if valid */
    				if(hash == aes_key_d) begin //correct key
    					valid <= 1'b1;
    				end else begin //incorrect key
    					valid <= 1'b0;
    				end
    				done <= 1'b1;
    				state <= 2'b00;
    			end
	    	endcase
    	end
    end


endmodule
