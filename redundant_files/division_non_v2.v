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
module division_non #(parameter Number_of_bits = 8)
(
    input  wire                             clk,      
    input  wire                             rst,
    input  wire                             enable,      
    input  wire                             start,
    input  wire signed [Number_of_bits-1:0] N,
    input  wire signed [Number_of_bits-1:0] D,

    output reg signed  [Number_of_bits-1:0] Q,
    output reg signed  [Number_of_bits-1:0] R,
    output reg                              busy,
    output reg                              done,
    output reg                              DBZ

);

    localparam IDLE = 1'b0, RUN = 1'b1;

    reg state;                                        
    reg signed [Number_of_bits:0]   A;        // Increased by 1 bit for non-restoring carry/sign
    reg signed [Number_of_bits-1:0] N_reg;
    reg signed [Number_of_bits-1:0] D_reg; 
                                   
    integer count;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            A     <= 0;
            N_reg <= 0;
            D_reg <= 0;
            Q     <= 0;
            R     <= 0;
            busy  <= 0;
            done  <= 0;
            DBZ   <= 0;
            count <= 0;
            state <= IDLE;
        end
        else if (enable) begin
            done <= 1'b0;

            case(state)
                IDLE: begin
                    busy <= 1'b0;
                    if(start) begin
                        A     <= 0;
                        count <= Number_of_bits;
                        busy  <= 1'b1;
                        state <= RUN;
                        
                        // Check Divide by Zero
                        if (D == 0) begin
                            DBZ <= 1'b1;
                            busy <= 1'b0;
                            Q <= 0 ;
                            R <= 0 ;
                            state <= IDLE;
                        end
                        else begin
                            DBZ <= 1'b0;
                            // Pre-processing: Absolute values setup
                            case({N[Number_of_bits-1], D[Number_of_bits-1]})
                                2'b10: begin
                                    N_reg <= -N;
                                    D_reg <= D;   
                                end
                                2'b01: begin
                                    N_reg <= N;
                                    D_reg <= -D;   
                                end
                                2'b11: begin
                                    N_reg <= -N;
                                    D_reg <= -D;   
                                end
                                default: begin
                                    N_reg <= N;
                                    D_reg <= D;   
                                end 
                            endcase
                        end
                    end
                end

                RUN: begin               
                    if (count > 0) begin
                        // Shift & Add/Sub step (using D_reg instead of D)
                        A = {A[Number_of_bits-1:0], N_reg[Number_of_bits-1]};
                        N_reg = N_reg << 1;
                        
                        if(A[Number_of_bits] == 1'b1)
                            A = A + D_reg;
                        else
                            A = A - D_reg;
                            
                        if(A[Number_of_bits] == 1'b1)
                            N_reg = {N_reg[Number_of_bits-1:1], 1'b0};
                        else
                            N_reg = {N_reg[Number_of_bits-1:1], 1'b1};

                        count = count - 1;
                    end
                    else begin
                        // Final correction if A is negative
                        if(A[Number_of_bits] == 1'b1)
                            A = A + D_reg;

                        // Post-processing: Sign Calculation & Output Assignment
                        case({N[Number_of_bits-1], D[Number_of_bits-1]})
                            2'b10: begin
                                Q <= -N_reg;
                                R <= -A[Number_of_bits-1:0];   
                            end
                            2'b01: begin
                                Q <= -N_reg;
                                R <= A[Number_of_bits-1:0];   
                            end
                            2'b11: begin
                                Q <= N_reg;
                                R <= -A[Number_of_bits-1:0];   
                            end
                            default: begin
                                Q <= N_reg;
                                R <= A[Number_of_bits-1:0];
                            end                       
                        endcase
                        
                        busy  <= 1'b0;
                        done  <= 1'b1;
                        state <= IDLE;
                    end
                end

                default:
                    state <= IDLE;
            endcase
        end
    end
endmodule