//==============================================================================
// Module      : division_non
// Description :
//   Parameterizable signed divider implementing the Non-Restoring Division
//   algorithm. The divider performs one iteration per clock cycle.
//   Signed operands are converted to their absolute values before the division,
//   then the quotient and remainder signs are corrected after completion.
//
// Parameters:
// Number_of_bits : Width of the dividend and divisor (default = 8 bits).
//
// Inputs:
//   clk    : System clock.
//   rst    : Active-low asynchronous reset.
//   enable : Clock gating signal to isolate dynamic power.
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

    reg                             state, next_state;                                        
    reg signed [Number_of_bits:0]   A, next_A;        
    reg signed [Number_of_bits-1:0] N_reg, next_N_reg;
    reg signed [Number_of_bits-1:0] D_reg, next_D_reg;                          
    reg [7:0]                       count, next_count;
    
    reg [1:0]                       saved_signs; // Protects against changing inputs


    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            A           <= 0;
            N_reg       <= 0;
            D_reg       <= 0;
            Q           <= 0;
            R           <= 0;
            busy        <= 0;
            done        <= 0;
            DBZ         <= 0;
            count       <= 0;
            saved_signs <= 2'b00;
            state       <= IDLE;
        end
        else if (enable) begin
            state <= next_state;
            A     <= next_A;
            N_reg <= next_N_reg;
            D_reg <= next_D_reg;
            count <= next_count;
            
            // Output control registers
            if (state == IDLE && start && (D != 0)) begin
                busy        <= 1'b1;
                DBZ         <= 1'b0;
                done        <= 1'b0;
                saved_signs <= {N[Number_of_bits-1], D[Number_of_bits-1]};
            end
            else if (state == IDLE && start && (D == 0)) begin
                DBZ   <= 1'b1;
                busy  <= 1'b0;
                done  <= 1'b1;
                Q     <= 0;
                R     <= 0;
            end
            else if (next_state == IDLE && state == RUN) begin
                busy <= 1'b0;
                done <= 1'b1;
                
                // Cleaned up redundant if/else block using the safely latched signs
                case(saved_signs)
                    2'b10:     begin Q <= -next_N_reg; R <= -next_A[Number_of_bits-1:0]; end
                    2'b01:     begin Q <= -next_N_reg; R <=  next_A[Number_of_bits-1:0]; end
                    2'b11:     begin Q <=  next_N_reg; R <= -next_A[Number_of_bits-1:0]; end
                    default:   begin Q <=  next_N_reg; R <=  next_A[Number_of_bits-1:0]; end
                endcase
            end
            else begin
                done <= 1'b0;
            end
        end
    end


    always @(*) begin

        next_state = state;
        next_A     = A;
        next_N_reg = N_reg;
        next_D_reg = D_reg;
        next_count = count;

        case(state)
            IDLE: begin
                if(start) begin
                    if (D != 0) begin
                        next_A     = 0;
                        next_count = Number_of_bits;
                        next_state = RUN;
                        
                        case({N[Number_of_bits-1], D[Number_of_bits-1]})
                            2'b10:   begin next_N_reg = -N; next_D_reg =  D; end
                            2'b01:   begin next_N_reg =  N; next_D_reg = -D; end
                            2'b11:   begin next_N_reg = -N; next_D_reg = -D; end
                            default: begin next_N_reg =  N; next_D_reg =  D; end 
                        endcase
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end

            RUN: begin               
                if (count > 0) begin
                    next_A     = {A[Number_of_bits-1:0], N_reg[Number_of_bits-1]};
                    next_N_reg = N_reg << 1;
                    
                    if(next_A[Number_of_bits] == 1'b1)
                        next_A = next_A + D_reg;
                    else
                        next_A = next_A - D_reg;
                        
                    if(next_A[Number_of_bits] == 1'b1)
                        next_N_reg = {next_N_reg[Number_of_bits-1:1], 1'b0};
                    else
                        next_N_reg = {next_N_reg[Number_of_bits-1:1], 1'b1};

                    next_count = count - 1;
                end
                else begin
                    if(next_A[Number_of_bits] == 1'b1)
                        next_A = next_A + D_reg;
                    
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule