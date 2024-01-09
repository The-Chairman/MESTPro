`timescale 1ns / 1ps
`include "param.vh"

module mest_pro_tb;



parameter OP_CODE_SIZE     = `OPCODE_SIZE;
parameter INSTRUCTION_SIZE = `INSTRUCTION_SIZE;
parameter ROM_DEPTH = 65536;

reg clk;
reg i_reset_n;
reg i_start;

wire [8-1 :0] o_result;
wire o_valid_result;
wire o_carry;
wire o_zero_flag;
wire o_all_done;

wire memory_reset;

mest_pro#(
   .OP_CODE_SIZE    (OP_CODE_SIZE    ),
   .INSTRUCTION_SIZE(INSTRUCTION_SIZE),
   .ROM_DEPTH       (ROM_DEPTH       )
)
DUT
(
    .clk            (clk            ),
    .i_reset_n      (i_reset_n      ),
    .i_start        (i_start        ),
    .o_result       (o_result       ),
    .i_memory_reset ( memory_reset ),
    .o_valid_result (o_valid_result ),
    .o_carry        (o_carry        ),
    .o_zero_flag    (o_zero_flag    ),
    .o_all_done     (o_all_done     )
);

mest_pro_STIM my_mest_pro_STIM
(
    .clk            (clk            ),
    .i_reset_n      (i_reset_n      ),
    .i_start        (i_start        ),
    .o_memory_reset ( memory_reset  ),
    .o_result       (o_result       ),
    .o_valid_result (o_valid_result ),
    .o_carry        (o_carry        ),
    .o_zero_flag    (o_zero_flag    ),
    .o_all_done     (o_all_done     )
);


endmodule