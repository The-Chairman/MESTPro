`include "opcodes.vh"
`include "param.vh"

module mest_pro_exec(
    input clk,
    input i_reset_n,
    input i_execute,
    input [ `OPCODE_SIZE - 1 :0 ] i_op_code,
    input [ `OPERANDA_SIZE - 1 : 0 ] i_operand1,
    input [ `OPERANDB_SIZE - 1 :0] i_operand2,
    input [`INSTRUCTION_SIZE - 1   :0] i_loadReg,
    output reg o_exec_done,
    output reg [8-1 :0] o_result,
    output reg o_carry,
    output reg o_zero_flag,
    output reg o_jump,
    output reg o_return_pc,
    output reg o_end_of_code,
    output reg o_output_enable,
    output reg [ `OUTPUT_MEM_WIDTH - 1: 0] o_output, 
    output reg[ `DATA_BITS-1:0] o_rega,
    output reg [ `ADDR_BITS -1 : 0 ] o_mm_addr,
    output reg [ `DATA_BITS - 1: 0 ] o_mm_dat,
    output reg o_mm_select,
    output reg o_cs,
    output reg o_we
    // Add stuff for memory //
);

reg [ `DATA_BITS :0] inter_result;
integer i;
reg [`DATA_BITS-1:0] tmp;

initial
begin
tmp = 0;
end 

always @(*)
begin
    o_mm_select = 0;
    o_cs = 1;
    o_we = 0;
    o_output_enable = 0;
    
    case(i_op_code)
    `OP_ADD: begin
        inter_result = i_operand1 + i_operand2;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_SUB: begin
        inter_result = i_operand1 - i_operand2;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_MULTIPLY: begin
        inter_result = i_operand1 * i_operand2;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_AND: begin
        inter_result = i_operand1 & i_operand2;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_OR: begin
        inter_result = i_operand1 | i_operand2;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_XOR: begin
        inter_result = i_operand1 ^ i_operand2;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_SROP1 : begin
        inter_result = i_operand1 >> 1;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_SLOP1: begin
        inter_result = i_operand1 << 1;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_NEGOP1: begin
        inter_result = ~i_operand1;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_JMP: begin
        o_jump = 1'd1;
        inter_result  = 8'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    `OP_RET: begin
        o_return_pc = 1'd1;
        inter_result  = 8'd0;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
    end  
    `OP_MVI: begin
        case( i_operand2 )
            `OUTPUT_REG: o_output = i_operand1 ;
            `REGA: o_rega = i_operand1 ;
            `MM: o_mm_dat = i_operand1;
        endcase
        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
`OP_MRA: begin
        case( i_operand2 )
            `OUTPUT_REG: o_output = o_rega ;
            `MM: o_mm_dat = o_rega;
        endcase
        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
`OP_MLR: begin
        case( i_operand2 )
            `OUTPUT_REG: o_output = i_loadReg;
            `REGA: o_rega = i_loadReg;
            `MM: o_mm_dat = i_loadReg;
        endcase
        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
`OP_MMDR: begin
        case( i_operand2 )
            `OUTPUT_REG: o_output = o_mm_dat;
            `REGA: o_rega = o_mm_dat;
        endcase
        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    
`OP_MRR: begin
        case( i_operand2 )
            `OUTPUT_REG: o_output = inter_result;
            `REGA: o_rega = inter_result;
            `MM: o_mm_dat = inter_result;
        endcase
        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
            
    
    `OP_OUTPUT: begin
//        o_output_enable = i_operand1 ? 1'b1 : 1'b0;
        o_output_enable = 1;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
     end    
     `OP_STORE_WORD: begin
        o_mm_addr[ 7:0 ] = i_operand2;
        o_mm_addr[ 15:8 ] = i_operand1;
        
 //       o_cs = 1;
        o_we = 1;
        o_mm_select = 1;
        #199 //NOTE this delay is not sythesizable but is neede for proper operation. 
        o_we = 0;
        o_mm_select = 0;
                        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
     end
     `OP_LOAD_WORD: begin
        o_mm_addr[ 7:0 ] = i_operand2;
        o_mm_addr[ 15:8 ] = i_operand1;
        
        o_mm_select = 1;
        o_cs = 1;
        o_we = 0;
        #199 //NOTE this delay is not sythesizable but is neede for proper operation.
        o_mm_select = 0;
        
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
     end
     `NO_OP: begin
     #10;
     end
    `OP_HALT: begin
        o_end_of_code = 1'd1;
        inter_result  = 8'd0;
        o_jump        = 1'd0;
        o_return_pc   = 1'b0;
    end
    default: begin
        inter_result  = 8'd0;
        o_jump        = 1'd0;
        o_end_of_code = 1'd0;
        o_return_pc   = 1'b0;
    end
    endcase
end

// Sequential Logic
always @(posedge clk or negedge i_reset_n)
begin
    if(~i_reset_n)
        begin
            o_result    <= 8'd0;
            o_carry     <= 1'd0;
            o_zero_flag <= 1'd0;
            o_exec_done <= 1'd0;
        end 
    else
        begin
            o_result    <= inter_result[8-1 :0];
            o_carry     <= inter_result[9-1];
            o_zero_flag <= ~(|inter_result);
            o_exec_done <= i_execute;
        end 
end



endmodule