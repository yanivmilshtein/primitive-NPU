module MAC_Element #(
    parameter DW = 16
)
(
    input clk,
    input rst,  // active-high reset button
    input start,
    input signed [DW-1:0] x_i,
    input signed [DW-1:0] w_i,
    input signed [2*DW-1:0] acc_in,
    output reg signed [2*DW-1:0] acc_out,
    output reg done
);

    (* altera_attribute = "-name MULT_STYLE DSP" *)
    wire signed [2*DW-1:0] product;
    assign product = x_i * w_i;

    // registers to track previous reset state (to detect falling edge)
    reg rst_prev;

    always @(negedge clk) begin
        rst_prev <= rst;  // remember previous reset
        if (rst_prev & ~rst) begin
            // falling edge of reset (1 -> 0)
            acc_out <= 0;
            done <= 0;
        end
        else if (start) begin
            acc_out <= acc_in + product;
            done <= 1;
        end
        else begin
            done <= 0;
        end
    end
endmodule
