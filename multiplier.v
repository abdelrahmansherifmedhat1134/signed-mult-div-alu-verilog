`timescale 1ns/1ps
module multiplier (
    input                    clk,rst,
    input wire               enable,
    input wire signed [7:0]  A,B,
    
    output reg signed [15:0] sum
);

integer i;
wire signed [9:0] c;
reg signed [15:0] sum_pp [4:1]; // Teammate's Parallel Partial Product Array

assign c = {B[7],B,1'b0};

always @(posedge clk or negedge rst) begin
   if(!rst) begin
      sum <= 16'sb0;
   end else if (enable) begin
       
     // FIXED: Correctly initialize the sum_pp array, not the final sum register
     sum_pp[1] = 16'sb0;
     sum_pp[2] = 16'sb0;
     sum_pp[3] = 16'sb0;
     sum_pp[4] = 16'sb0;
     
     for(i=0; i<=6; i=i+2) begin
         case (c[i+:3])
             3'b000,3'b111: sum_pp[(i/2)+1] = 0;
             3'b001,3'b010: sum_pp[(i/2)+1] = $signed({{8{A[7]}}, A}) <<< i;
             3'b011       : sum_pp[(i/2)+1] = $signed({{7{A[7]}}, A, 1'b0}) <<< i;
             3'b100       : sum_pp[(i/2)+1] = $signed(-{{7{A[7]}}, A, 1'b0}) <<< i;
             3'b101,3'b110: sum_pp[(i/2)+1] = $signed(-{{8{A[7]}}, A}) <<< i;
             default:       sum_pp[(i/2)+1] = 16'b0; // FIXED: Target the array
         endcase
     end
     
     // FIXED: Use Non-Blocking (<=) to safely latch the parallel addition into the D-Flip-Flop
     sum <= sum_pp[1] + sum_pp[2] + sum_pp[3] + sum_pp[4];
   end  
end

endmodule