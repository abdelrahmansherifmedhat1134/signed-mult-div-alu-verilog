`timescale 1ns/1ps
module multiplier_2 (
    input wire signed [7:0] A, B,
    output reg signed [15:0] sum
);
    integer i;
    wire signed [9:0] c;
    reg signed [15:0] sum_t[4:1];

    assign c = {B[7], B, 1'b0};

    always @(*) begin
        sum_t[1] = 16'sb0;
        sum_t[2] = 16'sb0;
        sum_t[3] = 16'sb0;
        sum_t[4] = 16'sb0;
        for (i = 0; i <= 6; i = i + 2) 
        begin
            case (c[i+:3])
                3'b000, 3'b111: sum_t[(i/2)+1] = 16'sb0;
                3'b001, 3'b010: sum_t[(i/2)+1] = $signed({{8{A[7]}}, A}) <<< i;
                3'b011        : sum_t[(i/2)+1] = $signed({{7{A[7]}}, A, 1'b0}) <<< i;
                3'b100        : sum_t[(i/2)+1] = $signed(-{{7{A[7]}}, A, 1'b0}) <<< i;
                3'b101, 3'b110: sum_t[(i/2)+1] = $signed(-{{8{A[7]}}, A}) <<< i;
                default:        sum= 16'sb0;
            endcase
            
        end
      sum=sum_t[1]+sum_t[2]+sum_t[3]+sum_t[4];
    end    
endmodule