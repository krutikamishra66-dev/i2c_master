 `timescale 1ns / 1ps
 module i2c_master (
    input  wire       clk,      // System clock
    input  wire       reset_n,  // Active-low reset
    input  wire       start,    // Start transaction pulse
    input  wire [6:0] addr,     // 7-bit slave address
    input  wire [7:0] data,     // 8-bit write byte
    output reg        scl,      // I2C Clock
    inout  wire       sda,      // I2C Data (bidirectional)
    output reg        busy      // High during active transaction
);

    // States
    localparam IDLE  = 3'd0,
               START = 3'd1,
               ADDR  = 3'd2,
               ACK1  = 3'd3,
               DATA  = 3'd4,
               ACK2  = 3'd5,
               STOP  = 3'd6;

    reg [2:0] state;
    reg [2:0] bit_cnt;
    reg       sda_out;
    reg       sda_oe; // Output enable (1 = drive SDA, 0 = release for ACK)

    // Tri-state buffer for SDA line
    assign sda = sda_oe ? sda_out : 1'bz;

    // Simple Clock Tick (Slowing down execution for SCL timing)
    reg [7:0] clk_div;
    reg       tick;

    // In i2c_master.v (temporary speed-up for simulation)
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        clk_div <= 0;
        tick    <= 0;
    end else if (clk_div == 8'd4) begin // Changed from 249 to 4
        clk_div <= 0;
        tick    <= 1'b1;
    end else begin
        clk_div <= clk_div + 1'b1;
        tick    <= 1'b0;
    end

    end

    // Main State Machine
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state   <= IDLE;
            scl     <= 1'b1;
            sda_out <= 1'b1;
            sda_oe  <= 1'b1;
            busy    <= 1'b0;
            bit_cnt <= 3'd0;
        end else if (tick) begin
            case (state)

                IDLE: begin
                    scl     <= 1'b1;
                    sda_out <= 1'b1;
                    sda_oe  <= 1'b1;
                    busy    <= 1'b0;
                    if (start) begin
                        busy  <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    sda_out <= 1'b0; // SDA falls while SCL is high
                    state   <= ADDR;
                    bit_cnt <= 3'd6; // Address bits [6:0]
                end

                ADDR: begin
                    scl <= ~scl; // Toggle SCL
                    if (scl == 1'b0) begin
                        sda_out <= addr[bit_cnt];
                    end else begin
                        if (bit_cnt == 0) state <= ACK1;
                        else bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                ACK1: begin
                    scl    <= ~scl;
                    sda_oe <= 1'b0; // Release SDA so slave can ACK
                    if (scl == 1'b1) begin
                        state   <= DATA;
                        bit_cnt <= 3'd7;
                        sda_oe  <= 1'b1;
                    end
                end

                DATA: begin
                    scl <= ~scl;
                    if (scl == 1'b0) begin
                        sda_out <= data[bit_cnt];
                    end else begin
                        if (bit_cnt == 0) state <= ACK2;
                        else bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                ACK2: begin
                    scl    <= ~scl;
                    sda_oe <= 1'b0; // Release SDA so slave can ACK
                    if (scl == 1'b1) begin
                        state  <= STOP;
                        sda_oe <= 1'b1;
                    end
                end

                STOP: begin
                    scl     <= 1'b1;
                    sda_out <= 1'b1; // SDA rises while SCL is high
                    busy    <= 1'b0;
                    state   <= IDLE;
                end

            endcase
        end
    end

endmodule
