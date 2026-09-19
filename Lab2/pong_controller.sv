
module pot_test(
    input  logic CLK100MHZ,

    input  logic vauxp4,
    input  logic vauxn4,

    input  logic vauxp5,
    input  logic vauxn5,

    output logic tx
);

logic [15:0] do_out;
logic drdy_out;

logic start = 0;
logic busy;

logic [31:0] counter = 0;

logic select_a1 = 0;

logic [7:0] left_value  = 0;
logic [7:0] right_value = 0;

logic [7:0] ascii_char;

logic [3:0] tx_state = 0;

xadc_wiz_0 XADC
(
    .di_in(16'h0000),
    .daddr_in(select_a1 ? 7'h15 : 7'h14),
    .den_in(1'b1),
    .dwe_in(1'b0),

    .drdy_out(drdy_out),
    .do_out(do_out),

    .dclk_in(CLK100MHZ),
    .reset_in(1'b0),

    .vp_in(1'b0),
    .vn_in(1'b0),

    .vauxp4(vauxp4),
    .vauxn4(vauxn4),

    .vauxp5(vauxp5),
    .vauxn5(vauxn5),

    .user_temp_alarm_out(),
    .vccint_alarm_out(),
    .vccaux_alarm_out(),
    .ot_out(),
    .channel_out(),
    .eoc_out(),
    .alarm_out(),
    .eos_out(),
    .busy_out()
);

always_ff @(posedge CLK100MHZ)
begin
    if(drdy_out)
    begin
        if(select_a1)
            right_value <= do_out[15:8];
        else
            left_value <= do_out[15:8];
    end
end

always_comb
begin
    case(tx_state)

        4'd0: ascii_char = 8'h4C; // L

        4'd1: ascii_char = 8'h30 + (left_value / 100);

        4'd2: ascii_char = 8'h30 + ((left_value / 10) % 10);

        4'd3: ascii_char = 8'h30 + (left_value % 10);

        4'd4: ascii_char = 8'h52; // R

        4'd5: ascii_char = 8'h30 + (right_value / 100);

        4'd6: ascii_char = 8'h30 + ((right_value / 10) % 10);

        4'd7: ascii_char = 8'h30 + (right_value % 10);

        default: ascii_char = 8'h0A; // newline

    endcase
end

uart_tx1 U1
(
    .clk(CLK100MHZ),
    .start(start),
    .data(ascii_char),
    .tx(tx),
    .busy(busy)
);

always_ff @(posedge CLK100MHZ)
begin
    start <= 0;

    if(counter >= 100_000)
    begin
        counter <= 0;

        if(!busy)
        begin
            start <= 1;

            if(tx_state == 8)
            begin
                tx_state <= 0;
                select_a1 <= ~select_a1;
            end
            else
            begin
                tx_state <= tx_state + 1;
            end
        end
    end
    else
    begin
        counter <= counter + 1;
    end
end

endmodule
