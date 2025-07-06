module uart_rx #(
  parameter CLOCKS_PER_PULSE = 5208, // For 9600 baud at 200 MHz
            BITS_PER_WORD    = 8
)(
  input  logic clk,
  input  logic rstn,
  input  logic rx,
  output logic m_valid,
  output logic [BITS_PER_WORD-1:0] m_data
);

  localparam PACKET_SIZE = BITS_PER_WORD + 2;  // 1 start + 8 data + 1 stop
  typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;

  state_t state;

  // Internal registers
  logic [$clog2(CLOCKS_PER_PULSE)-1:0] c_clocks;
  logic [$clog2(BITS_PER_WORD)-1:0]    c_bits;
  logic [BITS_PER_WORD-1:0]            shift_reg;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state      <= IDLE;
      c_clocks   <= 0;
      c_bits     <= 0;
      shift_reg  <= 0;
      m_data     <= 0;
      m_valid    <= 0;
    end else begin
      m_valid <= 0;  // default

      case (state)
        // Wait for falling edge of start bit
        IDLE: if (rx == 0) begin
          state    <= START;
          c_clocks <= 0;
        end

        // Wait until middle of start bit
        START: if (c_clocks == CLOCKS_PER_PULSE / 2 - 1) begin
          c_clocks <= 0;
          c_bits   <= 0;
          state    <= DATA;
        end else begin
          c_clocks <= c_clocks + 1;
        end

        // Sample 8 data bits
        DATA: if (c_clocks == CLOCKS_PER_PULSE - 1) begin
          c_clocks <= 0;
          shift_reg <= {rx, shift_reg[BITS_PER_WORD-1:1]};  // LSB first

          if (c_bits == BITS_PER_WORD - 1) begin
            state <= STOP;
          end else begin
            c_bits <= c_bits + 1;
          end
        end else begin
          c_clocks <= c_clocks + 1;
        end

        // Wait one stop bit
        STOP: if (c_clocks == CLOCKS_PER_PULSE - 1) begin
          c_clocks <= 0;
          m_data   <= shift_reg;
          m_valid  <= 1;
          state    <= IDLE;
        end else begin
          c_clocks <= c_clocks + 1;
        end
      endcase
    end
  end

endmodule
