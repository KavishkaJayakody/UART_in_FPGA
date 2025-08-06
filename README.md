# 🔌 UART Implementation on FPGA

A SystemVerilog-based FPGA project implementing a complete UART transceiver system with real-time display of received data using a 3-digit 7-segment display. Developed as a part of the **EN2111 – Electronic Circuit Design** module at the **Department of Electronic & Telecommunication Engineering, University of Moratuwa**.

---

## 📚 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Module Descriptions](#module-descriptions)
- [Simulation & Testing](#simulation--testing)
- [Hardware Implementation](#hardware-implementation)


---

## 🚀 Project Overview

This project demonstrates a complete UART transceiver system on an FPGA, integrating:

- **UART transmission and reception**
- **Data display on a 3-digit common anode 7-segment display**
- **SystemVerilog testbenches** for simulation
- **FPGA implementation** and validation using switches and buttons as input

The system is designed to receive 8-bit UART data and decode it for display if it matches the format `0000xxxx`.

---

## ✅ Features

- Baud Rate: **9600 bps**
- Start/Stop bit detection
- Data format: **8-bit, no parity, 1 stop bit**
- Real-time visualization on **3-digit 7-segment display**
- **Testbench verification** for all modules
- Debouncing logic for pushbuttons
- 50 MHz clock divider for UART timing

---

## 🧩 Module Descriptions

### 1. **UART_TX**
Handles UART transmission logic with a configurable baud rate generator. Serializes 8-bit data on pushbutton trigger.

### 2. **UART_RX**
Detects start/stop bits, samples incoming serial data, and reassembles it into 8-bit format.

### 3. **TX_TRIGGER**
Debounces and detects the rising edge of the pushbutton input to initiate UART transmission.

### 4. **BAUD_GENERATOR**
Generates precise baud rate ticks from a 50 MHz system clock for TX and RX synchronization.

### 5. **SEG_DECODER**
Converts received 8-bit data into three 4-bit BCD digits and drives the common anode 3-digit 7-segment display using multiplexing.

---

## 🧪 Simulation & Testing

Each module is supported with individual **SystemVerilog testbenches**. Simulations verify:

- UART transmission accuracy
- Start/stop bit synchronization
- Proper decoding of `0000xxxx` formatted data
- Segment multiplexing timing

> 💻 **Tools Used:** Quartus Prime / ModelSim

---

## 🔧 Hardware Implementation

- **Target Platform:** DE10 Nano FPGA board  
- **Clock Frequency:** 50 MHz  
- **UART Interface:** Onboard USB-to-UART  
- **Input Controls:** Onboard switches (for data), pushbuttons (for transmission)  
- **Output Display:** 3-digit common anode 7-segment display  
- **Synthesis Tool:**  Quartus Prime 

### System Behavior:

- Pressing a pushbutton triggers UART transmission of the current switch state
- Received data is displayed on the 7-segment display in real-time
- Data is shown only if it matches the pattern `0000xxxx` (i.e., upper nibble is `0000`)

---



