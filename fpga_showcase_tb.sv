`timescale 1ns/1ps

module fpga_showcase_tb;

    reg CLK100MHZ;
    reg [3:0] sw;
    reg [3:0] btn;
    wire [7:0] led;

    // DUT
    fpga_showcase uut (
        .CLK100MHZ(CLK100MHZ),
        .sw(sw),
        .btn(btn),
        .led(led)
    );

    // 100 MHz clock (10 ns period)
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end

    // Stimulus
    initial begin

        sw  = 4'b0000;
        btn = 4'b0000;

        // Let design run
        #10000;

        // Change switch settings
        sw = 4'b0001;
        #10000;

        sw = 4'b0010;
        #10000;

        sw = 4'b0100;
        #10000;

        sw = 4'b1000;
        #10000;

        // Press pause button
        btn[0] = 1'b1;
        #100;
        btn[0] = 1'b0;

        #10000;

        // Press reverse button
        btn[1] = 1'b1;
        #100;
        btn[1] = 1'b0;

        #10000;

        // Press reset button
        btn[3] = 1'b1;
        #100;
        btn[3] = 1'b0;

        #10000;

        $finish;

    end

endmodule
