//TxD - To transmit your resultant information back again via UART
module TxD ( 
  input wire clock,
  input wire reset,
  input wire [15:0] lidar_header, //Containing the LiDAR header (0x55 0xAA) = 16 bits
  input wire [47:0] data,     // Containing the processed data to be transmitted - contains 6 bytes for the 3 variables
  input wire flashin, // To enable transmission process
  output reg transmitData, // output
  output reg tx_busy // To indicate process in progress
);
  // Internal Registers:
  reg [63:0] regout;  // regout will contain the final message to be transmitted. it will contain 8 bytes = 64 bits
  reg [1:0] state;
  reg [5:0] count; // counter
  // 00 = idle
  // 01 = regout filling state
  // 10 = transmission mode state
  // 11 = transmission compelte state


  always @(posedge clock or posedge reset) begin
    if(reset) begin //Reset
      regout <= 64'b0; // temp for now
      tx_busy <= 1'b0;
      count <= 6'b111111;
      state <= 2'b00;
      transmitData <= 1'b1;
    end
    else begin
    // For constructing or transmitting themessage 
      // Send the message via UART
      // For state
      case(state)
        2'b00 : begin
          count <= 6'b111111; 
          tx_busy <= 1'b0;
          transmitData <= 1'b1;
          if(flashin) state <= 2'b01;
        end
        2'b01 : begin
          if(flashin && tx_busy == 0) begin 
            regout <= {
              lidar_header[15:8], // Set Header to 0x55 0xAA. This can also be written in an initial block
              lidar_header[7:0],
              data[47:32], // Get max_distance_angle (2 bytes)
              data[31:16], // Get min_distance_angle (2 bytes)
              data[15:0] // Get obs_alert (2 bytes)
            };
          end
          else if(!flashin) begin
            state <= 2'b10;
            count <= 6'b111111;
          end
        end
        2'b10 : begin
          tx_busy <= 1'b1;
          if(count > 0) begin
            transmitData <= regout[63]; //MSB first
            regout <= regout << 1; // shift regout left
            count <= count - 1;
          end
          else if (count==0) begin
            transmitData <= regout[63]; //MSB first
            regout <= regout << 1; // shift regout left
            state <= 2'b11;
          end
        end
        2'b11 : begin
          state <= 2'b00;       
          tx_busy <= 1'b0;
          count <= 6'b111111;
          transmitData <= 1'b1;
        end
        default : begin          
          state <= 2'b00;       
          tx_busy <= 1'b0;
          count <= 6'b111111;
        end
      endcase
    end
  end
endmodule


module testbench;
wire testout, testbusy;
reg clock, reset, flashin;
reg [15:0] lidar_header = 16'h55AA;
reg [47:0] data = 48'b11001001010101111111111111001111111000000000010;
TxD testTx(
  .clock(clock),
  .reset(reset),
  .lidar_header(lidar_header),
  .data(data),
  .flashin(flashin),
  .transmitData(testout),
  .tx_busy(testbusy)
);

// State monitoring
always @(posedge clock) begin
  $display("Time=%0t: state=%b, transmitData=%b, flashin=%b, count=%d, regout=%b", 
           $time, testTx.state, testout, flashin, testTx.count, testTx.regout);
end

// Simulation control
initial #900 $finish;
initial begin  
  $display ("Lidar Header: %h", lidar_header);
  $display ("Data: %b", data);
end
initial begin clock = 0; forever #2 clock = ~clock; end
initial fork
  reset = 1;
  flashin = 0;
  #5 reset = 0;
  #20 flashin = 1;    // Start transmission process
  #40 flashin = 0;
join

// For waveform generation
initial begin
  $dumpfile("temp.vcd");
  $dumpvars(0, testbench);
  $display ("Lidar Header: %h", lidar_header);
  $display ("Data: %h", data);
end
endmodule

