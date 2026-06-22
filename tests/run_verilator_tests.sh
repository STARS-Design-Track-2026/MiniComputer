#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/verilator"
mkdir -p "$BUILD_DIR"

run_top_test() {
  local top="$1"
  local tb="$2"
  local objdir="$BUILD_DIR/$top"
  echo "==> $top"
  verilator --cc --build -j 0 -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC \
    --top-module "$top" --Mdir "$objdir" \
    "$ROOT_DIR/top.sv" --exe "$ROOT_DIR/tests/$tb"
  "$objdir/V$top"
}

run_uart_test() {
  local top="$1"
  local tb="$2"
  local objdir="$BUILD_DIR/$top"
  echo "==> $top"
  verilator --cc --build -j 0 -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC \
    --top-module "$top" --Mdir "$objdir" \
    "$ROOT_DIR/uart/uart.v" "$ROOT_DIR/uart/uart_tx.v" "$ROOT_DIR/uart/uart_rx.v" \
    --exe "$ROOT_DIR/tests/$tb"
  "$objdir/V$top"
}

run_top_test alu tb_alu.cpp
run_top_test pc tb_pc.cpp
run_top_test regfile tb_regfile.cpp
run_top_test memory tb_memory.cpp
run_top_test uart_peripheral tb_uart_peripheral.cpp
run_top_test minicomp tb_minicomp.cpp

run_uart_test uart_tx tb_uart_tx.cpp
run_uart_test uart_rx tb_uart_rx.cpp
run_uart_test uart tb_uart.cpp

echo "All Verilator tests passed."
