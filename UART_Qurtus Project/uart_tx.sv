module uart_tx #(
  parameter CLOCKS_PER_PULSE = 5208,                // 50 MHz / 9600 baud
            BITS_PER_WORD    = 8,
            PACKET_SIZE      = BITS_PER_WORD + 5     // 1 start + 8 data + 2 stop + (optional parity)
)(
  input  logic clk,
  input  logic rstn,
  input  logic s_valid,
  input  logic [BITS_PER_WORD-1:0] s_data,
  output logic tx,
  output logic s_ready
);

  // Constants
  localparam END_BITS = PACKET_SIZE - BITS_PER_WORD - 1; // Number of stop bits (assuming 2)

  // FSM States
  typedef enum logic {IDLE, SEND} state_t;
  state_t state;

  // Internal registers
  logic [PACKET_SIZE-1:0] s_packet;
  logic [PACKET_SIZE-1:0] s_packet_reg;
  logic [$clog2(PACKET_SIZE)-1:0] c_bits;
  logic [$clog2(CLOCKS_PER_PULSE)-1:0] c_clocks;

  // Format packet: stop bits (1's), data, start bit (0)
  always_comb begin
    s_packet = { {END_BITS{1'b1}}, s_data, 1'b0 }; // LSB first
  end

  // Output is the LSB of the shift register
  assign tx = s_packet_reg[0];

  // FSM and logic
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state         <= IDLE;
      s_packet_reg  <= '1; // Idle line is high
      c_bits        <= 0;
      c_clocks      <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (s_valid) begin
            s_packet_reg <= s_packet;
            c_bits       <= 0;
            c_clocks     <= 0;
            state        <= SEND;
          end
        end

        SEND: begin
          if (c_clocks == CLOCKS_PER_PULSE - 1) begin
            c_clocks <= 0;
            if (c_bits == PACKET_SIZE - 1) begin
              state        <= IDLE;
              s_packet_reg <= '1; // Reset line to idle (high)
            end else begin
              c_bits       <= c_bits + 1;
              s_packet_reg <= s_packet_reg >> 1; // Shift next bit out
            end
          end else begin
            c_clocks <= c_clocks + 1;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

  // s_ready indicates the module is ready for new data
  assign s_ready = (state == IDLE);

endmodule
