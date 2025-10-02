`timescale 1ns/1ps

module tb_controller;

    parameter DW = 16;

    // Testbench signals
    reg clk;
    reg rst;
    reg start;

    reg signed [DW-1:0] x0, x1, x2;

    // Weight matrix
    reg signed [DW-1:0] w00, w01, w02;
    reg signed [DW-1:0] w10, w11, w12;
    reg signed [DW-1:0] w20, w21, w22;

    // Biases
    reg signed [2*DW-1:0] b0, b1, b2;

    // Outputs
    wire signed [2*DW-1:0] y0, y1, y2;
    wire done;

    // Expected values
    reg signed [2*DW-1:0] dot0_exp, dot1_exp, dot2_exp;
    reg signed [2*DW-1:0] y0_exp, y1_exp, y2_exp;

    // Instantiate controller
    controller #(.DW(DW)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x0(x0), .x1(x1), .x2(x2),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),
        .b0(b0), .b1(b1), .b2(b2),
        .y0(y0), .y1(y1), .y2(y2),
        .done(done)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Waveform dump for supported simulators
        $dumpfile("tb_controller.vcd");
        $dumpvars(0, tb_controller);

        // Initialize
        rst = 1;
        start = 0;
        x0 = 0; x1 = 0; x2 = 0;
        w00=0; w01=0; w02=0;
        w10=0; w11=0; w12=0;
        w20=0; w21=0; w22=0;
        b0 = 0; b1 = 0; b2 = 0;

        #20;
        // Deassert reset (design uses falling-edge detection in MACs)
        rst = 0;
        #10;

        // --------------------
        // Scenario 1: mixed outputs (some positive, some zero after ReLU)
        // --------------------
        x0 = 3; x1 = 2; x2 = 1;

        // Row 0: y0 = ReLU(3*4 + 2*5 + 1*6 + b0) = ReLU(28 + b0)
        w00 = 4; w01 = 5; w02 = 6; b0 = 0;

        // Row 1: y1 = ReLU(3*(-1) + 2*2 + 1*3 + b1) = ReLU(-3 +4 +3 + b1) = ReLU(4 + b1)
        w10 = -1; w11 = 2; w12 = 3; b1 = -10; // make negative to test ReLU -> 0

        // Row 2: y2 = ReLU(3*1 + 2*1 + 1*1 + b2) = ReLU(6 + b2)
        w20 = 1; w21 = 1; w22 = 1; b2 = 5;

        // Compute expected values in TB (signed arithmetic)
        dot0_exp = x0*w00 + x1*w01 + x2*w02 + b0;
        dot1_exp = x0*w10 + x1*w11 + x2*w12 + b1;
        dot2_exp = x0*w20 + x1*w21 + x2*w22 + b2;

        y0_exp = (dot0_exp > 0) ? dot0_exp : 0;
        y1_exp = (dot1_exp > 0) ? dot1_exp : 0;
        y2_exp = (dot2_exp > 0) ? dot2_exp : 0;

        // Pulse start
        #3; start = 1; #10; start = 0;

        // Wait for done
        wait (done == 1);
        #1;

        $display("--- CONTROLLER TEST: SCENARIO 1 ---");
        $display("Inputs: x = [%0d %0d %0d]", x0, x1, x2);
        $display("Weights row0: %0d %0d %0d, bias=%0d -> dot0_expected=%0d y0_expected=%0d", w00,w01,w02,b0, dot0_exp, y0_exp);
        $display("Weights row1: %0d %0d %0d, bias=%0d -> dot1_expected=%0d y1_expected=%0d", w10,w11,w12,b1, dot1_exp, y1_exp);
        $display("Weights row2: %0d %0d %0d, bias=%0d -> dot2_expected=%0d y2_expected=%0d", w20,w21,w22,b2, dot2_exp, y2_exp);
        $display("Controller outputs: y0=%0d y1=%0d y2=%0d (done=%0b)", y0, y1, y2, done);

        // Compare and report mismatches
        if (y0 !== y0_exp) $display("MISMATCH y0: expected %0d got %0d", y0_exp, y0);
        else $display("OK y0");
        if (y1 !== y1_exp) $display("MISMATCH y1: expected %0d got %0d", y1_exp, y1);
        else $display("OK y1");
        if (y2 !== y2_exp) $display("MISMATCH y2: expected %0d got %0d", y2_exp, y2);
        else $display("OK y2");

        #20;

        // --------------------
        // Scenario 2: force negative dots so ReLU zeros them
        // --------------------
        x0 = 4; x1 = 4; x2 = -1;

        w00 = -2; w01 = -3; w02 = -4; b0 = -50; // large negative
        w10 = -1; w11 = -1; w12 = -1; b1 = -5;
        w20 = 1; w21 = -2; w22 = -3; b2 = -10;

        dot0_exp = x0*w00 + x1*w01 + x2*w02 + b0;
        dot1_exp = x0*w10 + x1*w11 + x2*w12 + b1;
        dot2_exp = x0*w20 + x1*w21 + x2*w22 + b2;

        y0_exp = (dot0_exp > 0) ? dot0_exp : 0;
        y1_exp = (dot1_exp > 0) ? dot1_exp : 0;
        y2_exp = (dot2_exp > 0) ? dot2_exp : 0;

        // Pulse start again
        #3; start = 1; #10; start = 0;

        wait (done == 1);
        #1;

        $display("--- CONTROLLER TEST: SCENARIO 2 ---");
        $display("Inputs: x = [%0d %0d %0d]", x0, x1, x2);
        $display("dot0_expected=%0d y0_expected=%0d  |  y0_actual=%0d", dot0_exp, y0_exp, y0);
        $display("dot1_expected=%0d y1_expected=%0d  |  y1_actual=%0d", dot1_exp, y1_exp, y1);
        $display("dot2_expected=%0d y2_expected=%0d  |  y2_actual=%0d", dot2_exp, y2_exp, y2);

        if (y0 !== y0_exp) $display("MISMATCH y0: expected %0d got %0d", y0_exp, y0); else $display("OK y0");
        if (y1 !== y1_exp) $display("MISMATCH y1: expected %0d got %0d", y1_exp, y1); else $display("OK y1");
        if (y2 !== y2_exp) $display("MISMATCH y2: expected %0d got %0d", y2_exp, y2); else $display("OK y2");

        #10;
        $display("Controller testbench finished.");
        $finish;
    end

endmodule
