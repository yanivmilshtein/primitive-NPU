module controller #(
    parameter DW = 16
)(
    input clk,
    input rst,
    input start,

    // Input vector (x0,x1,x2)
    input signed [DW-1:0] x0,
    input signed [DW-1:0] x1,
    input signed [DW-1:0] x2,

    // Weight matrix W (3x3)
    input signed [DW-1:0] w00, input signed [DW-1:0] w01, input signed [DW-1:0] w02,
    input signed [DW-1:0] w10, input signed [DW-1:0] w11, input signed [DW-1:0] w12,
    input signed [DW-1:0] w20, input signed [DW-1:0] w21, input signed [DW-1:0] w22,

    // Bias vector b
    input signed [2*DW-1:0] b0,
    input signed [2*DW-1:0] b1,
    input signed [2*DW-1:0] b2,

    // Final output vector y = ReLU(Wx + b)
    output signed [2*DW-1:0] y0,
    output signed [2*DW-1:0] y1,
    output signed [2*DW-1:0] y2,

    output done
);

    // Row outputs before bias/ReLU
    wire signed [2*DW-1:0] r0_0, r0_1, r0_2;
    wire signed [2*DW-1:0] r1_0, r1_1, r1_2;
    wire signed [2*DW-1:0] r2_0, r2_1, r2_2;

    wire done0, done1, done2;

    // =========================
    // Row 0: dot product x * W[0,:]
    // =========================
    ROW_Element #(.DW(DW)) row0 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x0(x0), .x1(x1), .x2(x2),
        .w0(w00), .w1(w01), .w2(w02),
        .acc_in(0),
        .acc0_out(r0_0), .acc1_out(r0_1), .acc2_out(r0_2),
        .done(done0)
    );

    // =========================
    // Row 1
    // =========================
    ROW_Element #(.DW(DW)) row1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x0(x0), .x1(x1), .x2(x2),
        .w0(w10), .w1(w11), .w2(w12),
        .acc_in(0),
        .acc0_out(r1_0), .acc1_out(r1_1), .acc2_out(r1_2),
        .done(done1)
    );

    // =========================
    // Row 2
    // =========================
    ROW_Element #(.DW(DW)) row2 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x0(x0), .x1(x1), .x2(x2),
        .w0(w20), .w1(w21), .w2(w22),
        .acc_in(0),
        .acc0_out(r2_0), .acc1_out(r2_1), .acc2_out(r2_2),
        .done(done2)
    );

    // =========================
    // Combine partials into dot products
    // (sum of 3 outputs per row)
    // =========================
    wire signed [2*DW-1:0] dot0 = r0_0 + r0_1 + r0_2 + b0;
    wire signed [2*DW-1:0] dot1 = r1_0 + r1_1 + r1_2 + b1;
    wire signed [2*DW-1:0] dot2 = r2_0 + r2_1 + r2_2 + b2;

    // =========================
    // ReLU activation
    // =========================
    assign y0 = (dot0 > 0) ? dot0 : 0;
    assign y1 = (dot1 > 0) ? dot1 : 0;
    assign y2 = (dot2 > 0) ? dot2 : 0;

    // =========================
    // Done flag (all rows done)
    // =========================
    assign done = done0 & done1 & done2;

endmodule
