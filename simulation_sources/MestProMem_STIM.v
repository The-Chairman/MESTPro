`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2023 02:43:32 PM
// Design Name: 
// Module Name: MestProMem_STIM
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

module MestProMem_STIM(

output reg [`ADDR_BITS-1:0] addr,
output reg [`DATA_BITS-1:0] in_dat,
output reg CLK,
output reg WE,
output reg CS,
output reg RESET,

input wire [`DATA_BITS-1:0] o_dat

    );

integer tt;
reg [`DATA_BITS-1:0] t_buf;  
    

initial 
begin 

RESET = 1'b0 ;
CLK = 1'b0 ;
CS = 1'b0;
WE = 1'b0;
addr = 16'bx;
in_dat = 8'bx;


// READ Loaded ROM Test
//CS=1;
//for (tt=0;tt<50;tt=tt+1) begin
//#100
//    addr = tt;
//    t_buf = o_dat;
//    end


//Write and Read 9 RAM loactions, RESET, and Read 9 RAM locations
//CS=1;
//WE=1;
//in_dat = 0;
//for (tt=`ROM_SIZE;tt<`ROM_SIZE+9;tt=tt+1) begin
//#100
//   addr=tt;
//    in_dat = in_dat+1;
//end
//WE=0;
//in_dat = 8'bx;
//for (tt=`ROM_SIZE;tt<`ROM_SIZE+9;tt=tt+1) begin
//#100
//    addr=tt;  
//    t_buf = o_dat;
//end
//RESET=1;
//#100
//RESET=0;
//for (tt=`ROM_SIZE;tt<`ROM_SIZE+9;tt=tt+1) begin
//#100
//    addr=tt;  
//    t_buf = o_dat;
//end


//READ ROM locations, RESET, and read ROM locations -> should not be changed
CS=1;
for (tt=0;tt<15;tt=tt+1) begin
#100
    addr = tt;
    t_buf = o_dat;
    end
#100
RESET=1;
#100
RESET=0;
for (tt=0;tt<15;tt=tt+1) begin
#100
    addr = tt;
    t_buf = o_dat;
    end

//Overwrite ROM Test: Write 9 ROM locations and read back -> should fail 
//CS=1;
//WE=1;
//in_dat = 0;
//for (tt=16;tt<25;tt=tt+1) begin
//#100
//    addr=tt;
//    in_dat = in_dat+1;
//end
//WE=0;
//for (tt=16;tt<25;tt=tt+1) begin
//#100
//    addr=tt;
//    t_buf = o_dat;
//end

end

//clock generator for 100 ns clock with 50% duty cycle
always 
#50  CLK =  ! CLK; 

endmodule
