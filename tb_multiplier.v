`timescale 1ns/1ps

module tb_multiplier ();

reg clk_tb ;
reg rst_tb ;
reg enable_tb ;
reg signed [7:0] A_tb,B_tb ;
wire signed [15:0] sum_tb ;

multiplier DUT(
    .clk(clk_tb),
    .rst(rst_tb),
    .enable(enable_tb),
    .A(A_tb),
    .B(B_tb),
    .sum(sum_tb)
) ;

initial begin
    clk_tb = 0 ;
    forever #10 clk_tb = ~clk_tb ;
end

initial begin
    rst_tb = 0;
    enable_tb = 0;
    A_tb = 0 ;
    B_tb = 0 ;

    #15 rst_tb = 1;
    enable_tb = 1;

    // Test Case 1: Positive * Positive
    @(posedge clk_tb); 
    A_tb = 8'd10; B_tb = 8'd5;   
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 2: Negative * Positive
    @(posedge clk_tb); 
    A_tb = -8'd10; B_tb = 8'd5;  
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 3: Positive * Negative
    @(posedge clk_tb); 
    A_tb = 8'd12; B_tb = -8'd3;  
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 4: Negative * Negative
    @(posedge clk_tb); 
    A_tb = -8'd7; B_tb = -8'd6;  
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 5: Maximum Positive Values
    @(posedge clk_tb); 
    A_tb = 8'd127; B_tb = 8'd127; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 6: Maximum Negative Values
    @(posedge clk_tb); 
    A_tb = -8'd128; B_tb = -8'd128; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // ---------------------------------------------------------
    // EDGE CASES
    // ---------------------------------------------------------

    // Test Case 7: Multiply by Zero (A is zero)
    @(posedge clk_tb); 
    A_tb = 8'd0; B_tb = 8'd55; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 8: Multiply by Zero (B is zero)
    @(posedge clk_tb); 
    A_tb = -8'd89; B_tb = 8'd0; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 9: Identity Multiplication (Positive)
    @(posedge clk_tb); 
    A_tb = -8'd115; B_tb = 8'd1; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 10: Identity Multiplication (Negative)
    @(posedge clk_tb); 
    A_tb = 8'd42; B_tb = -8'd1; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 11: Asymmetric Boundary (Max Pos * Max Neg)
    @(posedge clk_tb); 
    A_tb = 8'd127; B_tb = -8'd128; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 12: Asymmetric Boundary (Max Neg * Max Pos)
    @(posedge clk_tb); 
    A_tb = -8'd128; B_tb = 8'd127; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);

    // End simulation
    #50 $finish;    
    
end

endmodule //tb_multiplier