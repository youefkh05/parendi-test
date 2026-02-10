module concurrency_multi_fiber (
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic [31:0] in3,
    input  logic [31:0] in4,
    input  logic [31:0] in5,
    input  logic [31:0] in6,
    input  logic [31:0] in7,

    output logic [31:0] out_sum,
    output logic [31:0] out_mix,
    output logic [31:0] out_ctrl
);

    // =========================
    // Independent registers (Fibers 1–6)
    // =========================
    logic [31:0] r0, r1, r2, r3, r4, r5;

    always_ff @(posedge clk) begin
        if (rst) r0 <= 0;
        else     r0 <= in0 + in1;       // Fiber 1
    end

    always_ff @(posedge clk) begin
        if (rst) r1 <= 0;
        else     r1 <= in2 ^ in3;       // Fiber 2
    end

    always_ff @(posedge clk) begin
        if (rst) r2 <= 0;
        else     r2 <= in4 & in5;       // Fiber 3
    end

    always_ff @(posedge clk) begin
        if (rst) r3 <= 0;
        else     r3 <= in6 | in7;       // Fiber 4
    end

    always_ff @(posedge clk) begin
        if (rst) r4 <= 0;
        else     r4 <= in0 * 3;         // Fiber 5 (heavier logic)
    end

    always_ff @(posedge clk) begin
        if (rst) r5 <= 0;
        else     r5 <= in1 + 42;        // Fiber 6
    end

    // =========================
    // Dependent logic (Fibers 7–8)
    // =========================
    logic [31:0] sum_all;
    logic [31:0] mixed;

    assign sum_all = r0 + r1 + r2;      // depends on fibers 1–3
    assign mixed   = r3 ^ r4 ^ r5;      // depends on fibers 4–6

    always_ff @(posedge clk) begin
        if (rst) out_sum <= 0;
        else     out_sum <= sum_all;    // Fiber 7
    end

    always_ff @(posedge clk) begin
        if (rst) out_mix <= 0;
        else     out_mix <= mixed;      // Fiber 8
    end

    // =========================
    // Control-like fiber (Fiber 9)
    // =========================
    always_ff @(posedge clk) begin
        if (rst)
            out_ctrl <= 0;
        else if (r0[0])
            out_ctrl <= out_sum;
        else
            out_ctrl <= out_mix;
    end

endmodule
