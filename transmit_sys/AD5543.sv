`timescale 1ns/10ps

module AD5543_tb;
    bit aclk,areset_n;
    bit [15:0] data;
    bit clk,sdi,cs_n;

    always #10 aclk=~aclk;  // 33.33MHz
    initial begin
        areset_n=1'b0;
        repeat(5) @(posedge aclk);
        areset_n=1'b1;
    end

    always_ff @( negedge cs_n ) begin
        data<=$random();
    end

    /*
    AD5543_32M theAD5543_32M_tb (
        aclk,areset_n,1'b1,
        data,
        clk,sdi,cs_n
    );
    */
    AD5543_48M theAD5543_48M_tb (
        aclk,areset_n,1'b1,
        data,
        clk,sdi,cs_n
    );
endmodule

module AD5543_32M #(
    parameter integer DW = 16
)(
    input wire aclk,areset_n,en,
    input wire [DW-1:0] data,
    output logic clk,sdi,cs_n
);
    logic aclk_n;
    logic co15;
    logic co15_1,co15_2;
    logic [DW-1:0] shift_data;

    assign aclk_n=~aclk;
    counter #(DW-1) theCounter15(aclk,areset_n,en,co15);
    assign co15_1=aclk & co15;
    assign co15_2=~aclk & co15;

    // drive shift_data
    always_ff @(posedge aclk or posedge aclk_n or negedge areset_n) begin
        if(!areset_n) begin
            shift_data<='0;
        end
        else if(en) begin
            if(aclk_n && co15) begin
                shift_data<=data;
            end
            else if(aclk) begin
                shift_data<={shift_data[DW-2:0],1'b0};
            end
        end
    end

    // drive cs_n
    always_ff @( posedge aclk or posedge aclk_n or negedge areset_n) begin
        if(!areset_n) begin
            cs_n<=1'b1;
        end
        else if(en) begin
            if(aclk_n && co15) begin
                cs_n<=1'b1;
            end
            else if(aclk && co15) begin
                cs_n<=1'b0;
            end
        end
    end

    assign clk=aclk;
    assign sdi=shift_data[DW-1];

endmodule

module AD5543_48M #(
    parameter integer DW = 16
)(
    input wire aclk,areset_n,en,
    input wire [DW-1:0] data,
    output logic clk,sdi,cs_n
);
    logic cs;
    logic co16,co24;
    logic co16_dly;
    logic [DW-1:0] shift_data;

    assign cs=~cs_n;

    counter #(16) theCounter16 (aclk,cs,cs,co16);
    counter #(24) theCounter24 (aclk,areset_n,en,co24);

    always_ff @( posedge aclk ) begin
        co16_dly<=co16;
    end

    always_ff @( posedge aclk ) begin
        if(!areset_n) begin
            cs_n<=1'b1;
        end
        else if(en) begin
            if(co24) begin
                cs_n<=1'b0;
            end
            else if(co16_dly) begin
                cs_n<=1'b1;
            end
        end
    end

    always_ff @( posedge aclk ) begin
        if(!areset_n) begin
            shift_data<='0;
        end
        else if(en) begin
            if(co24) begin
                shift_data<=data;
            end
            else if(cs) begin
                shift_data<={shift_data[DW-2:0],1'b0};
            end
            else begin
                shift_data<=shift_data;
            end
        end
    end

    assign clk=aclk;
    assign sdi=shift_data[DW-1];

endmodule