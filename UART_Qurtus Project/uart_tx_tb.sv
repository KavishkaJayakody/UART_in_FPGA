`timescale 1ns/1ps

module uart_tx_tb;

  // Parameters
  localparam CLOCKS_PER_PULSE = 10;  // Use small value for faster simulation
  localparam BITS_PER_WORD    = 8;
  localparam PACKET_SIZE      = BITS_PER_WORD + 5;

  // DUT Signals
  logic clk;
  logic rstn;
  logic s_valid;
  logic [BITS_PER_WORD-1:0] s_data;
  logic tx;
  logic s_ready;

  // Instantiate the UART transmitter
  uart_tx #(
    .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
    .BITS_PER_WORD(BITS_PER_WORD),
    .PACKET_SIZE(PACKET_SIZE)
  ) dut (
    .clk(clk),
    .rstn(rstn),
    .s_valid(s_valid),
    .s_data(s_data),
    .tx(tx),
    .s_ready(s_ready)
  );

  // Clock generation: 100MHz
  always #5 clk = ~clk; // 10ns period

  // Test sequence
  initial begin
    // Initialize
    clk = 0;
    rstn = 0;
    s_valid = 0;
    s_data = 8'h00;

    // Reset pulse
    #20;
    rstn = 1;

    // Wait for DUT to become ready
    @(posedge clk);
    wait (s_ready);

    // Send byte 0xA5 (10100101)
    s_data = 8'hA5;
    s_valid = 1;
    @(posedge clk);
    s_valid = 0;

    // Wait for transmission to complete
    wait (s_ready);

    // Another byte
    @(posedge clk);
    s_data = 8'h3C;
    s_valid = 1;
    @(posedge clk);
    s_valid = 0;

    // Wait and finish
    wait (s_ready);
    #100;
    $finish;
  end

  // Monitor TX line
  initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, uart_tx_tb);
    $display("Time\tTX");
    $monitor("%0t\t%b", $time, tx);
  end

endmodule
