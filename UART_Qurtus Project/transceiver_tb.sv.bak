`timescale 1ns / 1ps

module transceiver_tb;

  parameter CLOCKS_PER_PULSE = 10;  // Smaller for faster simulation
  parameter BITS_PER_WORD = 8;

  // Testbench signals
  logic clk = 0, rstn = 0;
  logic [3:0] sw;
  logic btn;
  logic tx, rx;
  logic [6:0] seg;

  // Clock generation: 100 MHz
  always #5 clk = ~clk;

  // DUT
  transceiver #(
    .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
    .BITS_PER_WORD(BITS_PER_WORD)
  ) dut (
    .clk(clk),
    .rstn(rstn),
    .sw(sw),
    .btn(btn),
    .seg(seg),
    .tx(tx),
    .rx(rx)
  );

  // Connect tx back to rx for loopback
  assign rx = tx;

  // Test sequence
  initial begin
    $display("Starting transceiver testbench...");

    // Reset
    rstn = 0;
    sw = 4'd0;
    btn = 0;
    #50;
    rstn = 1;

    // Send several values via switches
    repeat (5) begin
      @(posedge clk);
      sw = $urandom_range(0, 9);  // Random value between 0 and 9
      @(posedge clk);
      btn = 1;  // Simulate button press
      @(posedge clk);
      btn = 0;

      // Wait for transmission and reception
      #(CLOCKS_PER_PULSE * (BITS_PER_WORD + 2) * 10);  // Enough time for full UART transfer

      $display("Sent: %0d, Segment: %b", sw, seg);
    end

    $finish;
  end

endmodule
