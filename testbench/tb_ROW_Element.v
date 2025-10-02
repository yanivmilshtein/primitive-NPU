`timescale 1ns/1ps

module tb_ROW_Element;

    parameter DW = 16;

    // Testbench signals
    reg clk;
    reg rst;
    reg start;

    reg signed [DW-1:0] x0, x1, x2;
    reg signed [DW-1:0] w0, w1, w2;
    reg signed [2*DW-1:0] acc_in;

    wire signed [2*DW-1:0] acc0_out, acc1_out, acc2_out;
    wire done;

    // Instantiate unit under test
    ROW_Element #(.DW(DW)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .w0(w0),
        .w1(w1),
        .w2(w2),
        .acc_in(acc_in),
        .acc0_out(acc0_out),
        .acc1_out(acc1_out),
        .acc2_out(acc2_out),
        .done(done)
    );

    // Clock: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequences
    initial begin
        // Setup waveform dump (for simulators that support it)
        $dumpfile("tb_ROW_Element.vcd");
        $dumpvars(0, tb_ROW_Element);

        // Initial values
        rst = 1;
        start = 0;
        x0 = 0; x1 = 0; x2 = 0;
        w0 = 0; w1 = 0; w2 = 0;
        acc_in = 0;

        // Wait a few cycles so rst_prev in MACs captures a 1
        #20;

        // Deassert reset (this falling-edge-aware design resets on the falling-edge captured in negedge clock blocks)
        rst = 0;
        #10; // allow reset propagation on a clock edge

        // SCENARIO 1: acc_in = 0
        // Load vectors and weights
        x0 = 16'sd3;   // x0 = 3
        x1 = -16'sd2;  // x1 = -2
        x2 = 16'sd7;   // x2 = 7

        w0 = 16'sd4;   // w0 = 4
        w1 = 16'sd5;   // w1 = 5
        w2 = -16'sd1;  // w2 = -1

        acc_in = 32'sd0; // acc_in = 0 for first scenario

        // Pulse start for one cycle so MACs capture and compute on next negedge
        #3; // align a bit before a negedge
        start = 1;
        #10;
        start = 0;

        // Wait for done
        wait (done == 1);
        #1; // settle

        // Display MAC outputs and internal products (via hierarchical access)
        $display("--- SCENARIO 1 (acc_in = 0) ---");
        $display("x0=%0d w0=%0d product0=%0d acc0_out=%0d", x0, w0, uut.mac0.product, acc0_out);
        $display("x1=%0d w1=%0d product1=%0d acc1_out=%0d", x1, w1, uut.mac1.product, acc1_out);
        $display("x2=%0d w2=%0d product2=%0d acc2_out=%0d", x2, w2, uut.mac2.product, acc2_out);
        $display("overall_done=%0b (MACs: %0b %0b %0b)", done, uut.mac0.done, uut.mac1.done, uut.mac2.done);

        // Also show the sum of MAC outputs (sum of products when acc_in==0)
        $display("sum_of_products = %0d", acc0_out + acc1_out + acc2_out);

        // Small pause before next scenario
        #20;

        // SCENARIO 2: acc_in != 0 (non-zero accumulator input)
        acc_in = 32'sd100; // some previous partial sum

        // Change inputs slightly to validate behavior
        x0 = 16'sd2; x1 = 16'sd2; x2 = 16'sd2;
        w0 = 16'sd10; w1 = -16'sd3; w2 = 16'sd4;

        // Pulse start again
        #3;
        start = 1;
        #10;
        start = 0;

        // Wait for done
        wait (done == 1);
        #1;

        $display("--- SCENARIO 2 (acc_in != 0) ---");
        $display("acc_in = %0d", acc_in);
        $display("x0=%0d w0=%0d product0=%0d acc0_out=%0d", x0, w0, uut.mac0.product, acc0_out);
        $display("x1=%0d w1=%0d product1=%0d acc1_out=%0d", x1, w1, uut.mac1.product, acc1_out);
        $display("x2=%0d w2=%0d product2=%0d acc2_out=%0d", x2, w2, uut.mac2.product, acc2_out);
        $display("overall_done=%0b (MACs: %0b %0b %0b)", done, uut.mac0.done, uut.mac1.done, uut.mac2.done);
        $display("sum_of_accs = %0d", acc0_out + acc1_out + acc2_out);

        #10;
        $display("Testbench finished.");
        $finish;
    end

endmodule
