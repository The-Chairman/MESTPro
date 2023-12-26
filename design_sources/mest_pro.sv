module mest_pro#(
    parameter OP_CODE_SIZE     = 4,
    parameter INSTRUCTION_SIZE = OP_CODE_SIZE + 8 + 8 + 8,
    parameter ROM_DEPTH = 256
)(
    input clk,
    input i_reset_n,
    input i_start,
    // Memory Interface
    output o_req,
    output [$clog2(ROM_DEPTH)-1  :0] o_prog_counter,
    input [INSTRUCTION_SIZE-1    :0] i_instruction,
    // Outputs
    output [8-1 :0] o_result,
    output o_valid_result,
    output o_carry,
    output o_zero_flag,
    output o_all_done
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

assign o_valid_result = exec_done;

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
    .o_end_of_code (end_of_code  )
);

endmodule