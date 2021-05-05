`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // If a module starts with #() then it is parametisable. It can be instantiated with different settings
    // for the localparams defined here. So the default is an UPDATE_PERIOD of 1200 and BITS = 12
    localparam UPDATE_PERIOD = 1200,
    localparam BITS = 12
)(
    input wire              clk,
    input wire              reset,
    input wire              signal,

    input wire [BITS-1:0]   period,
    input wire              period_load,

    output wire [6:0]       segments,
    output wire             digit
    );

    localparam LOCAL_BITS = 7;
    localparam LOCAL_SEGMENTS = 3;
    // states
    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS  = 2;
    localparam STATE_FLUSH  = 3;
    reg [2:0] state = STATE_COUNT;
    reg [LOCAL_BITS:0] edge_counter;
    reg [LOCAL_SEGMENTS:0] ten_count;
    reg [LOCAL_SEGMENTS:0] unit_count;
    reg [BITS:0] clk_counter;

    reg load_enable;
    wire leading_edge_detect;

    edge_detect Edge(.clk(clk),
                     .signal(signal),
                     .leading_edge_detect(leading_edge_detect));

    seven_segment SevenSegment(.clk(clk),
                               .reset(reset),
                               .load(load_enable),
                               .ten_count(ten_count),
                               .unit_count(unit_count),
                               .segments(segments),
                               .digit(digit));

    always @(posedge clk) begin
        if(reset) begin
            state <= STATE_COUNT;
            load_enable <= 1'b0;
	    edge_counter <= 0;
            clk_counter <= 0;
            ten_count <= 0;
            unit_count <= 0;
        end else begin
            case(state)
                STATE_COUNT: begin
                    // count edges and clock cycles
                    clk_counter <= clk_counter + 1;
                    if (leading_edge_detect) begin
                            if (edge_counter < 99) begin
                                edge_counter <= edge_counter + 1;
                            end
                    end
                    // if clock cycles > UPDATE_PERIOD then go to next state
                    if (clk_counter > UPDATE_PERIOD) begin
                            state <= STATE_TENS;
                    end
                end

                STATE_TENS: begin
                    // count number of tens by subtracting 10 while edge counter >= 10
                    if (edge_counter >= 10) begin
                            edge_counter <= edge_counter - 10;
                            ten_count <= ten_count + 1;
                    end else
                    // then go to next state
                            state <= STATE_UNITS;
                end

                STATE_UNITS: begin
                    // what is left in edge counter is units
                    unit_count <= edge_counter;
                    // update the display
                    load_enable <= 1'b1;
                    // go back to counting
                    state <= STATE_FLUSH;
                end

                STATE_FLUSH: begin
                    unit_count <= 0;
                    ten_count <= 0;
                    load_enable <= 1'b0;
		    edge_counter <= 0;
		    clk_counter <= 0;
                    state          <= STATE_COUNT;
                end
                default:
                        state <= STATE_COUNT;

            endcase
        end
    end

endmodule
