`include "opcodes.vh"
`default_nettype none

module minicomp (
  input logic clk,
  input logic rst,
  output logic txclk,
  output logic rxclk,
  input logic txready,
  input logic rxready,
  output logic [7:0] txdata,
  input logic [7:0] rxdata,
  output logic [15:0] debug
);

  

endmodule
