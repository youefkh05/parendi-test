module concurrency_large_demo (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] in_a,
    input  wire [31:0] in_b,
    output wire [31:0] out_sum,
    output wire [31:0] out_pipe
);

    /* ==============================
     * Group 1: Independent counters
     * ============================== */
    reg [31:0] cnt0, cnt1, cnt2, cnt3, cnt4;

    always @(posedge clk) begin
        if (rst) cnt0 <= 0;
        else     cnt0 <= cnt0 + 1;
    end

    always @(posedge clk) begin
        if (rst) cnt1 <= 0;
        else     cnt1 <= cnt1 + 2;
    end

    always @(posedge clk) begin
        if (rst) cnt2 <= 0;
        else     cnt2 <= cnt2 + 3;
    end

    always @(posedge clk) begin
        if (rst) cnt3 <= 0;
        else     cnt3 <= cnt3 + 4;
    end

    always @(posedge clk) begin
        if (rst) cnt4 <= 0;
        else     cnt4 <= cnt4 + 5;
    end

    /* ==============================
     * Group 2: Independent sensors
     * ============================== */
    reg [31:0] sensor0, sensor1, sensor2, sensor3, sensor4;

    always @(posedge clk) begin
        sensor0 <= in_a + 10;
    end

    always @(posedge clk) begin
        sensor1 <= in_a + 20;
    end

    always @(posedge clk) begin
        sensor2 <= in_a + 30;
    end

    always @(posedge clk) begin
        sensor3 <= in_a + 40;
    end

    always @(posedge clk) begin
        sensor4 <= in_a + 50;
    end

    /* ==============================
     * Group 3: Reduction tree (dependent)
     * ============================== */
    reg [31:0] sum0, sum1, sum2;

    always @(posedge clk) begin
        sum0 <= sensor0 + sensor1;
    end

    always @(posedge clk) begin
        sum1 <= sensor2 + sensor3;
    end

    always @(posedge clk) begin
        sum2 <= sum0 + sum1;
    end

    assign out_sum = sum2 + sensor4;

    /* ==============================
     * Group 4: Pipeline chain (strong dependency)
     * ============================== */
    reg [31:0] pipe0, pipe1, pipe2, pipe3, pipe4;

    always @(posedge clk) begin
        pipe0 <= in_b;
    end

    always @(posedge clk) begin
        pipe1 <= pipe0 + 1;
    end

    always @(posedge clk) begin
        pipe2 <= pipe1 + 2;
    end

    always @(posedge clk) begin
        pipe3 <= pipe2 + 3;
    end

    always @(posedge clk) begin
        pipe4 <= pipe3 + 4;
    end

    assign out_pipe = pipe4;

    /* ==============================
     * Group 5: Control + dependent datapath
     * ============================== */
    reg enable;
    reg [31:0] gated0, gated1;

    always @(posedge clk) begin
        if (rst) enable <= 0;
        else     enable <= (cnt0[2] ^ cnt1[3]);
    end

    always @(posedge clk) begin
        if (enable)
            gated0 <= cnt2 + cnt3;
        else
            gated0 <= 0;
    end

    always @(posedge clk) begin
        gated1 <= gated0 + cnt4;
    end

    /* ==============================
     * Group 6: Independent status flags
     * ============================== */
    reg flag0, flag1, flag2, flag3, flag4;

    always @(posedge clk) flag0 <= (cnt0 > 100);
    always @(posedge clk) flag1 <= (cnt1 > 200);
    always @(posedge clk) flag2 <= (cnt2 > 300);
    always @(posedge clk) flag3 <= (cnt3 > 400);
    always @(posedge clk) flag4 <= (cnt4 > 500);

endmodule

