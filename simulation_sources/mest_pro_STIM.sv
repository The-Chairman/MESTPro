`timescale 1ns / 1ps
module mest_pro_STIM
#(
parameter OP_CODE_SIZE     = 4, INSTRUCTION_SIZE = OP_CODE_SIZE + 8 + 8 + 8, ROM_DEPTH = 65536
)
(
output reg clk,
output reg o_reset_n,
output reg o_start,
output reg o_memory_reset,
input wire [8-1 :0] i_result,
input wire i_valid_result,
input wire i_carry,
input wire i_zero_flag,
input wire i_all_done
);

always begin
#50  clk = !clk;
end

realtime delay;
initial begin
    clk       =0;
    o_start   =0;
    o_memory_reset = 1;
    o_reset_n = 0;
    #5
    o_memory_reset = 0;
    repeat(5) @(posedge clk);
    o_reset_n = 1;
    repeat(5) @(posedge clk);
    o_start   =1;
    @(posedge clk);
    o_start   =0;


	delay=10000;
	#(delay);
	$display("Simulation timeout!");
	$display("Done Simulation");
	$finish;
end

integer out_num;
initial out_num = 0;


always @(posedge clk)begin
    if(i_valid_result)begin
        $display("Result number %0d = %0d",out_num,i_valid_result);
        $display("Carry  number %0d = %0d",out_num,i_carry);
        $display("Zero Flag  number %0d = %0d",out_num,i_zero_flag);
        out_num = out_num +1;
    end
 
 
end

endmodule