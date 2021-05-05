`default_nettype none
`timescale 1ns/1ps


module seg7 (
    input wire [3:0] counter,
    output reg [6:0] segments
);

	always @(*) begin
        case(counter)
            //                7654321
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111100;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1100111;
            default:
                segments = 7'b0000000;
        endcase
    end

endmodule

module seven_segment (
    input wire          clk,
    input wire          reset,
    input wire          load,
    input wire [3:0]    ten_count,
    input wire [3:0]    unit_count,
    output reg [6:0]    segments,
    output reg          digit
);

	reg [3:0] copy_ten_count;
	reg [3:0] copy_unit_count;
	reg select_output = 0;
	wire [3:0] values;

	assign values = (select_output ? copy_unit_count : copy_ten_count);

	always @(posedge clk) begin
			if (reset) begin
					select_output <= 0;
					copy_ten_count <= 0;
					copy_unit_count <= 0;
					digit <= 0;
			end else
				// Flips back and forth.
				select_output <= !select_output;
	end

	always @(posedge load) begin
		copy_ten_count <= ten_count;
		copy_unit_count <= unit_count;
	end
	always @(select_output) begin
		digit <= select_output;
	end

	seg7 seg7(.counter(values), .segments(segments));
endmodule
