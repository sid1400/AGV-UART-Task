`include "topModule.v"

module testbench;
    wire [7:0]out;
    reg reset =0;
    wire clk;
    clock cock(clk);
    wire connect;
    siggen sig(connect);
    wire [7:0]RDX_MEMA;
    wire [7:0]RDX_MEMB;
    wire RDX_infotime;
    wire [7:0]RDX_InfoPulse;
    wire [7:0]RDX_shiftSTORE;
    RxD RRR(connect,clk,reset,RDX_InfoPulse,RDX_infotime);

    wire [15:0]DX_LOWEST;
    wire [15:0]DX_HIGHEST;
    wire [15:0]DX_HITOUT;
    wire DX_fleshout;
    distanceProcess DDD(clk,RDX_InfoPulse,RDX_infotime,reset,DX_LOWEST,DX_HIGHEST,DX_HITOUT,DX_fleshout);
    wire [8:0] DX_DDDlength;
    wire [8:0] DX_DDDlengthnoncopy;
    wire [3:0] DX_DDDlengthnoncopylimit;
    wire [3:0] DX_DDDlengthlimit;
    wire [3:0] DX_execstate;
    wire [23:0] mult1;
    wire [23:0] mult2;
    assign mult1 = DDD.multipliedval1;
    assign mult2 = DDD.multipliedval2;
    assign DX_DDDlength = DDD.lengthcopy;
    assign DX_DDDlengthnoncopy = DDD.length;
    assign DX_DDDlengthlimit = DDD.trimmed_length;
    assign DX_DDDlengthnoncopylimit = DDD.trimmed_lengthcopy;
    assign DX_execstate = DDD.execstate;
    wire [15:0] DX_quot;
    assign DX_quot = DDD.divider1.lessbig;
/*
    wire [15:0] quotient;
    wire [23:0] BIG;
    wire divdone;
    reg flesh;
    div DIVIDE(24'h2BA891,8'h3A,flesh,clk,reset,quotient,divdone);
    assign BIG = DIVIDE.biginp;  */

    wire [2:0]RDX_state;
    wire RDX_babydonthurtme;
    wire [2:0] RDX_babydonthurtmecount;

    assign RDX_MEMA = RRR.MEMA;
    assign RDX_MEMB = RRR.MEMB;
    assign RDX_state = RRR.state;
    assign RDX_shiftSTORE = RRR.buffer.out;
    assign RDX_count = RRR.BC.store;
    assign RDX_babydonthurtme = RRR.ignore_all;

    wire TXD_OUTPUT;
    wire TXD_write;
    TxD Transmit(clk,reset,16'hAA55,{DX_LOWEST,DX_HIGHEST,DX_HITOUT},DX_fleshout,DX_fleshout,TXD_OUTPUT,TXD_write);
    
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(1,testbench);
        reset = 1;
        #2;
        reset = 0;
        #2;
        #1800;
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
    reg [103:0]reg2 = 104'h78452390782211CDAB9CA1FB04;
    reg [359:0]amigay = 360'h117512342000212111110FAB11ABABCD112312340310029903000ABCAAAAA0BC00AB00070008FBAD3311001114; //womp womp sha356 aaa key

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
        for (i = 0;i<360;i++) begin
            out=amigay[i];
            #2;
        end
        assign out = 1'b1;#2;
        
    end
endmodule