# Parameterizable Signed Arithmetic Datapath (ALU)

Final project of the **Digital Design using FPGA** course by NTI (National Telecommunication Institute) / ITIDA.

## 👥 Team and roles

| Member | Contribution |
|---|---|
| Abdelrahman Sherif ([@abdelrahmansherifmedhat1134](https://github.com/abdelrahmansherifmedhat1134)) | System top module (`top_signed_mult_div.v`) that links the multiplier and divider into one ALU; adapting both blocks to the top module (v2) and parameterizing the datapath; all testbenches; project report |
| Anas Mostafa ([@Anoos-mostafa](https://github.com/Anoos-mostafa)) | First version of the Radix-4 Booth multiplier |
| Mohamed Ashraf ([@11Mohamed-Ashraf11](https://github.com/11Mohamed-Ashraf11)) | First version of the non-restoring divider |

Earlier versions of each block are kept in [`redundant_files/`](redundant_files) to show how the design evolved (see `redundant_files/comments on files.txt`).

A robust, high-performance Verilog implementation of a parameterizable signed arithmetic unit. This datapath features a **Radix-4 Booth Multiplier** for high-speed multiplication and a **Non-Restoring Divider** for efficient division operations. It is designed with a focus on ASIC/FPGA best practices, including power-aware datapath routing, strict synthesis rules, and a unified hardware handshake interface.

## 🏗️ System Architecture

The project consists of three core components encapsulated within a unified top-level module:

### 1. Top-Level Integration (`top_signed_mult_div.v`)
The top module acts as a wrapper that abstracts the timing differences between the single-cycle multiplier and the multi-cycle divider. 
* **Opcode Decoding (`op_sel`):** Routes data based on a 2-bit operation selector (00: Multiply, 01: Quotient, 10: Remainder).
* **Power-Aware Clock Gating:** Utilizes the opcode to generate localized enable signals. Inactive sub-modules are isolated from switching activity, freezing their internal flip-flops and driving inputs to zero to conserve dynamic power.
* **Unified Handshake Interface:** Multiplexes the `busy`, `done`, and `err_dbz` (Divide-by-Zero) flags. External controllers simply pulse `start` and wait for `done`, treating the ALU as a timing-agnostic black box.
* **Dynamic Sign Extension:** Automatically replicates the sign bit of N-bit division results across the 2N-bit output bus using purely combinatorial logic, preventing latch inference.

### 2. Radix-4 Booth Multiplier (`multiplier.v`)
* Explores groups of 3 overlapping bits to halve the number of partial products compared to standard binary multiplication.
* Implements a **Parallel Adder Tree** architecture to calculate all partial products independently and sum them simultaneously, significantly reducing the critical path delay.
* Strictly adheres to sequential design rules, separating the combinatorial Radix-4 logic from the non-blocking D-Flip-Flop output assignments.

### 3. Non-Restoring Signed Divider (`division_non.v`)
* Implements the Non-Restoring algorithm (Shift, Add/Subtract) to calculate signed division iteratively without the clock-wasting penalty of explicit restoring steps.
* Features a robust two-process Finite State Machine (FSM) methodology.
* Automatically tracks the signs of the operands, computes on their absolute magnitudes, and applies correct sign logic at the end (ensuring the remainder sign inherently matches the dividend).

## 🧪 Verification & Simulation

Each block and the full datapath have their own testbench. The top-level testbenches run at 8 and 16 bits and print each result next to its expected value. They cover:
* Two's complement multiplication of every sign combination, zero and identity operands, and the asymmetric boundary `Max Positive * Max Negative`.
* Quotient and remainder outputs, including fractional results and negative operands.
* Divide-by-zero (`err_dbz`) and the signed overflow case `-128 / -1` (8-bit) or `-32768 / -1` (16-bit).

| Testbench | Unit under test |
|---|---|
| `tb/tb_top_signed_mult_div8.v`, `tb/tb_top_signed_mult_div16.v` | full datapath, `width` = 8 / 16 |
| `tb/tb_multiplier8.v`, `tb/tb_multiplier16.v` | Booth multiplier |
| `tb/tb_division_non.v` | non-restoring divider |

All 20 checks in each top-level testbench match their expected values in QuestaSim 2021.1.

### How to run (Questa / ModelSim)

`run_sim.do` compiles the RTL, runs a testbench and, in GUI mode, opens a grouped wave window.

```bash
vsim -do run_sim.do                                       # 16-bit top-level testbench with waves
vsim -do "set TB tb_top_signed_mult_div8; do run_sim.do"  # any other testbench
vsim -c -do "do run_sim.do; quit -f"                      # batch mode, console output only
```

## 📁 Repository layout

```
rtl/              top_signed_mult_div.v, multiplier.v, division_non.v
tb/               testbenches (top level 8/16-bit, multiplier, divider)
docs/             project report (PDF)
redundant_files/  earlier versions of the multiplier, divider and testbenches
comments.txt      integration notes
run_sim.do        Questa/ModelSim script
```

## 📄 Report

The full report, including the algorithms, design decisions and simulation results, is in [docs/signed-arithmetic-units-report.pdf](docs/signed-arithmetic-units-report.pdf).

## License

All rights reserved. No license is granted to reuse this code.
