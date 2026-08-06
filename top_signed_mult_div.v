module top_signed_mult_div #(parameter width = 8)(
    input  wire                             clk,      
    input  wire                             rst, 
    input  wire        [1:0]                op_sel, //multiplication =2'd0 , division = 2'd1 , remainder = 2'd2 

    input  wire signed [width-1:0] operand1,
    input  wire signed [width-1:0] operand2,

    //division inputs
    input  wire                             start,
    
   //output
    output reg  signed  [2*width-1:0] final_result,
    output wire                       busy,
    output wire                       done,
    output wire                       err_dbz
);
//division output internal signals 
wire                     div_dbz, div_busy, div_done;
wire                     mult_enable, div_enable, rem_enable ;
wire signed [width-1:0]  mult_in1, mult_in2, div_in1, div_in2, div_quotient, div_remainder ;
wire signed [2*width-1:0] mult_result ;

assign mult_in1 = mult_enable ? operand1 : 0 ;
assign mult_in2 = mult_enable ? operand2 : 0 ;

assign div_in1 = (div_enable || rem_enable) ? operand1 : 0 ;
assign div_in2 = (div_enable || rem_enable) ? operand2 : 0 ;

assign mult_enable = (op_sel==2'd0) ;
assign div_enable  = (op_sel==2'd1) ;
assign rem_enable  = (op_sel==2'd2) ;
/*
module multiplier (
    input                    clk,rst,
    input wire               enable,
    input wire signed [7:0]  A,B,
    
    output reg signed [15:0] sum
);
*/
multiplier u_multiplier(
    .clk(clk),
    .rst(rst),
    .enable(mult_enable),
    .A(mult_in1),
    .B(mult_in2),
    .sum(mult_result)
);

/*
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

*/
division_non #(.Number_of_bits(width)) u_division_non(
    .clk(clk),
    .rst(rst),
    .enable(div_enable || rem_enable),
    .start(start),
    .N(div_in1),
    .D(div_in2),
    .Q(div_quotient),
    .R(div_remainder),
    .busy(div_busy),
    .done(div_done),
    .DBZ(div_dbz)
);

always @(*)begin
    case(op_sel)
        2'd0 : final_result = mult_result ;
        2'd1 : final_result = {{width{div_quotient[width-1]}},div_quotient} ;
        2'd2 : final_result = {{width{div_remainder[width-1]}},div_remainder} ;
        default : final_result = 0 ; 
    endcase
end
assign busy    = (op_sel==2'd1 || op_sel==2'd2)  ? div_busy : 1'b0;
assign done    = (op_sel==2'd1 || op_sel==2'd2)  ? div_done : 1'b0;
assign err_dbz = (op_sel==2'd1 || op_sel==2'd2)  ? div_dbz  : 1'b0;

endmodule //signed_mult_div