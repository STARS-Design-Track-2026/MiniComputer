`default_nettype none

module memory #(
  parameter memloc = "cpu.mem"
)(
  input  logic        clk,
  // Data write port
  input  logic [15:0] data_in,
  input  logic        write_en,
  input  logic [7:0]  daddr,     // byte address into data region (0-based)
  // Instruction read port (combinational)
  input  logic [7:0]  iaddr,     // byte address from PC
  output logic [15:0] instr_out,
  // Data read port (combinational)
  output logic [15:0] data_out
);

  

endmodule
