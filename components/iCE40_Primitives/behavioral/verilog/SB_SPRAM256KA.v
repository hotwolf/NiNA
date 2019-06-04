//###############################################################################
//# NiNA - Behavioral Model of the SB_SPRAM256KA Single-Ported RAM Cell         #
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
//#    This is a behavioral model of the SB_SPRAM256KA single-ported RAM cell,  #
//#    which is available on all Lattice iCE40 FPGA devices. This model has     #
//#    been written based on the public documentation from Lattice.             #
//#                                                                             #
//###############################################################################
//# Version History:                                                            #
//#   May 16, 2019                                                              #
//#      - Initial release                                                      #
//###############################################################################
`default_nettype none

module SB_SPRAM256KA
   (input  wire [13:0]     ADDRESS,                                                           //address
    input  wire [15:0]     DATAIN,                                                            //write data
    input  wire  [3:0]     MASKWREN,                                                          //write mask
    input  wire            WREN,                                                              //read/write selecty
    input  wire            CHIPSELECT,                                                        //memory enable
    input  wire            CLOCK,                                                             //clock
    input  wire            STANDBY,                                                           //low power mode -> maintain DATAOUT and memory content
    input  wire            SLEEP,                                                             //low power mode -> drive DATAOUT low, but keep memory content
    input  wire            POWEROFF,                                                          //low power mode -> drive DATAOUT low and loose memory content
    output reg  [15:0]     DATAOUT);                                                          //read data

   //Memory
   reg [15:0]              memory [16383:0];

   //Counter variables
   int                     i;

   //Memory initialization
   initial
     begin
        for (i=0; i<16383; i=i+1)
          memory[i] = 16'hxxxx;
     end // initial begin

   //Write access
   always @(posedge CLOCK or
            posedge POWEROFF)
     begin
        //Memory write
        if ( WREN       &
             CHIPSELECT &
             ~STANDBY   &
             ~SLEEP     &
             ~POWEROFF)
          memory[ADDRESS] <= ( {{4{MASKWREN[3]}},{4{MASKWREN[2]}},{4{MASKWREN[1]}},{4{MASKWREN[0]}}} & DATAIN) |
                             (~{{4{MASKWREN[3]}},{4{MASKWREN[2]}},{4{MASKWREN[1]}},{4{MASKWREN[0]}}} & memory[ADDRESS]);
        //Loose content
        if (POWEROFF)
          for (i=0; i<16383; i=i+1)
            memory[i] = 16'hxxxx;
     end // always @ (posedge CLOCK or...

   //Memory read
   always @(posedge CLOCK    or
            posedge SLEEP    or
            posedge POWEROFF)
     begin
        //Drive DATAOUT low
        if (SLEEP | POWEROFF)
          DATAOUT = 16'h0000;
        else
        //Read access
         if (~WREN       &
              CHIPSELECT &
             ~STANDBY)
           DATAOUT = memory[ADDRESS];
     end // always @ (posedge CLOCK    or...

endmodule // SB_RAM256x16
