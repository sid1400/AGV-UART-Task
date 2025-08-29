`include "topModule.v"

module testbench;
    wire [7:0]out;
    reg reset =0;
    wire clk;
    clock cock(clk);
    wire connect;
    siggen sig(connect);
    wire [7:0]MEMA;
    wire [7:0]MEMB;
    wire infotime;
    wire [7:0]InfoPulse;
    wire [7:0]shiftSTORE;
    RxD RRR(connect,clk,reset,InfoPulse,infotime);

    wire [15:0]LOWEST;
    wire [15:0]HIGHEST;
    wire [15:0]HITOUT;
    wire fleshout;
    distanceProcess DDD(clk,InfoPulse,infotime,reset,LOWEST,HIGHEST,HITOUT,fleshout);
    wire [7:0] DDDlength;
    wire [3:0] execstate;
    assign DDDlength = DDD.lengthcopy;
    assign execstate = DDD.execstate;

    wire [15:0] quotient;
    wire [23:0] BIG;
    wire divdone;
    reg flesh;
    div DIVIDE(24'h2BA891,8'h3A,flesh,clk,reset,quotient,divdone);
    assign BIG = DIVIDE.biginp;


    wire [7:0]buf_out;
    wire [2:0]state;
    wire babydonthurtme;
    wire [2:0] count;
    wire [8:0] thingstogothrough;

    assign MEMA = RRR.MEMA;
    assign MEMB = RRR.MEMB;
    assign state = RRR.state;
    assign shiftSTORE = RRR.buffer.out;
    assign count = RRR.BC.store;
    assign babydonthurtme = RRR.ignore_all;
    
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(1,testbench);
        flesh =0;
        reset = 1;
        #2;
        reset = 0;
        #2;flesh = 1;#2;
        flesh = 0;
        #1000;
        $finish(1);
    end
endmodule

module clock(output reg out);
    reg dog;
    initial begin
        out =0;
        #0.5;
        dog=1;
    end
    always begin
        if (dog==1) begin
        #1 out = !out;
        end
        else #0.1;
    end
endmodule

module siggen(output reg out);
    reg [15:0]reg1 = 16'hAA55;
    reg [31:0]reg2 = 32'h9CA1FB04;
    integer i;
    initial begin
        out = 1'b1;
        #4;
        out =1'b0;
        #2;
        for (i = 0;i<16;i++) begin
            out=reg1[i];
            #2;
        end
        for (i = 0;i<32;i++) begin
            out=reg2[i];
            #2;
        end
    end
endmodule