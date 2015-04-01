`timescale 1ns/1ns

`include "fat_defines.sv"
`include "../spi/defines.sv"

module fat_core (
   clk, rst,
   read_i, write_i, spi_read_o, spi_write_o,
   ready_o, ready_i, valid_o, valid_i,
   bus_io, aes_i, aes_o,
   fname_i, fext_i, fname_o, fext_o
);

   input clk, rst;
   // read_i: read the next fat file
   // write_i: write the given file name and data being sent
   input read_i, write_i;
   // ready_i: the upstream module accepted the data on the bus
   // valid_i: the upstream module has sent valid data on the bus
   input ready_i, valid_i;
   // fname_i: the file name of 8.3 format
   // fext_i: the file extension of 8.3 format
   input [`CHF_NAME_SIZE-1:0] fname_i;
   input [`CHF_EXT_SIZE-1:0] fext_i;
   // aes_i: data from the AES module to write to the SD card
   input [`AES_DAT_SIZE-1:0] aes_i;
   
   // spi_read_o: initiate a read to the card
   // spi_write_o: initiate a write to the card
   output logic spi_read_o, spi_write_o;
   // ready_o: I can accept data to write
   // valid_o: I have read data to give you
   output logic ready_o, valid_o;
   // ditto
   output logic [`CHF_NAME_SIZE-1:0] fname_o;
   output logic [`CHF_EXT_SIZE-1:0] fext_o;
   // aes_o: data from the SD card to the AES modules
   output logic [`AES_DAT_SIZE-1:0] aes_o;
   
   // Communicating with the SD card
   inout [`BUS_WIDTH-1:0] bus_io;
   
   // Communicating with the SD card again
   logic do_io;
   logic [`BUS_WIDTH-1:0] bus_dat;
   
   // Single block SD cache
   logic [`SD_BLOCK_SIZE-1:0] spi_buf;
   // Single block FAT32 cache
   reg[7:0] block[`MAX_BLOCK_SIZE-1:0];
   logic [`MAX_BLOCK_SIZE_WIDTH-1:0] block_count;
   
   enum {READ_BS} init;
   
   always_ff @(posedge clk) begin
      if (rst) begin
         do_io <= '0;
         bus_dat <= '0;
         
         spi_read_o <= '0;
         spi_write_o <= '0;
         ready_o <= '0;
         valid_o <= '0;
         fname_o <= '0;
         fext_o <= '0;
         aes_o <= '0;
         
         block_count <= '0;
         init <= READ_BS;
      end
      else begin
      end
   end

   // Combinational logic
   assign bus_io = do_io ? bus_dat : 'z;
   
endmodule
