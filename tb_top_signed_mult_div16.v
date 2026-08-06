`timescale 1ns/1ps

module tb_top_signed_mult_div16 #(parameter width_tb = 16);

    // 1. Declare Signals for Top Module
    reg                               clk_tb;
    reg                               rst_tb;
    reg  [1:0]                        op_sel_tb;
    reg  signed [width_tb-1:0]        operand1_tb;
    reg  signed [width_tb-1:0]        operand2_tb;
    reg                               start_tb;
    
    wire signed [2*width_tb-1:0]      final_result_tb;
    wire                              busy_tb;
    wire                              done_tb;
    wire                              err_dbz_tb;

    // 2. Instantiate the Top Module
    top_signed_mult_div #(.width(width_tb)) DUT (
        .clk(clk_tb),
        .rst(rst_tb),
        .op_sel(op_sel_tb),
        .operand1(operand1_tb),
        .operand2(operand2_tb),
        .start(start_tb),
        .final_result(final_result_tb),
        .busy(busy_tb),
        .done(done_tb),
        .err_dbz(err_dbz_tb)
    );

    // 3. Clock Generation
    initial begin
        clk_tb = 0;
        forever #10 clk_tb = ~clk_tb;
    end

    // 4. Test Stimulus Sequence
    initial begin
        // Initialization
        rst_tb = 0;
        start_tb = 0;
        op_sel_tb = 2'd0;
        operand1_tb = 0;
        operand2_tb = 0;

        #15 rst_tb = 1; // Release reset
        #10;

        // =========================================================================================
        // MULTIPLICATION TESTS (op_sel = 2'd0) - 16-BIT DATA
        // =========================================================================================
        $display("\n===================================================================================================");
        $display(" MULTIPLICATION TESTS (op_sel = 0) - 16-BIT");
        $display("===================================================================================================");
        $display(" Time       | Operand A | Operand B | Final Result    | Expected        | Test Case Type");
        $display("---------------------------------------------------------------------------------------------------");
        op_sel_tb = 2'd0; // Lock top module to multiplication

        // Test Case 1: Positive * Positive
        @(posedge clk_tb); 
        operand1_tb = 16'd1500; operand2_tb = 16'd40;   
        @(posedge clk_tb); #1; // Wait 1 cycle for D-FF + 1ns delay for simulator
        $display(" %0t       | %9d | %9d | %15d |           60000 | Positive * Positive", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 2: Negative * Positive
        @(posedge clk_tb); 
        operand1_tb = -16'd2000; operand2_tb = 16'd25;  
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |          -50000 | Negative * Positive", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 3: Positive * Negative
        @(posedge clk_tb); 
        operand1_tb = 16'd3000; operand2_tb = -16'd15;  
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |          -45000 | Positive * Negative", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 4: Negative * Negative
        @(posedge clk_tb); 
        operand1_tb = -16'd4500; operand2_tb = -16'd12;  
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |           54000 | Negative * Negative", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 5: Maximum Positive Values
        @(posedge clk_tb); 
        operand1_tb = 16'd32767; operand2_tb = 16'd32767; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |      1073676289 | Max Positive Boundary", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 6: Maximum Negative Values
        @(posedge clk_tb); 
        operand1_tb = -16'd32768; operand2_tb = -16'd32768; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |      1073741824 | Max Negative Boundary", $time, operand1_tb, operand2_tb, final_result_tb);

        // Test Case 7: Multiply by Zero (A is zero)
        @(posedge clk_tb); 
        operand1_tb = 16'd0; operand2_tb = 16'd8500; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |               0 | Zero Operand A", $time, operand1_tb, operand2_tb, final_result_tb);
        
        // Test Case 8: Multiply by Zero (B is zero)
        @(posedge clk_tb); 
        operand1_tb = -16'd12450; operand2_tb = 16'd0; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |               0 | Zero Operand B", $time, operand1_tb, operand2_tb, final_result_tb);
        
        // Test Case 9: Identity Multiplication
        @(posedge clk_tb); 
        operand1_tb = -16'd24000; operand2_tb = 16'd1; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |          -24000 | Identity Multiplication", $time, operand1_tb, operand2_tb, final_result_tb);
        
        // Test Case 10: Asymmetric Boundary (Max Pos * Max Neg)
        @(posedge clk_tb); 
        operand1_tb = 16'd32767; operand2_tb = -16'd32768; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %15d |     -1073709056 | Asymmetric Extremes", $time, operand1_tb, operand2_tb, final_result_tb);

        // =========================================================================================
        // DIVISION TESTS (QUOTIENT) (op_sel = 2'd1) - 16-BIT DATA
        // =========================================================================================
        $display("\n===================================================================================================");
        $display(" DIVISION TESTS (QUOTIENT OUTPUT) (op_sel = 1) - 16-BIT");
        $display("===================================================================================================");
        $display(" Time       | N (Divd)  | D (Divs)  | Result (Q)      | DBZ | Expected        | Test Case Type");
        $display("---------------------------------------------------------------------------------------------------");
        op_sel_tb = 2'd1; // Switch top module to Output Quotient

        // Test Case 11: 15000 / 40
        @(posedge clk_tb); 
        operand1_tb = 16'd15000; operand2_tb = 16'd40; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb); 
        $display(" %0t       | %9d | %9d | %15d |   %b |             375 | Positive / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 12: 15025 / 40
        @(posedge clk_tb); 
        operand1_tb = 16'd15025; operand2_tb = 16'd40; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |             375 | Fractional (R=25)", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 13: -15025 / 40
        @(posedge clk_tb); 
        operand1_tb = -16'd15025; operand2_tb = 16'd40; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |            -375 | Negative / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 14: 10000 / 0 (Divide By Zero)
        @(posedge clk_tb); 
        operand1_tb = 16'd10000; operand2_tb = 16'd0; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(err_dbz_tb); @(posedge clk_tb); 
        $display(" %0t       | %9d | %9d | %15d |   %b |               0 | DIVIDE BY ZERO ERROR", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 15: -25000 / -50
        @(posedge clk_tb); 
        operand1_tb = -16'd25000; operand2_tb = -16'd50; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |             500 | Negative / Negative", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 16: 0 / 1500 (Zero Dividend)
        @(posedge clk_tb); 
        operand1_tb = 16'd0; operand2_tb = 16'd1500; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |               0 | Zero Dividend", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 17: -32768 / -1 (16-bit Signed Division Overflow)
        @(posedge clk_tb); 
        operand1_tb = -16'd32768; operand2_tb = -16'd1; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |          -32768 | Overflow Hardware Edge Case", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // =========================================================================================
        // REMAINDER TESTS (op_sel = 2'd2) - 16-BIT DATA
        // =========================================================================================
        $display("\n===================================================================================================");
        $display(" DIVISION TESTS (REMAINDER OUTPUT) (op_sel = 2) - 16-BIT");
        $display("===================================================================================================");
        $display(" Time       | N (Divd)  | D (Divs)  | Result (R)      | DBZ | Expected        | Test Case Type");
        $display("---------------------------------------------------------------------------------------------------");
        op_sel_tb = 2'd2; // Switch top module to Output Remainder

        // Test Case 18: 15025 / 40 (Should output 25)
        @(posedge clk_tb); 
        operand1_tb = 16'd15025; operand2_tb = 16'd40; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |              25 | Positive / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 19: -15025 / 40 (Should output -25)
        @(posedge clk_tb); 
        operand1_tb = -16'd15025; operand2_tb = 16'd40; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |             -25 | Negative / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);
        
        // Test Case 20: 12000 / 0 (Divide By Zero on Remainder)
        @(posedge clk_tb); 
        operand1_tb = 16'd12000; operand2_tb = 16'd0; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(err_dbz_tb); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %15d |   %b |               0 | DIVIDE BY ZERO ERROR", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // End Simulation
        $display("===================================================================================================\n");
        #50 $finish;
    end

endmodule