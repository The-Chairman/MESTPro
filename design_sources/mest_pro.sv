`include "param.vh"

module mest_pro#(
    parameter OP_CODE_SIZE     = `OPCODE_SIZE,
    parameter INSTRUCTION_SIZE = `INSTRUCTION_SIZE
)(
    input clk,
    input i_reset_n,
    input i_start,
    input i_memory_reset,

    // Outputs
    output [8-1 :0] o_result,
    output o_valid_result,
    output o_carry,
    output o_zero_flag,
    output o_all_done,
    output [ `OUTPUT_MEM_WIDTH -1 : 0 ] o_display
);

// State Machine wires 
wire exec_done;
wire end_of_code;
wire idle_state;
wire fetch_state;
wire decode_state;
wire execute_state;

wire [ `ADDR_BITS -1  :0] prog_counter;
reg [INSTRUCTION_SIZE-1   :0] instruction;
reg [INSTRUCTION_SIZE-1   :0] loadReg;

// Memory Components 

reg [INSTRUCTION_SIZE-1   :0] data2store;
wire mm_we;
wire mm_cs;
wire mm_select;

reg[ `ADDR_BITS - 1 : 0] mm_addr;
reg[ `DATA_BITS -1 : 0] mm_dat;

wire [`INSTRUCTION_SIZE-1 :0] decode_reg;
wire [ `OPCODE_SIZE - 1 :0 ] op_code  ; 
wire [ `CONSTANT_K_SIZE -1 :0 ] const_K  ; 
wire [ `OPERANDA_SIZE - 1 :0 ] operand_a; 
wire [ `OPERANDB_SIZE - 1 :0 ] operand_b; 
wire jump;
wire return_pc;


// Local Global Registers
reg [ `OUTPUT_MEM_WIDTH - 1:0 ] output_buffer;
reg output_enable; 
reg [ `DATA_BITS-1:0 ] REGA;

assign o_valid_result = exec_done;

mest_pro_ctrlr
u_mest_pro_ctrlr(
    .clk           (clk          ),
    .i_reset_n     (i_reset_n    ),
    .i_start       (i_start      ),
    .i_end_of_code (end_of_code  ),
    .o_idle        (idle_state   ),
    .o_fetch       (fetch_state  ),
    .o_decode      (decode_state ),
    .o_execute     (execute_state),
    .o_all_done    (o_all_done   )
);

mest_pro_fetch#(
    .OP_CODE_SIZE     (OP_CODE_SIZE     ),
    .INSTRUCTION_SIZE (INSTRUCTION_SIZE )
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
    .o_prog_counter (prog_counter),
    .i_instruction  (instruction )
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
    .i_loadReg     (loadReg      ),
    .o_exec_done   (exec_done    ),
    .o_result      (o_result     ),
    .o_carry       (o_carry      ),
    .o_zero_flag   (o_zero_flag  ),
    .o_jump        (jump         ),
    .o_return_pc   (return_pc    ),
    .o_output_enable( output_enable),
    .o_output (output_buffer),
    .o_end_of_code (end_of_code  ),
    .o_rega ( REGA ),
    .o_mm_select( mm_select ),
    .o_mm_addr( mm_addr ),
    .o_mm_dat( mm_dat ),
    .o_cs( mm_cs ),
    .o_we( mm_we )
);

TOP_MESTProMem3 my_mest_pro_memory
(
    .CLK            (clk            ),
    .i_prog_counter ( prog_counter),
    .i_mm_select    ( mm_select ),
    .addr           ( mm_addr ),
    .in_dat         ( mm_dat    ),
    .WE             ( mm_we           ),
    .CS             ( mm_cs           ),
    .RESET          ( i_memory_reset        ),
    .o_inst         (instruction),
    .o_dat          (loadReg),
    .ERROR          ( ERROR)
);

mest_pro_output u_mest_pro_output(
    .clk( clk ),
    .i_output_enable(output_enable),
    .i_mem_val( output_buffer ),
    .o_display( o_display )
    
);

endmodule