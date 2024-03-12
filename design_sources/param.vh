`timescale 1ns / 1ps
`ifndef _param_vh_
`define _param_vh_

`define OPCODE_SIZE 8
`define CONSTANT_K_SIZE 8
`define OPERANDA_SIZE 8
`define OPERANDB_SIZE 8
`define INSTRUCTION_SIZE `OPCODE_SIZE + `CONSTANT_K_SIZE + `OPERANDA_SIZE + `OPERANDB_SIZE

`define ADDR_BITS 16
`define DATA_BITS 28
`define ROM_SIZE 2048
`define MEM_SIZE 4096

// Output parameters
`define OUTPUT_MEM_WIDTH 16

// Alias for Regs
`define OUTPUT_REG 0
`define REGA 1
`define MM 2 

`endif