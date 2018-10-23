//###############################################################################
//# WbXbc - Wishbone Crossbar Components - Bus Splitter                         #
//###############################################################################
//#    Copyright 2018 Dirk Heisswolf                                            #
//#    This file is part of the WbXbc project.                                  #
//#                                                                             #
//#    WbXbc is free software: you can redistribute it and/or modify            #
//#    it under the terms of the GNU General Public License as published by     #
//#    the Free Software Foundation, either version 3 of the License, or        #
//#    (at your option) any later version.                                      #
//#                                                                             #
//#    WbXbc is distributed in the hope that it will be useful,                 #
//#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
//#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
//#    GNU General Public License for more details.                             #
//#                                                                             #
//#    You should have received a copy of the GNU General Public License        #
//#    along with WbXbc.  If not, see <http://www.gnu.org/licenses/>.           #
//###############################################################################
//# Description:                                                                #
//#    This module implements a bus splitter for the pipelined Wishbone         #
//#    protocol. Accesses from the initiator bus are propagated to one of the   #
//#    target busses. The target busses are selected by a set of address tags,  #
//#    generated by the address decoder.                                        #
//#                                                                             #
//#                            +-------------------+                            #
//#                            |                   |--->                        #
//#               single       |                   |                            #
//#              initiator     |      WbXbc        |--->  multiple              #
//#                 bus    --->|     splitter      |       target               #
//#                with        |                   | ...   busses               #
//#              selects       |                   |                            #
//#                            |                   |--->                        #
//#                            +-------------------+                            #
//#                                                                             #
//###############################################################################
//# Version History:                                                            #
//#   July 18, 2018                                                             #
//#      - Initial release                                                      #
//#   October 8, 2018                                                           #
//#      - Updated parameter and signal naming                                  #
//###############################################################################
`default_nettype none

module WbXbc_splitter
  #(parameter TGT_CNT     = 4,   //number of target busses
    parameter ADR_WIDTH   = 16,  //width of the address bus
    parameter DAT_WIDTH   = 16,  //width of each data bus
    parameter SEL_WIDTH   = 2,   //number of data select lines
    parameter TGA_WIDTH   = 1,   //number of propagated address tags
    parameter TGC_WIDTH   = 1,   //number of propagated cycle tags
    parameter TGRD_WIDTH  = 1,   //number of propagated read data tags
    parameter TGWD_WIDTH  = 1)   //number of propagated write data tags

   (//Clock and reset
    //---------------
    input wire                             clk_i,            //module clock
    input wire                             async_rst_i,      //asynchronous reset
    input wire                             sync_rst_i,       //synchronous reset

    //Initiator interface
    //-------------------
    input  wire                            itr_cyc_i,        //bus cycle indicator       +-
    input  wire                            itr_stb_i,        //access request            |
    input  wire                            itr_we_i,         //write enable              |
    input  wire                            itr_lock_i,       //uninterruptable bus cycle |
    input  wire [SEL_WIDTH-1:0]            itr_sel_i,        //write data selects        | initiator
    input  wire [ADR_WIDTH-1:0]            itr_adr_i,        //address bus               | to
    input  wire [DAT_WIDTH-1:0]            itr_dat_i,        //write data bus            | target
    input  wire [TGA_WIDTH-1:0]            itr_tga_i,        //generic address tags      |
    input  wire [TGT_CNT-1:0]              itr_tga_tgtsel_i, //tags from address decoder |
    input  wire [TGC_WIDTH-1:0]            itr_tgc_i,        //bus cycle tags            |
    input  wire [TGWD_WIDTH-1:0]           itr_tgd_i,        //write data tags           +-
    output wire                            itr_ack_o,        //bus cycle acknowledge     +-
    output wire                            itr_err_o,        //error indicator           | target
    output wire                            itr_rty_o,        //retry request             | to
    output wire                            itr_stall_o,      //access delay              | initiator
    output reg  [DAT_WIDTH-1:0]            itr_dat_o,        //read data bus             |
    output reg  [TGRD_WIDTH-1:0]           itr_tgd_o,        //read data tags            +-

    //Target interfaces
    //-----------------
    output wire [TGT_CNT-1:0]              tgt_cyc_o,        //bus cycle indicator       +-
    output wire [TGT_CNT-1:0]              tgt_stb_o,        //access request            |
    output wire [TGT_CNT-1:0]              tgt_we_o,         //write enable              |
    output wire [TGT_CNT-1:0]              tgt_lock_o,       //uninterruptable bus cycle | initiator
    output wire [(TGT_CNT*SEL_WIDTH)-1:0]  tgt_sel_o,        //write data selects        | to
    output wire [(TGT_CNT*ADR_WIDTH)-1:0]  tgt_adr_o,        //address bus               | target
    output wire [(TGT_CNT*DAT_WIDTH)-1:0]  tgt_dat_o,        //write data bus            |
    output wire [(TGT_CNT*TGA_WIDTH)-1:0]  tgt_tga_o,        //propagated address tags   |
    output wire [(TGT_CNT*TGC_WIDTH)-1:0]  tgt_tgc_o,        //bus cycle tags            |
    output wire [(TGT_CNT*TGWD_WIDTH)-1:0] tgt_tgd_o,        //write data tags           +-
    input  wire [TGT_CNT-1:0]              tgt_ack_i,        //bus cycle acknowledge     +-
    input  wire [TGT_CNT-1:0]              tgt_err_i,        //error indicator           | target
    input  wire [TGT_CNT-1:0]              tgt_rty_i,        //retry request             | to
    input  wire [TGT_CNT-1:0]              tgt_stall_i,      //access delay              | initiator
    input  wire [(TGT_CNT*DAT_WIDTH)-1:0]  tgt_dat_i,        //read data bus             |
    input  wire [(TGT_CNT*TGRD_WIDTH)-1:0] tgt_tgd_i);       //read data tags            +-

   //Internal signals
   wire [TGT_CNT-1:0]                      new_tgt = itr_tga_tgtsel_i & {TGT_CNT{itr_stb_i}}; //one-hot coded target bus tracker

   //Internal registers
   reg  [TGT_CNT-1:0]                      cur_tgt_reg;                                       //one-hot coded target bus tracker

   //Counters
   integer            i, j;

   //Target bus tracker
   always @(posedge async_rst_i or posedge clk_i)
     if (async_rst_i)                                        //asynchronous reset
       cur_tgt_reg <= {TGT_CNT{1'b0}};
     else if (sync_rst_i)                                    //synchronous reset
       cur_tgt_reg <= {TGT_CNT{1'b0}};
     else if (itr_cyc_i & itr_stb_i)
       cur_tgt_reg <= new_tgt;                               //update bus tracker

   //Plain signal propagation to all target busses
   assign tgt_we_o  = {TGT_CNT{itr_we_i}};                   //write enables
   assign tgt_sel_o = {TGT_CNT{itr_sel_i}};                  //write data selects
   assign tgt_adr_o = {TGT_CNT{itr_adr_i}};                  //address busses
   assign tgt_dat_o = {TGT_CNT{itr_adr_i}};                  //write data busses
   assign tgt_tga_o = {TGT_CNT{itr_tga_i}};                  //propagated address tags
   assign tgt_tgc_o = {TGT_CNT{itr_tgc_i}};                  //bus cycle tags
   assign tgt_tgd_o = {TGT_CNT{itr_tgd_i}};                  //write data tags

   //Masked signal propagation to all target busses
   assign tgt_cyc_o  =  new_tgt | cur_tgt_reg;               //bus cycle indicators
   assign tgt_stb_o  =  new_tgt;                             //access requests
   assign tgt_lock_o = (new_tgt | cur_tgt_reg) &             //uninterruptible bus cycle indicators
	               {TGT_CNT{itr_lock_i}};
	  
   //Multiplexed signal propagation to the initiator bus
   assign itr_ack_o   = |{cur_tgt_reg & tgt_ack_i};          //bus cycle acknowledge
   assign itr_err_o   = |{cur_tgt_reg & tgt_err_i};          //error indicator
   assign itr_rty_o   = |{cur_tgt_reg & tgt_rty_i};          //retry request
   assign itr_stall_o = |{new_tgt & tgt_stall_i};            //access delay

   always @*                                                 //read data bus
   //always @(cur_tgt_reg or tgt_dat_i)                      //read data bus
     begin
        itr_dat_o = {DAT_WIDTH{1'b0}};
        for (i=0; i<(DAT_WIDTH*TGT_CNT); i=i+1)
          itr_dat_o[i%DAT_WIDTH] = itr_dat_o[i%DAT_WIDTH] |
                                   (cur_tgt_reg[i%TGT_CNT] & tgt_dat_i[i]);
     end

   always @*                                                 //read data tags
   //always @(cur_tgt_reg or tgt_tgd_i)                      //read data tags
     begin
        itr_tgd_o = {TGRD_WIDTH{1'b0}};
        for (j=0; j<(TGRD_WIDTH*TGT_CNT); j=j+1)
          itr_tgd_o[j%TGRD_WIDTH] = itr_tgd_o[j%TGRD_WIDTH] |
                                    (cur_tgt_reg[j%TGT_CNT] & tgt_tgd_i[j]);
     end

endmodule // WbXbc_splitter
