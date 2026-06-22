`default_nettype none

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  
  minicomp mc_inst (
    .clk(hz100),
    .rst(reset),
    .txclk(txclk),
    .rxclk(rxclk),
    .txready(txready),
    .rxready(rxready),
    .txdata(txdata),
    .rxdata(rxdata),
    .debug(debug)
  );

  logic [63:0] debug;

  // debug will consist of:
  /*
    assign debug[0] = rxclk;
    assign debug[1] = txclk;
    assign debug[2] = txready;
    assign debug[3] = rxready;
    assign debug[11:4] = rxdata;
    assign debug[19:12] = txdata;
    assign debug[35:20] = mem_instr_out;
  */
  
  // Change this to connect to your CPU's internal signals for debugging.
  // You can use as many bits of debug as you want, but don't forget to 
  // change both minicomp and the top module to match!

  // We provide you with the following ssdec instances so you can visualize 
  // the instruction in the 7-segment displays. You can change the input to these
  // to display whatever you want, but we recommend using them to display the current
  // instruction for debugging purposes.
  
  // ssdec ssdec_inst_1 (
  //   .in(debug[35:32]),
  //   .enable(1'b1),
  //   .out(ss3[6:0])
  // );
  // ssdec ssdec_inst_2 (
  //   .in(debug[31:28]),
  //   .enable(1'b1),
  //   .out(ss2[6:0])
  // );
  // ssdec ssdec_inst_3 (
  //   .in(debug[27:24]),
  //   .enable(1'b1),
  //   .out(ss1[6:0])
  // );
  // ssdec ssdec_inst_4 (
  //   .in(debug[23:20]),
  //   .enable(1'b1),
  //   .out(ss0[6:0])
  // );
  // assign left = debug[19:12];
  // assign right = debug[11:4];

endmodule

// TODO: insert your ssdec module below from a previous lab if you would like to use it.