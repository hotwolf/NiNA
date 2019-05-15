//###############################################################################
//# NiNA - Behavioral Model of the SB_RAM256x16 RAM Cell                        #
//###############################################################################
//#    Copyright 2018 - 2019 Dirk Heisswolf                                     #
//#    This file is part of the N1 project.                                     #
//#                                                                             #
//#    N1 is free software: you can redistribute it and/or modify               #
//#    it under the terms of the GNU General Public License as published by     #
//#    the Free Software Foundation, either version 3 of the License, or        #
//#    (at your option) any later version.                                      #
//#                                                                             #
//#    N1 is distributed in the hope that it will be useful,                    #
//#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
//#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
//#    GNU General Public License for more details.                             #
//#                                                                             #
//#    You should have received a copy of the GNU General Public License        #
//#    along with N1.  If not, see <http://www.gnu.org/licenses/>.              #
//###############################################################################
//# Description:                                                                #
//#    This is a behavioral model of the SB_RAM256x16 RAM Scell, which is       #
//#    available on all Lattice iCE40 FPGA devices. This model has been written #
//#    based on the public documentation from Lattice.                          #
//#                                                                             #
//###############################################################################
//# Version History:                                                            #
//#   May 15, 2019                                                              #
//#      - Initial release                                                      #
//###############################################################################
`default_nettype none

module SB_RAM256x16
  #(parameter INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x00 - 0x0F
    parameter INIT_1 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x10 - 0x1F
    parameter INIT_2 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x20 - 0x2F
    parameter INIT_3 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x30 - 0x3F
    parameter INIT_4 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x40 - 0x4F
    parameter INIT_5 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x50 - 0x5F
    parameter INIT_6 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x60 - 0x6F
    parameter INIT_7 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x70 - 0x7F
    parameter INIT_8 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x80 - 0x8F
    parameter INIT_9 = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0x90 - 0x9F
    parameter INIT_A = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0xA0 - 0xAF
    parameter INIT_B = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0xB0 - 0xBF
    parameter INIT_C = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0xC0 - 0xCF
    parameter INIT_D = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0xD0 - 0xDF
    parameter INIT_E = 256'h0000000000000000000000000000000000000000000000000000000000000000, //0xE0 - 0xEF
    parameter INIT_F = 256'h0000000000000000000000000000000000000000000000000000000000000000) //0xF0 - 0xFF
   (input  wire  [7:0]     RADDR,                                                             //read address
    input  wire            RCLK,                                                              //read clock
    input  wire            RCLKE,                                                             //read clock enable
    input  wire            RE,                                                                //read enable
    input  wire  [7:0]     WADDR,                                                             //write address
    input  wire            WCLK,                                                              //write clock
    input  wire            WCLKE,                                                             //write clock enable
    input  wire [15:0]     WDATA,                                                             //write data
    input  wire            WE,                                                                //write enable
    input  wire [15:0]     MASK,                                                              //write mask
    output reg  [15:0]     RDATA);                                                            //read data

   //Memory
   reg [15:0]              memory [255:0];

   //Memory initialization
   initial
     begin
        {memory[8'h0f], memory[8'h0e], memory[8'h0d], memory[8'h0c],                          //0x00 - 0x0F
         memory[8'h0b], memory[8'h0a], memory[8'h09], memory[8'h08],
         memory[8'h07], memory[8'h06], memory[8'h05], memory[8'h04],
         memory[8'h03], memory[8'h02], memory[8'h01], memory[8'h00]} = INIT_0;

        {memory[8'h1f], memory[8'h1e], memory[8'h1d], memory[8'h1c],                          //0x10 - 0x1F
         memory[8'h1b], memory[8'h1a], memory[8'h19], memory[8'h18],
         memory[8'h17], memory[8'h16], memory[8'h15], memory[8'h14],
         memory[8'h13], memory[8'h12], memory[8'h11], memory[8'h10]} = INIT_1;

        {memory[8'h2f], memory[8'h2e], memory[8'h2d], memory[8'h2c],                          //0x20 - 0x2F
         memory[8'h2b], memory[8'h2a], memory[8'h29], memory[8'h28],
         memory[8'h27], memory[8'h26], memory[8'h25], memory[8'h24],
         memory[8'h23], memory[8'h22], memory[8'h21], memory[8'h20]} = INIT_2;

        {memory[8'h3f], memory[8'h3e], memory[8'h3d], memory[8'h3c],                          //0x30 - 0x3F
         memory[8'h3b], memory[8'h3a], memory[8'h39], memory[8'h38],
         memory[8'h37], memory[8'h36], memory[8'h35], memory[8'h34],
         memory[8'h33], memory[8'h32], memory[8'h31], memory[8'h30]} = INIT_3;

        {memory[8'h4f], memory[8'h4e], memory[8'h4d], memory[8'h4c],                          //0x40 - 0x4F
         memory[8'h4b], memory[8'h4a], memory[8'h49], memory[8'h48],
         memory[8'h47], memory[8'h46], memory[8'h45], memory[8'h44],
         memory[8'h43], memory[8'h42], memory[8'h41], memory[8'h40]} = INIT_4;

        {memory[8'h5f], memory[8'h5e], memory[8'h5d], memory[8'h5c],                          //0x50 - 0x5F
         memory[8'h5b], memory[8'h5a], memory[8'h59], memory[8'h58],
         memory[8'h57], memory[8'h56], memory[8'h55], memory[8'h54],
         memory[8'h53], memory[8'h52], memory[8'h51], memory[8'h50]} = INIT_5;

        {memory[8'h6f], memory[8'h6e], memory[8'h6d], memory[8'h6c],                          //0x60 - 0x6F
         memory[8'h6b], memory[8'h6a], memory[8'h69], memory[8'h68],
         memory[8'h67], memory[8'h66], memory[8'h65], memory[8'h64],
         memory[8'h63], memory[8'h62], memory[8'h61], memory[8'h60]} = INIT_6;

        {memory[8'h7f], memory[8'h7e], memory[8'h7d], memory[8'h7c],                          //0x70 - 0x7F
         memory[8'h7b], memory[8'h7a], memory[8'h79], memory[8'h78],
         memory[8'h77], memory[8'h76], memory[8'h75], memory[8'h74],
         memory[8'h73], memory[8'h72], memory[8'h71], memory[8'h70]} = INIT_7;

        {memory[8'h8f], memory[8'h8e], memory[8'h8d], memory[8'h8c],                          //0x80 - 0x8F
         memory[8'h8b], memory[8'h8a], memory[8'h89], memory[8'h88],
         memory[8'h87], memory[8'h86], memory[8'h85], memory[8'h84],
         memory[8'h83], memory[8'h82], memory[8'h81], memory[8'h80]} = INIT_8;

        {memory[8'h9f], memory[8'h9e], memory[8'h9d], memory[8'h9c],                          //0x90 - 0x9F
         memory[8'h9b], memory[8'h9a], memory[8'h99], memory[8'h98],
         memory[8'h97], memory[8'h96], memory[8'h95], memory[8'h94],
         memory[8'h93], memory[8'h92], memory[8'h91], memory[8'h90]} = INIT_9;

        {memory[8'haf], memory[8'hae], memory[8'had], memory[8'hac],                          //0xA0 - 0xAF
         memory[8'hab], memory[8'haa], memory[8'ha9], memory[8'ha8],
         memory[8'ha7], memory[8'ha6], memory[8'ha5], memory[8'ha4],
         memory[8'ha3], memory[8'ha2], memory[8'ha1], memory[8'ha0]} = INIT_A;

        {memory[8'hbf], memory[8'hbe], memory[8'hbd], memory[8'hbc],                          //0xB0 - 0xBF
         memory[8'hbb], memory[8'hba], memory[8'hb9], memory[8'hb8],
         memory[8'hb7], memory[8'hb6], memory[8'hb5], memory[8'hb4],
         memory[8'hb3], memory[8'hb2], memory[8'hb1], memory[8'hb0]} = INIT_B;

        {memory[8'hcf], memory[8'hce], memory[8'hcd], memory[8'hcc],                          //0xC0 - 0xCF
         memory[8'hcb], memory[8'hca], memory[8'hc9], memory[8'hc8],
         memory[8'hc7], memory[8'hc6], memory[8'hc5], memory[8'hc4],
         memory[8'hc3], memory[8'hc2], memory[8'hc1], memory[8'hc0]} = INIT_C;

        {memory[8'hdf], memory[8'hde], memory[8'hdd], memory[8'hdc],                          //0xD0 - 0xDF
         memory[8'hdb], memory[8'hda], memory[8'hd9], memory[8'hd8],
         memory[8'hd7], memory[8'hd6], memory[8'hd5], memory[8'hd4],
         memory[8'hd3], memory[8'hd2], memory[8'hd1], memory[8'hd0]} = INIT_D;

        {memory[8'hef], memory[8'hee], memory[8'hed], memory[8'hec],                          //0xE0 - 0xEF
         memory[8'heb], memory[8'hea], memory[8'he9], memory[8'he8],
         memory[8'he7], memory[8'he6], memory[8'he5], memory[8'he4],
         memory[8'he3], memory[8'he2], memory[8'he1], memory[8'he0]} = INIT_E;

        {memory[8'hff], memory[8'hfe], memory[8'hfd], memory[8'hfc],                          //0xF0 - 0xFF
         memory[8'hfb], memory[8'hfa], memory[8'hf9], memory[8'hf8],
         memory[8'hf7], memory[8'hf6], memory[8'hf5], memory[8'hf4],
         memory[8'hf3], memory[8'hf2], memory[8'hf1], memory[8'hf0]} = INIT_F;

     end // initial begin

   //Write access
   always @(posedge WCLK)
     if (WCLKE & WE)
       memory[WADDR] <= (MASK & memory[WADDR]) | (~MASK & WDATA);

   //Read access
   always @(posedge RCLK)
     if (RCLKE & RE)
       RDATA <= memory[RADDR];

endmodule // SB_RAM256x16
