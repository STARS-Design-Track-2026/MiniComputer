#include "Vminicomp.h"
#include "verilated.h"

#include <cstdint>
#include <iostream>
#include <queue>
#include <string>

static void tick(Vminicomp& dut) {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vminicomp dut;
  int passed = 0, total = 0;

  auto check = [&](bool cond, const char* name) {
    ++total;
    if (cond) { ++passed; std::cout << "  [PASS] " << name << "\n"; }
    else             { std::cout << "  [FAIL] " << name << "\n"; }
  };

  std::queue<uint8_t> rxq;
  const std::string input = "5\n3\n";
  for (char c : input) rxq.push(static_cast<uint8_t>(c));

  std::string tx;
  int newline_count = 0;
  dut.rst = 1; dut.txready = 1; dut.rxready = 0; dut.rxdata = 0;
  tick(dut); tick(dut);
  dut.rst = 0;

  for (int cyc = 0; cyc < 30000; ++cyc) {
    dut.txready = 1;
    if (cyc > 100 && !rxq.empty()) {
      dut.rxready = 1;
      dut.rxdata = rxq.front();
    } else {
      dut.rxready = 0;
      dut.rxdata = 0;
    }
    tick(dut);
    if (dut.rxclk && !rxq.empty()) rxq.pop();
    if (dut.txclk) {
      char c = static_cast<char>(dut.txdata);
      tx.push_back(c);
      if (c == '\n' && ++newline_count >= 4) break;
    }
  }

  std::cout << "  UART output: '" << tx << "'\n";
  check(tx.size() >= 16,                                              "output has at least 16 characters");
  check(tx.size() >= 3  && tx.substr(0,  3) == "5\r\n",   "first line echoes input '5'");
  check(tx.size() >= 8  && tx.substr(3,  5) == "120\r\n", "second line: 5! = '120'");
  check(tx.size() >= 11 && tx.substr(8,  3) == "3\r\n",   "third line echoes input '3'");
  check(tx.size() >= 16 && tx.substr(11, 5) == "006\r\n", "fourth line: 3! = '006'");

  std::cout << "\n  " << passed << "/" << total << " passed\n\n";
  return (passed == total) ? 0 : 1;
}
