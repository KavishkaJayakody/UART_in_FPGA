`timescale 1ns / 1ps

module transceiver_tb;

  parameter CLOCKS_PER_PULSE = 5208;  // Smaller for faster simulation
  parameter BITS_PER_WORD = 8;

  logic clk = 0;
  logic rstn;
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

    // Send known values instead of random ones
    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      sw = i % 10;  // Cycle through 0 to 9
      @(posedge clk);
      btn = 1;  // Simulate button press
      @(posedge clk);
      btn = 0;

      // Wait for UART transmission + reception
      #(CLOCKS_PER_PULSE * (BITS_PER_WORD + 2) * 10);  // Conservative wait

      $display("Sent: %0d, Segment: %b", sw, seg);
    end

    $finish;
  end

endmodule
