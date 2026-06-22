`default_nettype none

module uart_peripheral (
  input logic read_req,
  input logic write_req,
  input logic [7:0] write_data,
  input logic txready,
  input logic rxready,
  input logic [7:0] rxdata,
  output logic [15:0] read_data,
  output logic read_valid,
  output logic write_done,
  output logic [7:0] txdata,
  output logic txclk,
  output logic rxclk
);



endmodule
