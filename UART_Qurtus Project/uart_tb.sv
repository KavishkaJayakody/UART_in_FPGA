`timescale 1ns / 1ps

module uart_tb;

  // Parameters
  parameter CLOCKS_PER_PULSE = 10;  // Small for simulation speed
  parameter BITS_PER_WORD    = 8;

  // Signals
  logic clk = 0, rstn = 0;
  logic s_valid, s_ready;
  logic [BITS_PER_WORD-1:0] s_data;
  logic tx, rx;
  logic m_valid;
  logic [BITS_PER_WORD-1:0] m_data;

  // Clock generation
  always #5 clk = ~clk;  // 100 MHz

  // Instantiate UART module (which includes TX and RX)
  uart #(
    .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
    .BITS_PER_WORD(BITS_PER_WORD)
  ) uart_inst (
    .clk(clk),
    .rstn(rstn),
    .s_valid(s_valid),
    .s_data(s_data),
    .tx(tx),
    .s_ready(s_ready),
    .rx(rx),
    .m_valid(m_valid),
    .m_data(m_data)
  );

  // Connect tx to rx for loopback
  assign rx = tx;

  // Stimulus
  initial begin
    // Test vector
    logic [BITS_PER_WORD-1:0] test_data [0:2];
    int i;

    test_data[0] = 8'hA5;
    test_data[1] = 8'h3C;
    test_data[2] = 8'hF0;

    // Initial reset and setup
    $display("Starting simulation...");
    rstn = 0;
    s_valid = 0;
    #50;
    rstn = 1;

    // Test loop to send multiple bytes
    for (i = 0; i < 3; i++) begin
      // Wait until TX is ready for a new byte
      @(posedge clk);
      wait (s_ready);
      s_data = test_data[i];
      s_valid = 1;
      @(posedge clk);
      s_valid = 0;  // Pulse s_valid for one clock cycle

      // Wait for RX to receive data and assert m_valid
      wait (m_valid);
      $display("TX: %02X -> RX: %02X %s", test_data[i], m_data,
               (m_data == test_data[i]) ? "PASS" : "FAIL");

      // Add some delay between transmissions
      repeat (5) @(posedge clk);
    end

    $display("Simulation complete.");
    #50;
    $finish;
  end

endmodule
