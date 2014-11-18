`timescale 1ns/1ns
// Multimedia File Encryption (Top Level)
module mfe (mfe_ifc.dut d);
	/*clk, rst, status_leds, dat_spi_card_o, dat_spi_card_i,
            key_spi_card_o, key_spi_card_i, out_spi_card_o, out_spi_card_i, ps2_dat);*/

    // MFE original communication
    /*input               d.clk, d.rst;
    // 0 = Passphrase Accept | 1 = Passphrase fail | 2 = On | 3 = Ready | 4 =
    // Processing | 5 = Overall Success | 6 = Overall failure
    output wire [6:0]   d.status_leds;

    // SPI interface: 0 = SCLK, 1 = MOSI, 2 = SS are outputs of the master (us),
    // MISO is an input of the master (output of the slave)
    logic               d.spi_clk;
    output [2:0]        d.dat_spi_card_o;
    input               d.dat_spi_card_i;
    output [2:0]        d.key_spi_card_o;
    input               d.key_spi_card_i;
    output [2:0]        d.out_spi_card_o;
    input               d.out_spi_card_i;
    
    // PS/2 interface
    logic               d.ps2_clk;
    input               d.ps2_dat;
    */
    // The spi clk is bundled with the SPI communication array
    assign d.dat_spi_card_o[0] = d.spi_clk;
    assign d.key_spi_card_o[0] = d.spi_clk;
    assign d.out_spi_card_o[0] = d.spi_clk;

    // The file system wires follow exactly the same format
    // The dat_fs wires
    // The data from the SD card
    wire [31:0]         dat_in;
    // Information about data from the SD card, except for dat_in_ready, which
    // is an input to the FS from the consumer indicating that in the next
    // cycle, it cannot accept more input
    wire                dat_in_eof, dat_in_valid, dat_in_ready;
    // The data to the SD card
    wire [31:0]         dat_out;
    // Information about data to the sd card
    wire                dat_out_ready, dat_out_valid, dat_out_eof;
    // Command wires
    wire                dat_read, dat_write, dat_write_counter;
    // Command status (if it's currently reading or writing to the SD card)
    wire                dat_reading, dat_writing;
    // The key_fs wires
    wire [31:0]         key_in;
    wire                key_in_eof, key_in_valid, key_in_ready;
    wire [31:0]         key_out;
    wire                key_out_ready, key_out_valid, key_out_eof;
    wire                key_read, key_write, key_write_counter;
    wire                key_reading, key_writing;
    // The out_fs wires
    wire [31:0]         out_in;
    wire                out_in_eof, out_in_valid, out_in_ready;
    wire [31:0]         out_out;
    wire                out_out_ready, out_out_valid, out_out_eof;
    wire                out_read, out_write, out_write_counter;
    wire                out_reading, out_writing;
    wire                out_led_done;
    
    // RSA wires
    wire led_pass_o, led_fail_o;
    

    // AES wires
    wire led_proc_o;
    
    // The PS/2 module wires (a small set for communication)
    wire [15:0]         key_char_out;
    wire                key_char_out_valid;
    
    // The status led logics, for the two combinational inputs
    logic               stat_ready, stat_done_failed;
    
    file_system dat_fs  (.to_slave_o(d.dat_spi_card_o),
                         .from_slave_i(d.dat_spi_card_i), .data_i(dat_out),
                         .valid_i(dat_out_valid), .eof_i(dat_out_eof),
                         .ready_o(dat_out_ready), .data_o(dat_in),
                         .valid_o(dat_in_valid), .eof_o(dat_in_eof),
                         .read_i(dat_read), .write_i(dat_write),
                         .write_counter_i(dat_write_counter),
                         .ready_i(dat_in_ready),
                         .writing_o(dat_writing),
                         .reading_o(dat_reading),
                         .clk(d.clk), .rst(d.rst), .led_done_o());
    file_system key_fs  (.to_slave_o(d.key_spi_card_o),
                         .from_slave_i(d.key_spi_card_i), .data_i(key_out),
                         .valid_i(key_out_valid), .eof_i(key_out_eof),
                         .ready_o(key_out_ready), .data_o(key_in),
                         .valid_o(key_in_valid), .eof_o(key_in_eof),
                         .read_i(key_read), .write_i(key_write),
                         .write_counter_i(key_write_counter),
                         .ready_i(key_in_ready),
                         .writing_o(key_writing),
                         .reading_o(key_reading),
                         .clk(d.clk), .rst(d.rst), .led_done_o());
    file_system out_fs  (.to_slave_o(d.out_spi_card_o),
                         .from_slave_i(d.out_spi_card_i), .data_i(out_out),
                         .valid_i(out_out_valid), .eof_i(out_out_eof),
                         .ready_o(out_out_ready), .data_o(out_in),
                         .valid_o(out_in_valid), .eof_o(out_in_eof),
                         .read_i(out_read), .write_i(out_write),
                         .ready_i(out_in_ready),
                         .write_counter_i(out_write_counter),
                         .writing_o(out_writing),
                         .reading_o(out_reading),
                         .led_done_o(out_led_done),
                         .clk(d.clk), .rst(d.rst));
    
    rsa_decryptor key_decrypt  (.key_valid_i(key_in_valid),
                                .dat_valid_i(dat_in_valid),
                                .ps2_valid_i(key_char_out_valid),
                                .key_i(key_in),
                                .dat_i(dat_in),
                                .ps2_i(key_char_out),
                                .dat_read_o(dat_in_ready),
                                .clk(d.clk), .rst(d.rst), .key_ready_o(),
                                .dat_ready_o(), .ps2_ready_o(), .key_read_o(),
                                .key_o(), .key_valid_o(),
                                .led_pass_o(led_pass_o),
                                .led_fail_o(led_fail_o));

    aes_decryptor file_decrypt (.dat_valid_i(dat_in_valid),
                                .dat_i(dat_in), .dat_ready_o(dat_in_ready),
                                .dat_o(out_out), .dat_valid_o(out_out_valid),
                                .out_ready_i(out_out_ready),
                                .out_write_o(out_write),
                                .out_eof_o(out_out_eof),
                                .out_write_counter_o(out_write_counter),
                                .led_proc_o(led_proc_o),
                                .key_i(), .key_valid_i(),
                                .clk(d.clk), .rst(d.rst));
    
    keyboard_driver keyboard (.char_o(key_char_out),
                             .char_valid_o(key_char_out_valid),
                             .clk(d.clk), .ps2_clk(d.ps2_clk),
                             .ps2_dat(d.ps2_dat));
    
    status_driver status   (.pass_failed_i(led_fail_o),
                            .pass_passed_i(led_pass_o),
                            .done_failed_i(stat_done_failed),
                            .done_passed_i(out_led_done),
                            .processing_i(led_proc_o),
                            .ready_i(stat_ready), .rst(d.rst),
									 .status_leds(d.status_leds));

endmodule
