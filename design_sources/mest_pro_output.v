`include "param.vh"
module mest_pro_output #(
    MEM_WIDTH = `OUTPUT_MEM_WIDTH
)(
    input                      clk,
    input                      i_output_enable,
    input      [MEM_WIDTH - 1 : 0 ] i_mem_val,
    output reg [MEM_WIDTH - 1 :0] o_display
);

// 7 segment LED after
// jameco.com/Jameco/workshop/TechTips/working-with-seven-segment-displays.html


always @(posedge clk)
begin
  if(~i_output_enable)
    begin
      o_display <= 'd0; // clear display when output enable is off
    end
  else
    begin
      case(i_mem_val)
        'd0:
          begin
            o_display <= 'b1111110;
          end
        'd1:
          begin
            o_display <= 'b0110000;
          end
        'd2:
          begin
            o_display <= 'b1101101;
          end
        'd3:
          begin
            o_display <= 'b1111001;
          end
        'd4:
          begin
            o_display <= 'b0110011;
          end
        'd5:
          begin
            o_display <= 'b1011011;
          end
        'd6:
          begin
            o_display <= 'b0011111;
          end
        'd7:
          begin
            o_display <= 'b1110000;
          end
        'd8:
          begin
            o_display <= 'b1111111;
          end
        'd9:
          begin
            o_display <= 'b1110011;
          end
        'ha:
          begin
            o_display <= 'b1110111;
          end
        'hb:
          begin
            o_display <= 'b0011111;
          end
        'hc:
          begin
            o_display <= 'b0001101;
          end
        'hd:
          begin
            o_display <= 'b0111101;
          end
        'he:
          begin
            o_display <= 'b1001111;
          end
        'hf:
          begin
            o_display <= 'b1000111;
          end
        default:
          begin
            o_display <= 'd0; // clear display when output enable is off
          end
        endcase
    end
end

endmodule

