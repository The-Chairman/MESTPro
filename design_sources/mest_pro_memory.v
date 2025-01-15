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

module mest_pro_memory(
input wire CLK,
input wire boot,
input wire i_rom_line_ready,

input wire [`ADDR_BITS - 1 :0 ] i_prog_counter,
input wire [`ADDR_BITS - 1:0] addr,
input wire [`DATA_BITS - 1:0] in_dat,

input wire WE,
input wire CS,
input wire reset,
input wire i_mm_select,
output reg [`INSTRUCTION_SIZE-1:0] o_inst,
output reg [`INSTRUCTION_SIZE-1:0] o_dat,
output reg ERROR
);

reg [`INSTRUCTION_SIZE-1:0] mem[`MEM_SIZE-1:0];
reg[ $clog2(`ROM_SIZE) - 1 : 0] boot_ptr;

always @(posedge CLK or posedge reset)
begin
    if (~reset) begin
        o_dat = `INSTRUCTION_SIZE'b0;
        ERROR = 1'b0;
        boot_ptr = 0;
    end else if ( boot && i_rom_line_ready) begin
        mem[boot_ptr] = in_dat;
        boot_ptr = boot_ptr + 1;
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
