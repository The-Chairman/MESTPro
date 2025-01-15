module rom#(
    parameter ROM_SIZE = `ROM_SIZE,
    parameter INSTRUCTION_SIZE=32
)(
    input clk,
    input i_next_rom_line,
    output reg [INSTRUCTION_SIZE-1 :0] o_rom_line,
    output o_rom_line_ready,
    output o_rom_end
);
reg [INSTRUCTION_SIZE-1 :0] rom [ROM_SIZE-1 :0];
reg line_ready;
logic rom_end;
reg [ $clog2(ROM_SIZE) -1 : 0] rptr;
reg [ INSTRUCTION_SIZE - 1 : 0] cur_rom_line;

assign o_rom_end = rom_end;
assign o_rom_line_ready = line_ready;
assign rom_end = ( rptr >= `ROM_SIZE );
assign o_rom_line = cur_rom_line;
//assign o_rom_line = rom[rptr];
initial begin
    $readmemb(`ROM_FILE, rom, 0, `ROM_SIZE-1 );
    rptr = 0;
    line_ready = 0;
    cur_rom_line = 0;
end

always@(posedge i_next_rom_line ) begin
    if( ~rom_end ) begin
        cur_rom_line = rom[rptr];
        line_ready = 1;
    end
end

always@(negedge i_next_rom_line)begin
    line_ready = 0;
    rptr = rptr + 1;
end

// always @(*) begin
//     if( i_next_rom_line && ~rom_end && ~line_ready ) begin
//         rptr <= rptr + 1;
//         line_ready = 1;
//         rom_end = ( rptr >= `ROM_SIZE -1 ) ? 1 : 0;
//     end else if (~i_next_rom_line && line_ready ) begin
//         line_ready = 0;
//     end 
// end
endmodule