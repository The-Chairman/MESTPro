`include "param.vh"
module mest_pro_output #(
    parameter MEM_WIDTH = `OUTPUT_MEM_WIDTH
)(
    input                      clk,
    input                      i_output_enable,
    input      [MEM_WIDTH - 1 : 0 ] i_mem_val,
    output reg [MEM_WIDTH - 1 :0] o_display
);

// 7 segment LED after
// jameco.com/Jameco/workshop/TechTips/working-with-seven-segment-displays.html

reg[ MEM_WIDTH -1 : 0 ] temp_display; 

always @(posedge clk)
begin

 o_display <= temp_display; 

end

always@(*) begin
      case(i_mem_val)
        'd0:
          begin
            temp_display = 'b1111110;
          end
        'd1:
          begin
            temp_display = 'b0110000;
          end
        'd2:
          begin
            temp_display = 'b1101101;
          end
        'd3:
          begin
            temp_display = 'b1111001;
          end
        'd4:
          begin
            temp_display = 'b0110011;
          end
        'd5:
          begin
            temp_display = 'b1011011;
          end
        'd6:
          begin
            temp_display = 'b0011111;
          end
        'd7:
          begin
            temp_display = 'b1110000;
          end
        'd8:
          begin
            temp_display = 'b1111111;
          end
        'd9:
          begin
            temp_display = 'b1110011;
          end
        'ha:
          begin
            temp_display = 'b1110111;
          end
        'hb:
          begin
            temp_display = 'b0011111;
          end
        'hc:
          begin
            temp_display = 'b0001101;
          end
        'hd:
          begin
            temp_display = 'b0111101;
          end
        'he:
          begin
            temp_display = 'b1001111;
          end
        'hf:
          begin
            temp_display = 'b1000111;
          end
        default:
          begin
          end
        endcase
end
endmodule

