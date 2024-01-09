`include "param.vh" 

module mest_pro_decode
(
    input [`INSTRUCTION_SIZE - 1 :0] i_decode_reg,
// Decode stage
    output [`OPCODE_SIZE - 1 :0] o_op_code,
    output [`CONSTANT_K_SIZE - 1 :0] o_const_K,
    output [`OPERANDA_SIZE - 1 :0] o_operand_a,
    output [`OPERANDB_SIZE - 1 :0] o_operand_b
);

// Decode Stage
assign o_op_code       = i_decode_reg[`OPCODE_SIZE -1 + `CONSTANT_K_SIZE + `OPERANDA_SIZE + `OPERANDB_SIZE  : `CONSTANT_K_SIZE + `OPERANDA_SIZE + `OPERANDB_SIZE ];
assign o_const_K       = i_decode_reg[`CONSTANT_K_SIZE -1 + `OPERANDA_SIZE + `OPERANDB_SIZE : `OPERANDA_SIZE + `OPERANDB_SIZE ];
assign o_operand_a     = i_decode_reg[`OPERANDA_SIZE - 1 + `OPERANDB_SIZE :  `OPERANDB_SIZE ];
assign o_operand_b     = i_decode_reg[`OPERANDB_SIZE - 1       :  0];

//assign o_op_code       = i_decode_reg[31:24];
//assign o_const_K       = i_decode_reg[23:16];
//assign o_operand_a     = i_decode_reg[15:8];
//assign o_operand_b     = i_decode_reg[7  : 0];
endmodule