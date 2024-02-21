module mest_pro_ctrlr(
    input  clk,
    input  i_reset_n,
    input  i_start,
    input  i_end_of_code,
    output o_idle,
    output o_fetch,
    output o_decode,
    output o_execute,
    output o_all_done
);


// Controller 
reg [2-1 :0] current_state;
reg [2-1 :0] next_state;
parameter [2-1 :0] IDLE    = 2'd0;
parameter [2-1 :0] FETCH   = 2'd1;
parameter [2-1 :0] DECODE  = 2'd2;
parameter [2-1 :0] EXECUTE = 2'd3;

// Assignments
assign o_idle      = (current_state == IDLE   );
assign o_fetch     = (current_state == FETCH  );
assign o_decode    = (current_state == DECODE );
assign o_execute   = (current_state == EXECUTE);
assign o_all_done  = i_end_of_code & o_execute;



// Sequential Logic
always @(posedge clk or negedge i_reset_n)
begin
    if(~i_reset_n)
        begin
            current_state <= 'd0;
        end 
    else
        begin
            current_state <= next_state;
        end 
end

always @(*)
begin
    case(current_state)
        IDLE:
            begin
                next_state = i_start ? FETCH : IDLE;
            end
        FETCH:
            begin
                next_state = DECODE;
            end
        DECODE:
            begin
                next_state = EXECUTE;
            end 
        EXECUTE:
            begin
                next_state = i_end_of_code   ? IDLE : FETCH;
           end
        default:
            begin
                next_state = IDLE;
            end
    endcase
end



endmodule