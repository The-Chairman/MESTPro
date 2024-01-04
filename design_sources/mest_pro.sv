`include "param.vh"

module mest_pro#(
    parameter OP_CODE_SIZE     = 4,
    parameter INSTRUCTION_SIZE = OP_CODE_SIZE + 8 + 8 + 8,
    parameter ROM_DEPTH = 65536
)(
    input clk,
    input i_reset_n,
    input i_start,
    // Memory Interface
    output o_req,
    output [$clog2(ROM_DEPTH)-1  :0] o_prog_counter,
    output reg [INSTRUCTION_SIZE-1   :0] data2store,
    output reg WE,
    output reg CS,
    output reg RESET,
    input [INSTRUCTION_SIZE-1    :0] i_instruction,
    input m_ERROR,
    
    // Outputs
    output [8-1 :0] o_result,
    output o_valid_result,
    output o_carry,
    output o_zero_flag,
    output o_all_done,
    output o_display
);

wire exec_done;
wire end_of_code;
wire idle_state;
wire fetch_state;
wire decode_state;
wire execute_state;


wire [INSTRUCTION_SIZE-1 :0] decode_reg;
wire [4-1 :0] op_code  ; 
wire [8-1 :0] const_K  ; 
wire [8-1 :0] operand_a; 
wire [8-1 :0] operand_b; 
wire jump;
wire return_pc;


// Local Global Registers
reg [ `OUTPUT_SIZE - 1:0 ] output_buffer;
reg output_enable; 
reg [ `DATA_BITS-1:0 ] REGA;

assign o_valid_result = exec_done;

assign WE = 1'b0;
assign CS = 1'b1;
assign RESET = 1'b0;

mest_pro_ctrlr
u_mest_pro_ctrlr(
    .clk           (clk          ),
    .i_reset_n     (i_reset_n    ),
    .i_start       (i_start      ),
    .i_exec_done   (exec_done    ),
    .i_end_of_code (end_of_code  ),
    .o_idle        (idle_state   ),
    .o_fetch       (fetch_state  ),
    .o_decode      (decode_state ),
    .o_execute     (execute_state),
    .o_all_done    (o_all_done   )
);

mest_pro_fetch#(
    .OP_CODE_SIZE     (OP_CODE_SIZE     ),
    .INSTRUCTION_SIZE (INSTRUCTION_SIZE ),
    .ROM_DEPTH        (ROM_DEPTH        )
)
u_mest_pro_fetch(
    .clk            (clk           ),
    .i_reset_n      (i_reset_n     ),
    .idle_state     (idle_state    ),
    .fetch_state    (fetch_state   ),
    .exec_state     (decode_state  ),
    .jump           (jump          ),
    .return_pc      (return_pc     ),
    .const_K        (const_K       ),
    .decode_reg     (decode_reg    ),
    .o_req          (o_req         ),
    .o_prog_counter (o_prog_counter),
    .i_instruction  (i_instruction )
);

mest_pro_decode
u_mest_pro_decode(
    .i_decode_reg(decode_reg),
    .o_op_code   (op_code   ),
    .o_const_K   (const_K   ),
    .o_operand_a (operand_a ),
    .o_operand_b (operand_b )
);

mest_pro_exec
u_mest_pro_exec(
    .clk           (clk          ),
    .i_reset_n     (i_reset_n    ),
    .i_execute     (execute_state),
    .i_op_code     (op_code      ),
    .i_operand1    (operand_a    ),
    .i_operand2    (operand_b    ),
    .o_exec_done   (exec_done    ),
    .o_result      (o_result     ),
    .o_carry       (o_carry      ),
    .o_zero_flag   (o_zero_flag  ),
    .o_jump        (jump         ),
    .o_return_pc   (return_pc    ),
    .o_output_enable( output_enable),
    .o_end_of_code (end_of_code  ),
    .o_rega ( REGA )
);

// This is borked
TOP_MESTProMem3 my_mest_pro_memory
(
    .CLK            (clk            ),
    .addr           (o_prog_counter ),
    .in_dat         (data2store     ), //needs new wire
    .WE             (WE           ),
    .CS             (CS           ),
    .RESET          (RESET        ),
    .o_dat          (i_instruction  ), // needs new wire/reg?
    .ERROR          (ERROR)
);

mest_pro_output u_mest_pro_output(
    .clk( clk ),
    .i_output_enable_(output_enable),
    .i_mem_val( output_buffer ),
    .o_display( o_display )
    
);

endmodule