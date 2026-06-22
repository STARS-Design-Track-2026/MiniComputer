#include "Valu.h"
#include "verilated.h"

#include <cstdint>
#include <iostream>

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Valu dut;
  int passed = 0, total = 0;

  auto check = [&](bool cond, const char* name) {
    ++total;
    if (cond) { ++passed; std::cout << "  [PASS] " << name << "\n"; }
    else             { std::cout << "  [FAIL] " << name << "\n"; }
  };

  dut.a = 5; dut.b = 3; dut.op = 0; dut.eval();  // ALU_ADD
  check(dut.out == 8 && dut.zero == 0, "ADD: 5 + 3 = 8, zero=0");

  dut.a = 3; dut.b = 5; dut.op = 1; dut.eval();  // ALU_SUB
  check(static_cast<uint16_t>(dut.out) == static_cast<uint16_t>(3 - 5)
        && dut.neg == 1 && dut.carry == 0,
        "SUB: 3 - 5 underflows, neg=1, carry=0");

  dut.a = 7; dut.b = 6; dut.op = 2; dut.eval();  // ALU_MUL
  check(dut.out == 42, "MUL: 7 * 6 = 42");

  dut.a = 0x1234; dut.b = 0xBEEF; dut.op = 3; dut.eval();  // ALU_CPA
  check(dut.out == 0x1234, "CPA: copies A (0x1234)");

  dut.op = 4; dut.eval();  // ALU_CPB
  check(dut.out == 0xBEEF, "CPB: copies B (0xBEEF)");

  std::cout << "\n  " << passed << "/" << total << " passed\n\n";
  return (passed == total) ? 0 : 1;
}
