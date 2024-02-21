`include "param.vh"

module mest_pro_fetch#(
    parameter OP_CODE_SIZE     = `OPCODE_SIZE,
    parameter INSTRUCTION_SIZE = `INSTRUCTION_SIZE
)(
    input clk,
    input i_reset_n,
    input idle_state,
    input fetch_state,
    input exec_state,
    input jump,
    input return_pc,
    input [`CONSTANT_K_SIZE - 1            :0] const_K,
    output reg [INSTRUCTION_SIZE-1  :0] decode_reg,
    // Memory Interface
    output o_req,
    output [`ADDR_BITS -1     :0] o_prog_counter,
    input [INSTRUCTION_SIZE-1 :0] i_instruction

);


// Fetch Stage
// Program Memory
wire [INSTRUCTION_SIZE-1 :0] prog_mem_data_out;
reg [ `ADDR_BITS - 1     :0] prog_counter;
reg [ `ADDR_BITS -1     :0] tmp_counter;


// FETCH Stage
always @(posedge clk or negedge i_reset_n)
begin
    if(~i_reset_n)
        begin
            prog_counter <= 'd0;
            tmp_counter  <= 'd0;
        end
    else
        begin
            tmp_counter  <= (exec_state & jump) ? prog_counter : tmp_counter;
            prog_counter <= idle_state               ? 'd0 :
                            fetch_state ? prog_counter +'d1:
                            (exec_state & jump)      ? const_K  :
                            (exec_state & return_pc) ? tmp_counter  :
                            prog_counter;
        end
end

always @(posedge clk or negedge i_reset_n)
begin
    if(~i_reset_n)
        begin
            decode_reg <= 'd0;
        end
    else
        begin
            decode_reg <= idle_state  ? 'd0 :
                          fetch_state ? prog_mem_data_out:
                          decode_reg;
        end
end

assign prog_mem_data_out = i_instruction;
assign o_req             = fetch_state;
assign o_prog_counter    = prog_counter;

endmodule