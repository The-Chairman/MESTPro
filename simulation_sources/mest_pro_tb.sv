`timescale 1ns / 1ps
`include "param.vh"

module mest_pro_tb;

parameter OP_CODE_SIZE     = `OPCODE_SIZE;
parameter INSTRUCTION_SIZE = `INSTRUCTION_SIZE;
parameter ROM_DEPTH = 65536;

wire w_clk;
wire w_reset_n;
wire w_start;

wire [8-1 :0] w_result;
wire w_valid_result;
wire w_carry;
wire w_zero_flag;
wire w_all_done;
wire [ `OUTPUT_MEM_WIDTH -1 : 0 ] w_display
wire w_memory_reset;

mest_pro#(
   .OP_CODE_SIZE    (OP_CODE_SIZE    ),
   .INSTRUCTION_SIZE(INSTRUCTION_SIZE),
   .ROM_DEPTH       (ROM_DEPTH       )
)
DUT
(
    .clk            (w_clk            ),
    .i_reset_n      (w_reset_n      ),
    .i_start        (w_start        ),
    .i_memory_reset (w_memory_reset ),
    .o_result       (w_result       ),
    .o_valid_result (w_valid_result ),
    .o_carry        (w_carry        ),
    .o_zero_flag    (w_zero_flag    ),
    .o_all_done     (w_all_done     ),
    .o_display      (w_display      )
);

mest_pro_STIM my_mest_pro_STIM
(
    .clk            (w_clk            ),
    .o_reset_n      (w_reset_n      ),
    .o_start        (w_start        ),
    .o_memory_reset (w_memory_reset  ),
    .i_result       (w_result       ),
    .i_valid_result (w_valid_result ),
    .i_carry        (w_carry        ),
    .i_zero_flag    (w_zero_flag    ),
    .i_all_done     (w_all_done     ),
	.i_display      (w_display      )
);


endmodule