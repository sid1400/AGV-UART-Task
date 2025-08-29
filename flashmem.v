
module flash_outputter(input clk, 
    input [7:0]data,
    input flash,
    input reset,
    output reg [7:0]dataout,
    output reg flashout);

    reg [1:0]state;
    
    localparam IDLE = 2'b00;
    localparam MESC = 2'b01;
    localparam FLAG = 2'b02;

    always @(posedge clk) begin // you can only send messages every 3 turns
        if (!reset) begin
            case (state) 
                IDLE : begin
                    if (flash) begin
                        dataout <= data;
                        state <= MESC;
                    end
                end
                MESC : begin
                    flashout <= 1'b1;
                    state <= FLAG;
                end
                FLAG : begin
                    flashout <= 1'b0;
                    state <= IDLE;
                end

            endcase
        end
        else begin
            state <= 2'b00;
            flashout <= 1'b0;
        end
    end

endmodule

module flash_reader(input clk, input [7:0]datastream,input flashin,input reset,output reg [7:0]);

endmodule