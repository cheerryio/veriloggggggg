`timescale 1ns/10ps

module fir_tb #(

)(

);
    localparam integer LC_DW=12;
    localparam integer FREQ_DW = 32;
    logic clk,rst_n,en;
    initial begin
        clk=0;
        en=1;
        forever #50 clk=~clk;
    end
    initial begin
        rst_n=0;
        #100 rst_n=1;
    end
    real freqr = 1e6, fstepr = 49e6/(1e-3*100e6); // from 1MHz to 50MHz in 1ms
    always@(posedge clk) begin
        if(!rst_n) freqr = 1e6;
        else freqr += fstepr;
    end
    logic signed [FREQ_DW-1:0] freq;
    always@(posedge clk) begin
        freq <= 2.0**32 * freqr / 100e6; // frequency to freq control word
    end
    logic signed [FREQ_DW-1:0] phase = '0;
    logic signed [LC_DW-1:0] sin,cos;
    orthDds #(FREQ_DW, LC_DW, 13) theOrthDdsInst(clk, rst_n, 1'b1, freq, phase, sin,cos);
    logic signed [LC_DW-1:0] filtered;
    fir #(LC_DW, 27, '{ -0.005646,  0.006428,  0.019960,  0.033857,  0.036123,
                      0.016998, -0.022918, -0.068988, -0.097428, -0.087782,
                     -0.036153,  0.039431,  0.106063,  0.132519,  0.106063,
                      0.039431, -0.036153, -0.087782, -0.097428, -0.068988,
                     -0.022918,  0.016998,  0.036123,  0.033857,  0.019960,
                      0.006428, -0.005646
    })  theFir1(clk, rst_n, 1'b1, (LC_DW)'(integer'(sin * 0.9)), filtered);
endmodule