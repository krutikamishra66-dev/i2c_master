 # I2C_MASTER Protocol Controller (Digital VLSI ASIC Flow)

A complete **Digital VLSI ASIC Design Flow** for an **I2C Master Controller**, covering RTL design, functional verification, logic synthesis, and Physical Design (Place & Route) using the **Cadence Tool Suite**.

---

## Overview

This project implements an I2C Controller designed to manage serial communication with 7-bit addressing slaves over two bidirectional lines (`SDA` and `SCL`). The design is fully verified and taken through logic synthesis and physical layout using Cadence EDA software.

---

## Digital Design & Implementation Flow
+------------------+     +-------------------+     +------------------+
|   RTL Design     | --> | Logic Synthesis   | --> | Physical Design  |
| (Verilog/SystemV)|     | (Cadence Genus)   |     | (Cadence Innovus)|
+------------------+     +-------------------+     +------------------+

1. **RTL Design**: Behavior and FSM implemented in Verilog.
2. **Functional Verification**: Verified using Cadence Xcelium logic simulator.
3. **Logic Synthesis**: Gate-level netlist generated using Cadence Genus targeting standard cell libraries.
4. **Physical Design (P&R)**: Floorplanning, Placement, Clock Tree Synthesis (CTS), and Routing performed using Cadence Innovus.

---

## Cadence Tool Suite Used

| Stage | Cadence Tool | Description |
| :--- | :--- | :--- |
| **Simulation** | **Xcelium** (`xrun`) | RTL behavioral and gate-level simulation |
| **Synthesis** | **Genus** (`genus`) | RTL-to-GTL synthesis, timing optimization |
| **Place & Route** | **Innovus** (`innovus`) | Floorplanning, CTS, Placement & Routing |
| **Waveform View**| **SimVision** | Waveform analysis for RTL debugging |

---

## Module I/O Ports

| Signal | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1 | Main system clock |
| `rst_n` | Input | 1 | Active-low system reset |
| `enable` | Input | 1 | Trigger signal to initiate transaction |
| `rw` | Input | 1 | Read (`1`) / Write (`0`) selection |
| `addr` | Input | 7 | Target slave address |
| `data_in` | Input | 8 | Data byte for write transmission |
| `data_out`| Output | 8 | Received data byte from slave |
| `busy` | Output | 1 | Active when a transfer is in progress |
| `sda` | Inout | 1 | Serial Data line (Open-Drain) |
| `scl` | Inout | 1 | Serial Clock line |

---

## How to Run

### 1. Functional Simulation (Xcelium)

```bash
xrun -sv hdl/i2c_master.v testbench/i2c_master_tb.v -gui
2. Logic Synthesis (Genus)
Bash
genus -f scripts/synthesis.tcl -log synthesis.log
3. Physical Design (Innovus)
Bash
innovus -files scripts/pnr.tcl -log innovus.log
Directory Structure
Plaintext
├── hdl/            # Verilog source files (RTL)
├── testbench/      # Testbench and stimulus files
├── scripts/        # Tcl scripts for Genus (Synthesis) & Innovus (P&R)
├── constraints/    # SDC constraint files (timing/clock setup)
├── reports/        # Generated Area, Timing, and Power reports
