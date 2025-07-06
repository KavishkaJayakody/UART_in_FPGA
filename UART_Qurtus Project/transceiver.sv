module transceiver #(
  parameter CLOCKS_PER_PULSE = 5208,
            BITS_PER_WORD    = 8
)(
  input  logic clk,
  input  logic rstn,
  output logic clk_test,

  input  logic [3:0] sw,         // 4-bit switch input
  input  logic btn,             // Send trigger button
  output logic [6:0] seg,       // 7-segment display output
  output logic [2:0] an,

  output logic tx,              // UART transmit
  input  logic rx               // UART receive
);

  // UART TX signals
  logic s_valid, s_ready;
  logic [7:0] s_data;

  // UART RX signals
  logic m_valid;
  logic [7:0] m_data;

  // Display latch
  logic [7:0] display_data;
  
  //Clock output for measurements
  assign clk_test = clk;

  // Instantiate UART
  uart #(
    .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
    .BITS_PER_WORD(BITS_PER_WORD)
  ) uart_inst (
    .clk(clk),
    .rstn(rstn),
    .s_valid(s_valid),
    .s_data(s_data),
    .s_ready(s_ready),
    .tx(tx),
    .rx(rx),
    .m_valid(m_valid),
    .m_data(m_data)
  );

  // Button edge detection & transmit control
  logic btn_prev;
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      btn_prev <= 0;
      s_valid <= 0;
      s_data <= 0;
    end else begin
      btn_prev <= btn;
      if (btn && !btn_prev && s_ready) begin
        s_data <= {4'b0000, sw};
        s_valid <= 1;
      end else begin
        s_valid <= 0;
      end
    end
  end

  // Latch every valid received value
  always_ff @(posedge clk or negedge rstn) begin
	 //display_data <= m_data;
    if (!rstn)
      display_data <= 8'd0;
      else if (m_valid)
      display_data <= m_data;
  end

  // Drive 3-digit display
  display_3digit_multiplexed display_inst (
    .clk(clk),
    .num(m_data),
    .an(an),
    .seg(seg)
  );

endmodule
