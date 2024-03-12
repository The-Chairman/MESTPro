module mest_pro_rom#(
    parameter DEPTH = `ROM_SIZE,
    parameter WORD_SIZE=32
)(
    input clk,
    input  [$clog2(DEPTH)-1     :0] address,
    output reg [WORD_SIZE-1 :0] o_data
);
reg [WORD_SIZE-1 :0] rom [DEPTH-1 :0];

initial begin
    $readmemb(`ROM_FILE, rom); //Change Path
end

always @(posedge clk)
begin
    o_data <= rom[address];
end

endmodule