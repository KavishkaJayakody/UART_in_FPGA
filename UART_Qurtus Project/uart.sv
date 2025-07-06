module uart #(
  parameter CLOCKS_PER_PULSE = 5208,  // For 9600 baud at 50 MHz
            BITS_PER_WORD    = 8
)(
  input  logic clk,
  input  logic rstn,
  
  // TX interface
  input  logic s_valid,      						//from data source  , input control to the transmitter                
  input  logic [BITS_PER_WORD-1:0] s_data,	//from data source  , input data to the transmitter 
  output logic s_ready,								//to the data source
  output logic tx,
  
  // RX interface
  input  logic rx,
  output logic m_valid,								//data output validity
  output logic [BITS_PER_WORD-1:0] m_data		//output data
);

  // Instantiate TX module
  uart_tx #(
    .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
    .BITS_PER_WORD(BITS_PER_WORD)
  ) tx_inst (
    .clk(clk),
    .rstn(rstn),
    .s_valid(s_valid),
    .s_data(s_data),
    .tx(tx),
    .s_ready(s_ready)
  );

  // Instantiate RX module
  uart_rx #(
    .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
    .BITS_PER_WORD(BITS_PER_WORD)
  ) rx_inst (
    .clk(clk),
    .rstn(rstn),
    .rx(rx),
    .m_valid(m_valid),
    .m_data(m_data)
  );

endmodule 