`timescale 1ns/10ps

module counter #(
    parameter integer N = 64,
    parameter integer IS_NEGEDGE = 0
)(
    input wire clk,rst_n,en,
    output logic co
);
    logic [$clog2(N)-1:0] cnt;
    generate
        if(!IS_NEGEDGE) begin
            always_ff @( posedge clk ) begin
                if(!rst_n) begin cnt <= '0; end
                else if(en)
                begin
                    if(cnt<N-1) cnt<=cnt+1'b1;
                    else cnt<='0;
                end
            end
        end
        else begin
            always_ff @( negedge clk ) begin
                if(!rst_n) begin cnt <= '0; end
                else if(en)
                begin
                    if(cnt<N-1) cnt<=cnt+1'b1;
                    else cnt<='0;
                end
            end
        end
    endgenerate
    
    assign co=en & cnt==N-1;

    property check_counter;
        int LCount;
        @(posedge clk) disable iff (!rst_n)
        (
            (co,LCount=0) ##1
            (en,LCount=LCount+1)[*0:N] ##1 (LCount==N-1) |-> (co==1)
        );
    endproperty
    assert property (check_counter);
endmodule