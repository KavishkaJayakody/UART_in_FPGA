module display_3digit_multiplexed (
  input  logic        clk,         // System clock
  input  logic [7:0]  num,         // 8-bit number (0–255)
  output logic [6:0]  seg,         // Segment outputs (gfedcba)
  output logic [2:0]  an           // Digit enable (active LOW)
);

  logic [3:0] digit_val;
  logic [1:0] digit_idx;
  logic [15:0] refresh_counter;
  logic [6:0] seg_raw;

  // Convert number to BCD digits
  logic [3:0] hundreds, tens, units;

  always_comb begin
    hundreds = num / 100;
    tens     = (num % 100) / 10;
    units    = num % 10;
  end

  // 1 kHz refresh rate from 50 MHz clock
  always_ff @(posedge clk) begin
    refresh_counter <= refresh_counter + 1;
    if (refresh_counter == 49999) begin
      refresh_counter <= 0;
      digit_idx <= digit_idx + 1;
    end
  end

  // Select current digit value based on digit_idx
  always_comb begin
    case (digit_idx)
      2'd0: begin
        digit_val = units;
        an = 3'b001; // Enable rightmost digit (active-high)
      end
      2'd1: begin
        digit_val = tens;
        an = 3'b010; // Middle digit
      end
      2'd2: begin
        digit_val = hundreds;
        an = 3'b100; // Leftmost digit
      end
      default: begin
        digit_val = 4'd0;
        an = 3'b000; // All off
      end
    endcase
  end

  // Decode digit to segments
  seven_segment_decoder decoder (
    .num(digit_val),
    .seg(seg_raw)
  );

  
  assign seg = seg_raw;

endmodule
