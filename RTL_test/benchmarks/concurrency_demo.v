module concurrency_demo (
    input  wire clk,
    input  wire rst,
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [7:0] c,
    output reg  [7:0] y1,
    output reg  [7:0] y2,
    output reg  [7:0] y3
);

    // Independent concurrent logic blocks
    always @(posedge clk) begin
        if (rst)
            y1 <= 0;
        else
            y1 <= a + b;
    end

    always @(posedge clk) begin
        if (rst)
            y2 <= 0;
        else
            y2 <= b + c;
    end

    always @(posedge clk) begin
        if (rst)
            y3 <= 0;
        else
            y3 <= a + c;
    end

endmodule
