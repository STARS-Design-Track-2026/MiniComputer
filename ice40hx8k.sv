
module ice40hx8k (hwclk,pb,ss7,ss6,ss5,ss4,ss3,ss2,ss1,ss0,left,right,red,green,blue,
                  Rx, Tx, CTSn, DCDn);
    input hwclk;
    input [20:0] pb;
    output [7:0] ss7,ss6,ss5,ss4,ss3,ss2,ss1,ss0;
    output [7:0] left,right;
    output red,green,blue;
    input Rx;
    output Tx, CTSn, DCDn;

    reg [15:0] ctr = 0;
    reg hz100 = 0;
    always @ (posedge hwclk)
      if (ctr == 60000)
        begin
          ctr <= 0;
          hz100 <= ~hz100;
        end
      else
        ctr <= ctr + 1;

    assign CTSn = ~1; // clear to send
    assign DCDn = ~1; // carrier detect (makes Kermit happy)

// Example calculation (SIMPLE):
//
//    Fref * (DIVF + 1)
// ---------------------------- = out
//    2^(DIVQ + 2) * (DIVR + 1)
//
//     12  *  (95 + 1)
// ---------------------------- = 288
//      2^(0 + 2) * (0 + 1)

// Example calculation (PHASE_AND_DELAY):
// 
//      Fref * (DIVF + 1)
//   ---------------------------- = out
//          (DIVR + 1)
//
//       12  * (21 + 1)
//   ---------------------------- = 264
//          ( 0 + 1 )

// Want the serial clock to be about 2 * 16 * 115200 = 3686400
//       12  * ( 3 + 1)
//   ---------------------------- = 3692307.7  (within 0.16% of target)
//          (12 + 1 )

    /* The PLL instance */
    wire BYPASS;
    wire RESETB;
    wire serclk;
    wire reset;

    assign BYPASS = 1'b0;
    assign RESETB = 1'b1;
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("PHASE_AND_DELAY"),
        .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
        .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
        .PLLOUT_SELECT("SHIFTREG_0deg"),
        .SHIFTREG_DIV_MODE(1'b0), // 0 => div-by-4; 1 => div-by-7
        .FDA_FEEDBACK(4'b0000),
        .FDA_RELATIVE(4'b0000),
        .DIVR(4'b1100),        // 12
        .DIVF(7'b0000011),     // 3
        .DIVQ(3'b000),         // 0
        .FILTER_RANGE(3'b001)  // 1
    ) pll (
        .REFERENCECLK (hwclk),
        .PLLOUTCORE   (serclk),
        .BYPASS       (BYPASS),
        .RESETB       (RESETB)
        //.LOCK (LOCK)
    );

    wire [7:0] txdata;
    wire       txclk;
    wire       txready;
    wire [7:0] rxdata;
    wire       rxclk;
    wire       rxready;

    uart uart_inst(
      .clk(hwclk),
        .rst(0),
        .input_axis_tdata(txdata),
        .input_axis_tvalid(xmit),
        .input_axis_tready(txready),
        .output_axis_tdata(rxdata),
        .output_axis_tvalid(rxready),
        .output_axis_tready(recv),
        .rxd(Rx),
        .txd(Tx),
        .prescale(13)
    );

    // Direct handshake: CPU generates combinational pulses, pass to UART unchanged.
    assign xmit = txclk;
    assign recv = rxclk;

    reset_on_start ros (reset, hwclk, pb[3] && pb[0] && pb[16]);
    top top_inst(
      hwclk, reset, pb,
      left, right, ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
      red, green, blue,
      txdata,
      rxdata,
      txclk, rxclk,
      txready, rxready
    );

endmodule

module reset_on_start(reset, clk, manual);
  output reset;
  input clk;
  input manual;

  // Hold reset high long enough for clocked logic to settle on power-up.
  reg [19:0] startup = 0;
  assign reset = ~startup[19] | manual;
  always @ (posedge clk, posedge manual)
    if (manual == 1)
      startup <= 0;
    else if (!startup[19])
      startup <= startup + 1'b1;

endmodule
