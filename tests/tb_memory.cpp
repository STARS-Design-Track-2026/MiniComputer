#include "Vmemory.h"
#include "verilated.h"

#include <cstdint>
#include <iostream>

static void tick(Vmemory& dut) {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vmemory dut;
  int passed = 0, total = 0;

  auto check = [&](bool cond, const char* name) {
    ++total;
    if (cond) { ++passed; std::cout << "  [PASS] " << name << "\n"; }
    else             { std::cout << "  [FAIL] " << name << "\n"; }
  };

  dut.write_en = 0; dut.data_in = 0; dut.daddr = 0; dut.iaddr = 0; dut.eval();
  check(dut.instr_out == 0x3015, "instruction read at iaddr=0 returns 0x3015");

  dut.iaddr = 4; dut.eval();
  check(dut.instr_out == 0x40A5, "instruction read at iaddr=4 returns 0x40A5");

  dut.write_en = 1; dut.daddr = 0; dut.data_in = 0xBEEF;
  tick(dut);
  dut.write_en = 0; dut.daddr = 0; dut.eval();
  check(dut.data_out == 0xBEEF, "data write 0xBEEF to daddr=0, read back");

  dut.write_en = 1; dut.daddr = 4; dut.data_in = 0x1234;
  tick(dut);
  dut.write_en = 0; dut.daddr = 4; dut.eval();
  check(dut.data_out == 0x1234, "data write 0x1234 to daddr=4, read back");

  std::cout << "\n  " << passed << "/" << total << " passed\n\n";
  return (passed == total) ? 0 : 1;
}
