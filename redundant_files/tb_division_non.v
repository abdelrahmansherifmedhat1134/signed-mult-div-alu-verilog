//==============================================================================
// Module      : divider
// Description :
//   Parameterizable signed divider implementing the Non-Restoring Division
//   algorithm. The divider performs one iteration per clock cycle.
//   Signed operands are converted to their absolute values before the division,
//   then the quotient and remainder signs are corrected after completion.
//
// Parameters:
//   Number_of_bits : Width of the dividend and divisor (default = 8 bits).
//
// Inputs:
//   clk    : System clock.
//   rst    : Active-low asynchronous reset.
//   start  : One-clock-cycle pulse to start the division operation.
//   N      : Signed dividend.
//   D      : Signed divisor.
//
// Outputs:
//   Q      : Signed quotient.
//   R      : Signed remainder.
//   busy   : High while the division is in progress.
//   done   : One-clock-cycle pulse indicating that the result is valid.
//   DBZ    : Divide-by-zero flag. Asserted when the divisor is zero.
//
// Operation:
//   1. Check for divide-by-zero.
//   2. Convert operands to their absolute values.
//   3. Execute one Non-Restoring division iteration per clock cycle.
//   4. Restore the remainder if required.
//   5. Correct the signs of the quotient and remainder.
//==============================================================================



`timescale 1ns/1ps


module tb_division_non #(parameter Number_of_bits_tb = 8);

reg                                 clk_tb, rst_tb, start_tb ;
reg signed  [Number_of_bits_tb-1:0] N_tb, D_tb ;
wire signed [Number_of_bits_tb-1:0] Q_tb, R_tb ;
wire                                done_tb, busy_tb ;
wire                                DBZ_tb ;

division_non #(Number_of_bits_tb) DUT(
    .clk(clk_tb),
    .rst(rst_tb),
    .start(start_tb),
    .N(N_tb),
    .D(D_tb),
    .Q(Q_tb),
    .R(R_tb),
    .busy(busy_tb),
    .done(done_tb),
    .DBZ(DBZ_tb)
);

initial begin
    clk_tb = 0 ;
    forever #10 clk_tb = ~clk_tb ;
end

initial begin
    rst_tb = 0 ;
    N_tb = 0;
    D_tb = 0;
    start_tb = 0 ;

    $monitor("Time = %0t | rst = %b | N = %d, D = %d | quotient = %d | remainder = %d | DBZ = %b", $time, rst_tb, N_tb, D_tb, Q_tb, R_tb, DBZ_tb   );

    #20 rst_tb = 1 ;
    #10 ;
    $display("-----------------------------------------") ;
    $display("starting signed divisor tests") ;
    $display("-----------------------------------------") ;
    
    @(posedge clk_tb) ;
    $display("first test case ===> (20 / 5)") ;
    N_tb = 8'd20 ;
    D_tb = 8'd5 ;
    start_tb = 1 ;

    @(posedge clk_tb) ;
    start_tb =0 ;
    wait(busy_tb == 1) ;
    wait(busy_tb == 0) ;
    @(posedge clk_tb) ;

    //rest of test cases
    $display("second test case ===> (23 / 5)") ;
    N_tb = 8'd23 ;
    D_tb = 8'd5 ;
    start_tb = 1 ;

    @(posedge clk_tb) ;
    start_tb =0 ;
    wait(busy_tb == 1) ;
    wait(busy_tb == 0) ;
    @(posedge clk_tb) ;

    $display("third test case ===> (-23 / 5)") ;
    N_tb = -8'd23 ;
    D_tb = 8'd5 ;
    start_tb = 1 ;

    @(posedge clk_tb) ;
    start_tb =0 ;
    wait(busy_tb == 1) ;
    wait(busy_tb == 0) ;
    @(posedge clk_tb) ;

    $display("fourth test case ===> (10 / 0)") ;
    N_tb = 8'd10 ;
    D_tb = 8'd0 ;
    start_tb = 1 ;

    @(posedge clk_tb) ;
    start_tb =0 ;
    wait(DBZ_tb) ;
    @(posedge clk_tb) ;

    $finish ;

end
endmodule //tb_division_non