#include "Vregfile.h"
#include "verilated.h"

#include <cstdint>
#include <iostream>

static void tick(Vregfile& dut) {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vregfile dut;
  int passed = 0, total = 0;

  auto check = [&](bool cond, const char* name) {
    ++total;
    if (cond) { ++passed; std::cout << "  [PASS] " << name << "\n"; }
    else             { std::cout << "  [FAIL] " << name << "\n"; }
  };

  dut.rst = 1; dut.write_en = 0; dut.reg_a = 0; dut.reg_b = 1;
  dut.reg_in = 0; dut.data_in = 0;
  tick(dut);
  dut.rst = 0;

  dut.reg_a = 2; dut.reg_b = 3; dut.eval();
  check(dut.reg_out_a == 0, "reset clears R2 to 0");
  check(dut.reg_out_b == 0, "reset clears R3 to 0");

  dut.write_en = 1; dut.reg_in = 2; dut.data_in = 0x1234;
  tick(dut);
  dut.write_en = 0; dut.reg_a = 2; dut.reg_b = 3; dut.eval();
  check(dut.reg_out_a == 0x1234, "write 0x1234 to R2, read back via port A");
  check(dut.reg_out_b == 0,      "R3 unaffected after writing R2");

  dut.write_en = 1; dut.reg_in = 3; dut.data_in = 0xABCD;
  tick(dut);
  dut.write_en = 0; dut.reg_a = 3; dut.reg_b = 2; dut.eval();
  check(dut.reg_out_a == 0xABCD, "write 0xABCD to R3, read back via port A");
  check(dut.reg_out_b == 0x1234, "R2 still holds 0x1234 via port B");

  std::cout << "\n  " << passed << "/" << total << " passed\n\n";
  return (passed == total) ? 0 : 1;
}
