//TxD - To transmit your resultant information back again via UART
module TxD ( 
  input wire clk,
  input wire reset;
  input wire lidar_header; //Containing the LiDAR header (0x55 0xAA)
  input wire data;     // Data to be transmitted - contains 6 bytes for the 3 variables
  input wire txenable; // To enable transmission
  output wire transmitData;
);
  // regout will contain the final message to be transmitted. it will contain 8 bytes = 64 bits
  reg [63:0] regout;

  always @( (posedge clk and posedge txenable) or posedge reset) begin
    if(reset) begin
      regout <= 64'b0; // temporary for now
      transmitData <= 1'b0;
    end
    else if(txenable) begin
      //Set Header to 0x55 0xAA. This can also be written in an initial block
      regout[63:56] <= lidar_header[15:8];
      regout[55:48] <= lidar_header[7:0];
      // Get max_distance_angle (2 bytes)
      regout[47:32] <= data[47:32];
      // Get min_distance_angle (2 bytes)
      regout[31:16] <= data[31:16];
      // Get obs_alert (2 bytes)
      regout[15:0] <= data[15:0];
      // Send the message via UART
      transmitData = regout;
    end
  end
endmodule
