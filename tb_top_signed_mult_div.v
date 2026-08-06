`timescale 1ns/1ps

module tb_top_signed_mult_div #(parameter width_tb = 8);

    // 1. Declare Signals for Top Module[cite: 8]
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

    // 2. Instantiate the Top Module[cite: 8]
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
        // Initialization[cite: 6, 7]
        rst_tb = 0;
        start_tb = 0;
        op_sel_tb = 2'd0;
        operand1_tb = 0;
        operand2_tb = 0;

        #15 rst_tb = 1; // Release reset[cite: 7]
        #10;

        // =========================================================================================
        // MULTIPLICATION TESTS (op_sel = 2'd0)[cite: 7, 8]
        // =========================================================================================
        $display("\n=========================================================================================");
        $display(" MULTIPLICATION TESTS (op_sel = 0)");
        $display("=========================================================================================");
        $display(" Time       | Operand A | Operand B | Final Result | Expected     | Test Case Type");
        $display("-----------------------------------------------------------------------------------------");
        op_sel_tb = 2'd0; // Lock top module to multiplication[cite: 8]

        // Test Case 1: Positive * Positive[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = 8'd10; operand2_tb = 8'd5;   
        @(posedge clk_tb); #1; // Wait 1 cycle for D-FF + 1ns delay for simulator[cite: 7]
        $display(" %0t       | %9d | %9d | %12d |           50 | Positive * Positive", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 2: Negative * Positive[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = -8'd10; operand2_tb = 8'd5;  
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |          -50 | Negative * Positive", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 3: Positive * Negative[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = 8'd12; operand2_tb = -8'd3;  
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |          -36 | Positive * Negative", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 4: Negative * Negative[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = -8'd7; operand2_tb = -8'd6;  
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |           42 | Negative * Negative", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 5: Maximum Positive Values[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = 8'd127; operand2_tb = 8'd127; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |        16129 | Max Positive Boundary", $time, operand1_tb, operand2_tb, final_result_tb);
            
        // Test Case 6: Maximum Negative Values[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = -8'd128; operand2_tb = -8'd128; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |        16384 | Max Negative Boundary", $time, operand1_tb, operand2_tb, final_result_tb);

        // Test Case 7: Multiply by Zero (A is zero)[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = 8'd0; operand2_tb = 8'd55; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |            0 | Zero Operand A", $time, operand1_tb, operand2_tb, final_result_tb);
        
        // Test Case 8: Multiply by Zero (B is zero)[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = -8'd89; operand2_tb = 8'd0; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |            0 | Zero Operand B", $time, operand1_tb, operand2_tb, final_result_tb);
        
        // Test Case 9: Identity Multiplication[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = -8'd115; operand2_tb = 8'd1; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |         -115 | Identity Multiplication", $time, operand1_tb, operand2_tb, final_result_tb);
        
        // Test Case 10: Asymmetric Boundary (Max Pos * Max Neg)[cite: 7]
        @(posedge clk_tb); 
        operand1_tb = 8'd127; operand2_tb = -8'd128; 
        @(posedge clk_tb); #1;
        $display(" %0t       | %9d | %9d | %12d |       -16256 | Asymmetric Extremes", $time, operand1_tb, operand2_tb, final_result_tb);

        // =========================================================================================
        // DIVISION TESTS (QUOTIENT) (op_sel = 2'd1)[cite: 6, 8]
        // =========================================================================================
        $display("\n=========================================================================================");
        $display(" DIVISION TESTS (QUOTIENT OUTPUT) (op_sel = 1)");
        $display("=========================================================================================");
        $display(" Time       | N (Divd)  | D (Divs)  | Result (Q)   | DBZ | Expected     | Test Case Type");
        $display("-----------------------------------------------------------------------------------------");
        op_sel_tb = 2'd1; // Switch top module to Output Quotient[cite: 8]

        // Test Case 11: 20 / 5[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = 8'd20; operand2_tb = 8'd5; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb); // Multi-cycle wait logic[cite: 6]
        $display(" %0t       | %9d | %9d | %12d |   %b |            4 | Positive / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 12: 23 / 5[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = 8'd23; operand2_tb = 8'd5; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |            4 | Fractional (R=3)", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 13: -23 / 5[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = -8'd23; operand2_tb = 8'd5; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |           -4 | Negative / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 14: 10 / 0 (Divide By Zero)[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = 8'd10; operand2_tb = 8'd0; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(err_dbz_tb); @(posedge clk_tb); // DBZ triggers instantly, wait for flag[cite: 6]
        $display(" %0t       | %9d | %9d | %12d |   %b |            0 | DIVIDE BY ZERO ERROR", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 15: -23 / -5[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = -8'd23; operand2_tb = -8'd5; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |            4 | Negative / Negative", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 16: 0 / 15 (Zero Dividend)[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = 8'd0; operand2_tb = 8'd15; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |            0 | Zero Dividend", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 17: -128 / -1 (Signed Division Overflow)[cite: 6]
        @(posedge clk_tb); 
        operand1_tb = -8'd128; operand2_tb = -8'd1; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |         -128 | Overflow Hardware Edge Case", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // =========================================================================================
        // REMAINDER TESTS (op_sel = 2'd2)[cite: 8]
        // =========================================================================================
        $display("\n=========================================================================================");
        $display(" DIVISION TESTS (REMAINDER OUTPUT) (op_sel = 2)");
        $display("=========================================================================================");
        $display(" Time       | N (Divd)  | D (Divs)  | Result (R)   | DBZ | Expected     | Test Case Type");
        $display("-----------------------------------------------------------------------------------------");
        op_sel_tb = 2'd2; // Switch top module to Output Remainder[cite: 8]

        // Test Case 18: 23 / 5 (Should output 3)[cite: 6, 8]
        @(posedge clk_tb); 
        operand1_tb = 8'd23; operand2_tb = 8'd5; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |            3 | Positive / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // Test Case 19: -23 / 5 (Should output -3)[cite: 6, 8]
        @(posedge clk_tb); 
        operand1_tb = -8'd23; operand2_tb = 8'd5; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(busy_tb == 1); wait(busy_tb == 0); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |           -3 | Negative / Positive", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);
        
        // Test Case 20: 10 / 0 (Divide By Zero on Remainder)[cite: 6, 8]
        @(posedge clk_tb); 
        operand1_tb = 8'd10; operand2_tb = 8'd0; start_tb = 1;
        @(posedge clk_tb); start_tb = 0;
        wait(err_dbz_tb); @(posedge clk_tb);
        $display(" %0t       | %9d | %9d | %12d |   %b |            0 | DIVIDE BY ZERO ERROR", $time, operand1_tb, operand2_tb, final_result_tb, err_dbz_tb);

        // End Simulation
        $display("=========================================================================================\n");
        #50 $finish;
    end

endmodule