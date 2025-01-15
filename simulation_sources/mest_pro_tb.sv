`timescale 1ns / 1ps
`include "param.vh"

module mest_pro_tb;

wire w_clk;
wire w_reset_n;
wire w_start;

wire w_next_rom_line;
wire w_rom_line_ready;
wire w_rom_end;
wire [`INSTRUCTION_SIZE - 1 : 0] w_rom_line;

wire [8-1 :0] w_result;
wire w_valid_result;
wire w_carry;
wire w_zero_flag;
wire w_all_done;
wire [ `OUTPUT_MEM_WIDTH -1 : 0 ] w_display;
wire w_memory_reset;

initial begin
	$dumpfile( `DUMP_FILE );
	$dumpvars( w_clk, w_reset_n, w_start , w_result, w_valid_result, w_carry, 
		w_zero_flag, w_all_done, w_display, w_memory_reset, DUT, cur_rom );

end

always @( posedge w_all_done )  begin
	$display("all_done signal went high");
	$display("simulation complete");
    repeat(5) @(posedge w_clk);
	$finish;
end
mest_pro #(

)
DUT
(
    .clk            (w_clk          ),
    .i_reset_n      (w_reset_n      ),
    .i_start        (w_start        ),
    .i_memory_reset (w_memory_reset ),
    .i_rom_line     ( w_rom_line    ),
    .i_rom_line_ready     ( w_rom_line_ready ),
    .i_rom_end      ( w_rom_end     ),
    .o_result       (w_result       ),
    .o_valid_result (w_valid_result ),
    .o_carry        (w_carry        ),
    .o_zero_flag    (w_zero_flag    ),
    .o_all_done     (w_all_done     ),
    .o_display      (w_display      ),
    .o_next_rom_line( w_next_rom_line )
);

rom cur_rom(
    .clk (w_clk),
    .i_next_rom_line( w_next_rom_line ),
    .o_rom_line( w_rom_line ),
    .o_rom_line_ready( w_rom_line_ready),
    .o_rom_end( w_rom_end)
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
    .i_all_done     (w_all_done     )
);


endmodule
