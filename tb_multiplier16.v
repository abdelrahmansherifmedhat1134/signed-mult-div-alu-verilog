`timescale 1ns/1ps

module tb_multiplier16 ();

reg clk_tb ;
reg rst_tb ;
reg enable_tb ;
reg signed [15:0] A_tb, B_tb ;
wire signed [31:0] sum_tb ;

multiplier #(.width(16)) DUT(
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
    A_tb = 16'd150; B_tb = 16'd40;   
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 2: Negative * Positive
    @(posedge clk_tb); 
    A_tb = -16'd200; B_tb = 16'd25;  
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 3: Positive * Negative
    @(posedge clk_tb); 
    A_tb = 16'd300; B_tb = -16'd15;  
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 4: Negative * Negative
    @(posedge clk_tb); 
    A_tb = -16'd450; B_tb = -16'd12;  
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 5: Maximum Positive Values
    @(posedge clk_tb); 
    A_tb = 16'd32767; B_tb = 16'd32767; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
        
    // Test Case 6: Maximum Negative Values
    @(posedge clk_tb); 
    A_tb = -16'd32768; B_tb = -16'd32768; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // ---------------------------------------------------------
    // EDGE CASES
    // ---------------------------------------------------------

    // Test Case 7: Multiply by Zero (A is zero)
    @(posedge clk_tb); 
    A_tb = 16'd0; B_tb = 16'd8500; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 8: Multiply by Zero (B is zero)
    @(posedge clk_tb); 
    A_tb = -16'd12450; B_tb = 16'd0; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 9: Identity Multiplication (Positive)
    @(posedge clk_tb); 
    A_tb = -16'd24000; B_tb = 16'd1; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 10: Identity Multiplication (Negative)
    @(posedge clk_tb); 
    A_tb = 16'd18000; B_tb = -16'd1; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 11: Asymmetric Boundary (Max Pos * Max Neg)
    @(posedge clk_tb); 
    A_tb = 16'd32767; B_tb = -16'd32768; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);
    
    // Test Case 12: Asymmetric Boundary (Max Neg * Max Pos)
    @(posedge clk_tb); 
    A_tb = -16'd32768; B_tb = 16'd32767; 
    @(posedge clk_tb); 
    #1;
    $display("Time = %0t | rst = %b | enable = %b | A = %d, B = %d | Output sum = %d", $time, rst_tb, enable_tb, A_tb, B_tb, sum_tb);

    // End simulation
    #50 $finish;    
    
end

endmodule //tb_multiplier_16bit