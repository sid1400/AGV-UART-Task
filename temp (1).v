//TxD - To transmit your resultant information back again via UART
module TxD ( 
  input wire clock,
  input wire reset,
  input wire [15:0] lidar_header, //Containing the LiDAR header (0x55 0xAA) = 16 bits
  input wire [47:0] data,     // Containing the processed data to be transmitted - contains 6 bytes for the 3 variables
  input wire flashin, // To enable data storage in regout
  input wire flashout, // To enable transmission
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

  // For constructing or transmitting themessage 
  always @(posedge clock or posedge reset) begin
    if(reset) begin //Reset
      regout <= 64'b0; // temp for now
      tx_busy <= 1'b0;
      count <= 6'b111111; 
    end
    // Fill regout with the data to be transmitted
    else if( (state == 2'b01) && flashin && tx_busy == 0) begin 
      regout <= {
        lidar_header[15:8], // Set Header to 0x55 0xAA. This can also be written in an initial block
        lidar_header[7:0],
        data[47:32]; // Get max_distance_angle (2 bytes)
        data[31:16]; // Get min_distance_angle (2 bytes)
        data[15:0]; // Get obs_alert (2 bytes)
      };    
      state <= 2'b00;
    end
    // Send the message via UART
    else if( (state == 2'b10) && flashout && count > 0) begin
      transmitData <= regout[63]; //MSB first
      regout <= regout << 1; // shift regout left
      count <= count - 1;
    end
  end


  // For state
  always @(posedge clock or posedge reset) begin
    if(reset) begin //Reset
      state <= 2'b0;
    end
    else begin
      case(state)
        2'b00 : begin
          count <= 6'b111111; 
          tx_busy = 1'b0;
          if(flashin) state <= 2'b01;
          else if (flashout) begin
            state = 2'b10;
            count = 6'b111111;
          end
        end
        2'b01 : begin
        end
        2'b10 : begin
          tx_busy = 1'b1;
          if(count == 0) state <= 2'b11;
        end
        2'b11 : begin
        
        end
      endcase  
    end
  end
endmodule
