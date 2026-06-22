#include "Vpc.h"
#include "verilated.h"

#include <cstdint>
#include <iostream>

static void tick(Vpc& dut) {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vpc dut;
  int passed = 0, total = 0;

  auto check = [&](bool cond, const char* name) {
    ++total;
    if (cond) { ++passed; std::cout << "  [PASS] " << name << "\n"; }
    else             { std::cout << "  [FAIL] " << name << "\n"; }
  };

  dut.rst = 1; dut.we = 1; dut.next_addr = 0x24;
  tick(dut);
  check(dut.pc_addr == 0, "reset holds PC at 0 regardless of we");

  dut.rst = 0; dut.we = 1; dut.next_addr = 0x24;
  tick(dut);
  check(dut.pc_addr == 0x24, "load 0x24 when we=1");

  dut.we = 0; dut.next_addr = 0x40;
  tick(dut);
  check(dut.pc_addr == 0x24, "hold 0x24 when we=0");

  dut.rst = 1;
  tick(dut);
  check(dut.pc_addr == 0, "synchronous reset clears to 0");

  std::cout << "\n  " << passed << "/" << total << " passed\n\n";
  return (passed == total) ? 0 : 1;
}
