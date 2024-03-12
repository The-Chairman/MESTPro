`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2023 02:16:14 PM
// Design Name: 
// Module Name: TB_MESTProMem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "param.vh"

module TB_MESTProMem;

wire [`ADDR_BITS-1:0]addr;
wire [`DATA_BITS-1:0] data;
wire CLK;
wire WE;
wire CS;
wire RESET;
wire [`DATA_BITS-1:0] out_dat;

TOP_MESTProMem3 	My_Pro_Mem	( .addr(addr), .in_dat(data), .CLK(CLK), .o_dat(out_dat), .WE(WE), .CS(CS), .RESET(RESET)) ;

MestProMem_STIM My_ProMem_Stim (.in_dat(data), .addr(addr), .o_dat(out_dat), .CLK(CLK), .RESET(RESET), .WE(WE), .CS(CS)) ;


endmodule
