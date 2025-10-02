`timescale 1ns/1ps

module tb_MAC_Element();

	// Parameters must match the DUT default parameter
	parameter DW = 16;

	// Testbench signals
	reg clk;
	reg rst;
	reg start;
	reg signed [DW-1:0] x_i;
	reg signed [DW-1:0] w_i;
	reg signed [2*DW-1:0] acc_in;
	wire signed [2*DW-1:0] acc_out;
	wire signed [2*DW-1:0] product_tb;
	wire done;

	// Instantiate Device Under Test
	MAC_Element #(.DW(DW)) uut (
		.clk(clk),
		.rst(rst),
		.start(start),
		.x_i(x_i),
		.w_i(w_i),
		.acc_in(acc_in),
		.acc_out(acc_out),
		.done(done)
	);

	// Testbench local product calculation for display (same as internal product)
	assign product_tb = x_i * w_i;

	// Clock generation: 10ns period (5ns high, 5ns low)
	initial begin
		clk = 0;
	end
	always #5 clk = ~clk;

	// Test sequence
	initial begin
		// Waveform dump (useful when running with a simulator)
		$display("Starting MAC_Element testbench...");
		$dumpfile("tb_MAC_Element.vcd");
		$dumpvars(0, tb_MAC_Element);

		// Header for human-readable prints
		$display("time\tclk rst start x_i w_i product acc_in acc_out done");

		// Initialize signals
		rst = 0;
		start = 0;
		x_i = 0;
		w_i = 0;
		acc_in = 0;

		// Allow two negative edges to let internal regs settle
		repeat (2) @(negedge clk);

		// 1) Simple MAC: acc_out = 0 + (3 * 4) = 12
		x_i = 16'sd3;
		w_i = 16'sd4;
		acc_in = 32'sd0;
		start = 1;               // assert start before negedge so DUT samples it
		@(negedge clk);          // operation happens here
		// print the result immediately after the negedge where operation occurred
		$display("%0t\t%b   %b    %0d    %0d     %0d     %0d      %0d    %b", $time, clk, rst, start, x_i, w_i, product_tb, acc_in, acc_out, done);
		start = 0;

		// Wait a cycle to observe stable outputs
		@(negedge clk);

		// 2) Accumulate: feed previous acc_out back into acc_in and add (2 * 5) = 10
		acc_in = acc_out;        // capture previous result (12)
		x_i = 16'sd2;
		w_i = 16'sd5;
		start = 1;
		@(negedge clk);          // acc_out <= acc_in + (2*5) => 12 + 10 = 22
		$display("%0t\t%b   %b    %0d    %0d     %0d     %0d      %0d    %b", $time, clk, rst, start, x_i, w_i, product_tb, acc_in, acc_out, done);
		start = 0;

		@(negedge clk);

		// 3) Show done behavior when start is low
		x_i = 16'sd7;
		w_i = 16'sd7;
		acc_in = acc_out;        // 22
		// no start asserted here, so nothing should change and done==0
		@(negedge clk);
		$display("%0t\t%b   %b    %0d    %0d     %0d     %0d      %0d    %b  (no-start)", $time, clk, rst, start, x_i, w_i, product_tb, acc_in, acc_out, done);

		// 4) Test reset falling-edge behavior: per DUT, falling edge of rst clears acc_out and done
		// To create a falling edge we assert rst=1 for a cycle then deassert it to 0
		rst = 1;
		@(negedge clk); // rst_prev will be set to 1 inside DUT
		rst = 0;         // falling edge now exists (1 -> 0)
		@(negedge clk);  // DUT should detect falling edge and clear acc_out, done
		$display("%0t\t%b   %b    %0d    %0d     %0d     %0d      %0d    %b  (after reset)", $time, clk, rst, start, x_i, w_i, product_tb, acc_in, acc_out, done);

		// Final wait and finish
		#20;
		$display("Testbench finished.");
		$finish;
	end

	// Also print a monitored line whenever any of these signals change
	initial begin
		$monitor("%0t | clk=%b rst=%b start=%b x=%0d w=%0d prod=%0d acc_in=%0d acc_out=%0d done=%b", $time, clk, rst, start, x_i, w_i, product_tb, acc_in, acc_out, done);
	end

endmodule

