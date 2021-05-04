`default_nettype none
`timescale 1ns/1ps
module edge_detect (
    input wire              clk,
    input wire              signal,
    output wire             leading_edge_detect
    );

	reg q1, q2;

	always @(posedge clk) begin
		q1 <= signal;
		q2 <= q1;
	end

	assign leading_edge_detect = q1 & (q1 ^ q2);
endmodule
