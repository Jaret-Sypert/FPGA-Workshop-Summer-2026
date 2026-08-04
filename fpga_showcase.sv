module fpga_showcase(
    input  logic CLK100MHZ,
    input  logic [3:0] sw,
    input  logic [3:0] btn,
    output logic [7:0] led
);
logic [31:0] counter = 0;
logic tick = 0;

logic [31:0] max_count;

logic [2:0] position = 0;
logic direction = 0;

logic [7:0] counter_pattern = 0;

//--------------------------------------------------
// Speed Selection 
//--------------------------------------------------

always_comb
begin
    case(sw[1:0])

        2'b00: max_count = 25; // Slow
        2'b01: max_count = 12; // Medium
        2'b10: max_count = 6;  // Fast
        default: max_count = 3; // Very Fast

    endcase
end

//--------------------------------------------------
// Clock Divider
//--------------------------------------------------

always_ff @(posedge CLK100MHZ)
begin

    if(btn[3]) // Reset
    begin
        counter <= 0;
        tick <= 0;
    end
    else
    begin

        if(counter >= max_count)
        begin
            counter <= 0;
            tick <= 1;
        end
        else
        begin
            counter <= counter + 1;
            tick <= 0;
        end

    end

end

//--------------------------------------------------
// Scanner Position
//--------------------------------------------------

always_ff @(posedge CLK100MHZ)
begin

    if(btn[3]) // Reset
    begin
        position <= 0;
        direction <= 0;
        counter_pattern <= 0;
    end

    else if(tick && !btn[0]) // BTN0 = Pause
    begin

        counter_pattern <= counter_pattern + 1;

        if(btn[1]) // BTN1 = Reverse
            direction <= ~direction;

        if(direction == 0)
        begin

            if(position == 7)
            begin
                direction <= 1;
                position <= 6;
            end
            else
                position <= position + 1;

        end

        else
        begin

            if(position == 0)
            begin
                direction <= 0;
                position <= 1;
            end
            else
                position <= position - 1;

        end

    end

end

//--------------------------------------------------
// LED Patterns
//--------------------------------------------------

always_comb
begin

    case(sw[3:2])

    //--------------------------------------------------
    // Pattern 0 - Knight Rider
    //--------------------------------------------------

    2'b00:
    begin
        led = 8'b00000001 << position;
    end

    //--------------------------------------------------
    // Pattern 1 - Dual Scanner
    //--------------------------------------------------

    2'b01:
    begin

        led =
            (8'b00000001 << position) |
            (8'b10000000 >> position);

    end

    //--------------------------------------------------
    // Pattern 2 - Binary Counter
    //--------------------------------------------------

    2'b10:
    begin
        led = counter_pattern;
    end

    //--------------------------------------------------
    // Pattern 3 - Knight Rider Tail
    //--------------------------------------------------

    default:
    begin

        case(position)

            3'd0: led = 8'b00000001;
            3'd1: led = 8'b00000011;
            3'd2: led = 8'b00000110;
            3'd3: led = 8'b00001100;
            3'd4: led = 8'b00011000;
            3'd5: led = 8'b00110000;
            3'd6: led = 8'b01100000;
            3'd7: led = 8'b11000000;

            default: led = 8'b00000000;

        endcase

    end

    endcase

end

endmodule
