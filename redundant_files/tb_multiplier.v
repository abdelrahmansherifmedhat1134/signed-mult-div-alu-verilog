`timescale 1ns/1ps

module tb_multiplier ();

reg clk_tb ;
reg rst_tb ;
reg signed [7:0] A_tb,B_tb ;
wire signed [15:0] sum_tb ;

multiplier DUT(clk_tb, rst_tb, A_tb, B_tb, sum_tb) ;

initial begin
    clk_tb = 0 ;
    forever #10 clk_tb = ~clk_tb ;
end

initial begin
    rst_tb = 0;
    A_tb = 0 ;
    B_tb = 0 ;

    $monitor("Time = %0t | rst = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, A_tb, B_tb, sum_tb);

    #15 rst_tb = 1;

    // Test Case 1: Positive * Positive
    @(posedge clk_tb); 
    A_tb = 8'd10; B_tb = 8'd5;   // Expected: 50
        
    // Test Case 2: Negative * Positive
    #20 @(posedge clk_tb); 
    A_tb = -8'd10; B_tb = 8'd5;  // Expected: -50
        
    // Test Case 3: Positive * Negative
    #20 @(posedge clk_tb); 
    A_tb = 8'd12; B_tb = -8'd3;  // Expected: -36
        
    // Test Case 4: Negative * Negative
    #20 @(posedge clk_tb); 
    A_tb = -8'd7; B_tb = -8'd6;  // Expected: 42
        
    // Test Case 5: Maximum Positive Values
    #20 @(posedge clk_tb); 
    A_tb = 8'd127; B_tb = 8'd127; // Expected: 16129
        
    // Test Case 6: Maximum Negative Values
    #20 @(posedge clk_tb); 
    A_tb = -8'd128; B_tb = -8'd128; // Expected: 16384

    // End simulation
    #50 $finish;    
    
end


endmodule //tb_multiplier