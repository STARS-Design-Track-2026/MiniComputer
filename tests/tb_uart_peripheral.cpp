#include "Vuart_peripheral.h"
#include "verilated.h"

#include <cstdint>
#include <iostream>

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vuart_peripheral dut;
  int passed = 0, total = 0;

  auto check = [&](bool cond, const char* name) {
    ++total;
    if (cond) { ++passed; std::cout << "  [PASS] " << name << "\n"; }
    else             { std::cout << "  [FAIL] " << name << "\n"; }
  };

  // Both TX and RX ready
  dut.read_req = 1; dut.write_req = 1; dut.write_data = 0x55;
  dut.txready = 1; dut.rxready = 1; dut.rxdata = 0xA7;
  dut.eval();
  check(dut.read_valid == 1,      "read_valid asserted when rxready=1");
  check(dut.write_done == 1,      "write_done asserted when txready=1");
  check(dut.read_data == 0x00A7, "read_data is zero-extended rxdata (0xA7)");
  check(dut.txdata == 0x55,      "txdata passes through write_data");
  check(dut.rxclk == 1,          "rxclk mirrors read_valid");
  check(dut.txclk == 1,          "txclk mirrors write_done");

  // Neither TX nor RX ready
  dut.txready = 0; dut.rxready = 0; dut.eval();
  check(dut.read_valid == 0, "read_valid deasserted when rxready=0");
  check(dut.write_done == 0, "write_done deasserted when txready=0");
  check(dut.rxclk == 0,      "rxclk deasserted when not ready");
  check(dut.txclk == 0,      "txclk deasserted when not ready");

  std::cout << "\n  " << passed << "/" << total << " passed\n\n";
  return (passed == total) ? 0 : 1;
}
