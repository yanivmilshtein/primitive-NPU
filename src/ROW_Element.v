module ROW_Element #(
    parameter DW = 16
)(
    input clk,
    input rst,
    input start,

    // Inputs for the row (3 elements)
    input signed [DW-1:0] x0,
    input signed [DW-1:0] x1,
    input signed [DW-1:0] x2,

    // Weights for the row (3 elements)
    input signed [DW-1:0] w0,
    input signed [DW-1:0] w1,
    input signed [DW-1:0] w2,

    // Accumulator input (start value, usually 0 or previous partial sum)
    input signed [2*DW-1:0] acc_in,

    // Outputs from 3 MACs
    output signed [2*DW-1:0] acc0_out,
    output signed [2*DW-1:0] acc1_out,
    output signed [2*DW-1:0] acc2_out,
    output done
);

    // Done signals from each MAC
    wire done0, done1, done2;

    // Instantiate 3 MAC_Elements
    MAC_Element #(.DW(DW)) mac0 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_i(x0),
        .w_i(w0),
        .acc_in(acc_in),
        .acc_out(acc0_out),
        .done(done0)
    );

    MAC_Element #(.DW(DW)) mac1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_i(x1),
        .w_i(w1),
        .acc_in(acc_in),
        .acc_out(acc1_out),
        .done(done1)
    );

    MAC_Element #(.DW(DW)) mac2 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_i(x2),
        .w_i(w2),
        .acc_in(acc_in),
        .acc_out(acc2_out),
        .done(done2)
    );

    // For simplicity: overall "done" when all 3 MACs are done
    assign done = done0 & done1 & done2;

endmodule
