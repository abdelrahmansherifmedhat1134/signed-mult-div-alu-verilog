# Parameterizable Signed Arithmetic Datapath (ALU)

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

The system is fully verified using a comprehensive, automated testbench (`tb_signed_mult_div.v`). The testbench validates:
* Pure Two's Complement arithmetic logic.
* Hardware edge cases including Signed Division Overflow (e.g., `-128 / -1`), Divide-by-Zero assertions, and Asymmetric Boundaries (`Max Positive * Max Negative`).
* Output multiplexing and the integrity of the unified `done` pulse across single-cycle and multi-cycle operations.

### How to Run the Simulation (Questa / ModelSim)
An automated Tcl script (`run_sim.do`) is provided to compile the design, launch the simulator, and instantly generate a beautifully formatted and grouped wave window.

1. Clone the repository and navigate to the project directory.
2. Open your Questa/ModelSim terminal.
3. Execute the following command:
   ```bash
   vsim -gui -do run_sim.do