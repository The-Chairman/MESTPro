`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2024 02:43:28 PM
// Design Name: 
// Module Name: rom_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rom_ctrl#(
    parameter INSTRUCTION_SIZE = 32,
    parameter ROM_SIZE = `ROM_SIZE,
	parameter ROM_FILE = `ROM_FILE
    )(
    input wire clk, reset,
    input wire boot_state,
    input wire i_rom_line_ready,
    input reg[ INSTRUCTION_SIZE -1 : 0] i_rom_line,
    input i_rom_end,
    
    output reg o_next_rom_line_pls,
    output reg[ INSTRUCTION_SIZE -1 : 0 ] o_rom_line,
    output reg o_rom_load_complete,
    output reg[ INSTRUCTION_SIZE -1 : 0] tr_rom_line,
    output wire o_memory_write_enable
    );
    
    reg [ INSTRUCTION_SIZE - 1:0] rom_mem[ROM_SIZE-1:0];
    reg [ INSTRUCTION_SIZE - 1:0] cur_rom_line;
    
    reg next_instruction_pls;
    reg done_loading_rom;
    reg write_to_ram;

    assign o_next_rom_line_pls = next_instruction_pls;
    assign cur_rom_line = i_rom_line;
    assign o_rom_line = cur_rom_line;
    assign o_rom_load_complete = done_loading_rom;
    //assign o_memory_write_enable = write_to_ram;
    assign o_memory_write_enable = write_to_ram;

    typedef enum logic [1:0] {IDLE, FETCH, WRITE} state;
    state current_state;
    state next_state;

    always @( posedge clk or posedge reset )
    begin
        if( ~reset ) begin
            next_instruction_pls = 0;
            current_state = IDLE;
            next_state = IDLE;
            done_loading_rom = 0;
            write_to_ram = 0;
        end else if( boot_state ) begin
            if ( ~done_loading_rom ) begin
                if( current_state == IDLE && i_rom_end) begin
                    done_loading_rom = 1;
                end else begin 
                    case( current_state )
                        IDLE: begin
                            write_to_ram = 0;
                            next_instruction_pls = 1;
                        end
                        FETCH: begin
                            next_instruction_pls = 0;
                        end
                        WRITE: write_to_ram = 1;
                    endcase
                    current_state <= next_state; 
                end
            end else begin
                next_instruction_pls = 0;
                write_to_ram = 0;
            end
        end
    end

    always @(*) begin
        if ( boot_state && reset ) begin
            case( current_state )
                IDLE: begin
                    if (!i_rom_end) begin
                        next_state = FETCH;
                    end else begin
                        next_state = IDLE;
                    end
                end
                FETCH: begin
                    if( i_rom_line_ready) begin
                        next_state = WRITE;
                    end 
                end 
                WRITE: begin
                    next_state = IDLE;
                end
                default: next_state = IDLE;
            endcase
        end
    end
endmodule
