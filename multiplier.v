`timescale 1ns/1ps

module multiplier #(parameter width = 8) (
    input                             clk,
    input                             rst,
    input  wire                       enable,
    input  wire signed [width-1:0]    A,
    input  wire signed [width-1:0]    B,
    
    output reg  signed [2*width-1:0]  sum
);

    integer i, j;
    
    // The padded multiplier wire (width bits + 1 extra zero at the LSB)
    wire signed [width+1:0] c;
    
    // Dynamically sized array to hold N/2 partial products. 
    // Each partial product is 2*width bits wide.
    reg signed [2*width-1:0] sum_pp [(width/2):1]; 
    
    // Accumulator for the final summation tree
    reg signed [2*width-1:0] accum;

    assign c = {B[width-1], B, 1'b0}; // Sign-extend by 1 bit, append 0 to LSB

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sum <= 0;
        end else if (enable) begin
            
            // 1. Clear the dynamically sized array
            for (j = 1; j <= width/2; j = j + 1) begin
                sum_pp[j] = 0;
            end
            
            // 2. Generate Partial Products using Radix-4 Sliding Window
            for (i = 0; i <= width-2; i = i + 2) begin
                case (c[i+:3])
                    3'b000, 3'b111: sum_pp[(i/2)+1] = 0;
                    
                    3'b001, 3'b010: sum_pp[(i/2)+1] = $signed({{width{A[width-1]}}, A}) <<< i;
                    
                    3'b011:         sum_pp[(i/2)+1] = $signed({{width-1{A[width-1]}}, A, 1'b0}) <<< i;
                    
                    3'b100:         sum_pp[(i/2)+1] = $signed(-{{width-1{A[width-1]}}, A, 1'b0}) <<< i;
                    
                    3'b101, 3'b110: sum_pp[(i/2)+1] = $signed(-{{width{A[width-1]}}, A}) <<< i;
                    
                    default:        sum_pp[(i/2)+1] = 0; 
                endcase
            end
            
            // 3. Combinatorial Accumulation (Synthesizes into an Adder Tree)
            accum = 0;
            for (j = 1; j <= width/2; j = j + 1) begin
                accum = accum + sum_pp[j];
            end
            
            // 4. Safe sequential output assignment
            sum <= accum;
            
        end  
    end

endmodule