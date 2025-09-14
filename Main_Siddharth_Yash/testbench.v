`include "topModule.v"

module testbench;
    wire [7:0]out;
    reg reset =0;
    wire clk;
    masterclock clockkk(clk);
    wire connect;
    
    siggen sig(connect);
    localparam TIME = 4340;
    wire TXD_write;
    topModule T(connect,clk,reset,TXD_write);
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(1,testbench);
        $dumpvars(2,testbench.T);
        reset = 1;
        #(TIME);
        reset = 0;
        #(TIME);
        #(4000*TIME);
        $finish(1);
    end
endmodule

module masterclock(output reg out);
    localparam TIME = 4340;
    initial begin
        out = 0;
    end
    always begin
        #5 out <= !out;
    end
endmodule

module siggen(output reg out);
    localparam TIME = 4340;
    reg [15:0]reg1 = 16'h55AA;
    reg [103:0]test1 = 104'h78452390782211CDAB9CA1FB04;
    reg [359:0]test2 = 360'h117512342000212111110FAB11ABABCD112312340310029903000ABCAAAAA0BC00AB00070008FBAD3311001114; //womp womp sha356 aaa key
    
    reg [857:0]test3 = 856'h4761796461722041637469766174652E204761796461722073656E736520616D6F6E672075732E2E2E2E20486F742067617973206E65617220796F752E2077697468696E20312E35204B6D2E206E656172657374206761792061742037372064656772656573AA00110033;
    reg [567:0] testmain = 568'h21F6680BB894BC0428E28DF1AB363201ADB74CDB864418BDE67DF3013B230D01B2009600F6E73AA60B03ED02CA79C0038BBA7200E403A15E9917FC2A25006201B780453C49023E;
;
    integer i;
    initial begin
        out = 1'b1;
        #(4*TIME);
        out =1'b0;
        #(2*TIME);
        for (i = 0;i<16;i++) begin
            out=reg1[i];
            #(2*TIME);
        end
        for (i = 567;i>=0;i--) begin
            out=testmain[i];
            #(2*TIME);
        end
        assign out = 1'b1;#(2*TIME);
        
    end
endmodule