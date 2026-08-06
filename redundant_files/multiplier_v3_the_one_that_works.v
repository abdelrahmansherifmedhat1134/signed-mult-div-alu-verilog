`timescale 1ns/1ps
module multiplier (
    input                    clk,rst,
    input wire               enable,
    input wire signed [7:0]  A,B,
    
    output reg signed [15:0] sum
);
integer i;
wire signed [9:0]c;
reg signed [15:0] sum1,sum2;
assign c={B[7],B,1'b0};
always @(posedge clk,negedge rst) begin
   if(!rst)
   begin
      sum <= 16'sb0;
   end  else if (enable) begin
   sum2=16'sb0;
     for(i=0;i<=6;i=i+2)
     begin
         case (c[i+:3])
         3'b000,3'b111:sum1=0;
         3'b001,3'b010:sum1=$signed({{8{A[7]}}, A}) <<< i;
         3'b011       :sum1=$signed({{7{A[7]}}, A, 1'b0}) <<< i;
         3'b100       :sum1=$signed(-{{7{A[7]}}, A, 1'b0}) <<< i;
         3'b101,3'b110:sum1=$signed(-{{8{A[7]}}, A}) <<< i;
         default: sum2 =16'b0;      
         endcase
         sum2=sum2+sum1;
     end
     sum <= sum2;
   end  
end

endmodule