`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 11:24:18 AM
// Design Name: 
// Module Name: TOP_MESTProMem3
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

module TOP_MESTProMem3(
input wire CLK,
input wire [`ADDR_BITS - 1 :0 ] i_prog_counter,
input wire [`ADDR_BITS - 1:0] addr,
input wire [`DATA_BITS - 1:0] in_dat,

input wire WE,
input wire CS,
input wire RESET,
input wire i_mm_select,
output reg [`INSTRUCTION_SIZE-1:0] o_inst,
output reg [`INSTRUCTION_SIZE-1:0] o_dat,
output reg ERROR
);

reg [`INSTRUCTION_SIZE-1:0] mem[`MEM_SIZE-1:0];
integer i;

initial
begin

//o_dat = `INSTRUCTION_SIZE'd0;

ERROR = 1'b0;
 for (i=0;i<`MEM_SIZE; i=i+1) begin
		 mem[i] = `INSTRUCTION_SIZE'd0;
                end

$readmemb("prog3.txt", mem); 

end 

always @(posedge CLK)
begin
    if (RESET) begin
        o_dat = `INSTRUCTION_SIZE'b0;
        ERROR = 1'b0;
        for (i=`ROM_SIZE;i<`MEM_SIZE; i=i+1) begin 
          mem[i] = `INSTRUCTION_SIZE'd0;
        end	
    end
        else begin
            if ( CS ) begin
                o_inst = mem[i_prog_counter];
            end            
            else begin               
                if (WE & (addr>`ROM_SIZE-1)) begin
                   ERROR = 1'b0;
                   mem[addr]= in_dat;           
                   end
                else if (WE & addr<`ROM_SIZE) begin
                    ERROR = 1'b1;
                end
                else if ( !WE & i_mm_select ) begin
                    ERROR = 1'b0;
                    o_dat = mem[addr];
                end
             end
         end
    end
    
endmodule
