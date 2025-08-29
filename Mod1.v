
module RxD(input wire stream, 
    input wire clock,
    input wire reset,
    output reg [7:0]outstream,
    output reg infodump);

    wire [7:0]buffer_out;
    wire clock_out;

    reg [2:0]state; //0-> no bit 1-> entered into loop 1st 2-> entered into loop 3->getting length val 4->getting val 5->turning value indicator on 6->Stop conditon
    // for now if we dont get adress, we just play the game, assuming same structure of FS bits at the start;
    reg ignore_all;
    reg clock_trig;
    reg info_pulse;
    reg [7:0] MEMA;
    reg [7:0] MEMB;

    shiftreg buffer(stream,clock,~clock_trig,reset,buffer_out);
    counter BC(clock,clock_trig,reset,clock_out);



    always @(posedge clock) begin
        if (!reset) begin
            if (state == 0) begin
                clock_trig <=0;
                infodump <= 1'b0;
                if (stream == 0) begin state <= 3'b001; clock_trig <=1'b1;end
            end
            else begin
                if (info_pulse) begin
                    info_pulse <= 1'b0;
                    infodump <= 1'b1;
                end
                else begin
                    infodump <= 1'b0;

                end
                case(state)
                    3'b001 : begin
                        if (clock_out) begin
                            MEMA <= buffer_out;
                            state <= 3'b010;
                        end
                    end
                    3'b010 : begin
                        if (clock_out) begin
                            MEMB <= buffer_out;
                            state <= 3'b011;
                        end
                    end
                    3'b011 : begin
                        if (clock_out) begin
                            MEMB <= 0;
                            MEMA <= {buffer_out,1'b0} + 4;
                            outstream <= buffer_out;

                            state <= 3'b100;
                            if ((MEMA == 8'h55) && (MEMB == 8'hAA)) begin 
                                ignore_all <=1'b0;
                                info_pulse <=1;
                            end
                            else ignore_all <=1'b1;
                        end
                    end
                    3'b100 : begin
                        if (clock_out) begin
                            MEMA-=1;
                            outstream <= buffer_out;
                            if (ignore_all==0) info_pulse<=1;
                            if (MEMA == 0)  state <=3'b101; 
                        end
                        else
                            info_pulse<=0;
                    end
                    3'b101 : begin state <= 3'b000; infodump=1'b0;info_pulse=1'b0; end
                endcase
            end
        end
        else begin
            state <= 3'b000;
            ignore_all <= 1'b1;
            clock_trig <= 1'b0;
            MEMA <= 8'b00000000;
            MEMB <=8'b00000000;
            outstream <= 8'b00000000;
            infodump <=1'b0;
            info_pulse <= 1'b0;
        end
    end
endmodule