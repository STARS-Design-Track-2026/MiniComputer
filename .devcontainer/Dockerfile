FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # C++ build toolchain (for Verilator testbenches)
    build-essential \
    # Simulation
    verilator \
    iverilog \
    # Synthesis and place-and-route
    yosys \
    nextpnr-ice40 \
    # ice40 bitstream tools (icepack, icetime, iceprog, icepll)
    fpga-icestorm \
    # Python for project scripts
    python3 \
    # Graphviz for block diagram .dot rendering
    graphviz \
    && rm -rf /var/lib/apt/lists/*
