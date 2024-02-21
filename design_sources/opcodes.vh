`ifndef _opcodes_vh_
`define _opcodes_vh_

`define OP_ADD 'b00000000
`define OP_SUB 'b00000001
`define OP_MULTIPLY 'b00000010
`define OP_AND 'b00000011
`define OP_OR 'b00000100
`define OP_SROP1 'b00000101
`define OP_SLOP1 'b00000110
`define OP_NEGOP1 'b00000111
`define OP_JMP 'b00001000
`define OP_RET 'b00001001
`define OP_MRA 'b00001010
`define OP_MVI 'b00001011
`define OP_MLR 'b00001100
`define OP_MMDR 'b00001101
`define OP_MRR 'b00001110
`define OP_OUTPUT 'b00001111
`define OP_STORE_WORD 'b00010000
`define OP_LOAD_WORD 'b00010001
`define OP_XOR 'b00010010
`define OP_SDY 'b00010011
`define OP_HALT 'b11111111
`endif