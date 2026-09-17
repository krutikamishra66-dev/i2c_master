 `timescale 1ns / 1ps

module tb_i2c_master;

    reg        clk;
    reg        reset_n;
    reg        start;
    reg  [6:0] addr;
    reg  [7:0] data;
    wire       busy;

    // Pull-up resistors for open-drain I2C bus lines
    tri1 scl;
    tri1 sda;

    // Instantiate UUT
    i2c_master uut (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (start),
        .addr   (addr),
        .data   (data),
        .scl (scl),
        .sda(sda),
        .busy   (busy)
    );

    // Generate 50 MHz clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Waveform dump file setup (VCD format - works with GTKWave, ModelSim, Cadence SimVision)
        $dumpfile("i2c_wave.vcd");
        $dumpvars(0, tb_i2c_master);

        // Initialize signals
        clk     = 0;
        reset_n = 0;
        start   = 0;
        addr    = 7'h00;
        data    = 8'h00;

        // Release Reset
        #100;
        reset_n = 1;
        #100;

        // Trigger Transaction: Address = 0x3A, Data = 0xA5
         // In i2c_tb.v
addr  = 7'h3A;
data  = 8'hA5;

start = 1'b1;
wait (busy == 1'b1); // Hold start active until FSM responds
start = 1'b0;

wait (busy == 1'b0); // Wait until transaction finishes
        #200;
        $display("Simulation Finished Successfully.");
        $finish;
    end

endmodule
