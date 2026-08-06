module combinational_v1 #(parameter N=16)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [2*N-1:0] product
);

integer i ;
always @(*) begin
    for(i=0;i<N;i=i+1) begin
        if(b[i]) begin
            product = product + (a << i);
        end
    end

endmodule //combinational_v1