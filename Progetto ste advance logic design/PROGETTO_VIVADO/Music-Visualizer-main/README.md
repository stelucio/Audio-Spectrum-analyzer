# FPGA Music Visualizer 🎙️🌈 | Audio Processing with Custom RISC-V

[![Platform: FPGA](https://img.shields.io/badge/Platform-FPGA-blue)]()
[![CPU: RISC-V](https://img.shields.io/badge/CPU-RISC--V-green)]()
[![Output: LED Matrix](https://img.shields.io/badge/Output-LED--Matrix-orange)]()
[![Input: Microphone](https://img.shields.io/badge/Input-Microphone-red)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📖 Overview
**FPGA Music Visualizer** is a digital design project developed on an **FPGA** platform that performs real-time audio analysis and visualization. The system integrates:
- A custom-designed **RISC‑V CPU** (RV32I) for signal processing coordination.
- **Microphone input** for real-time audio acquisition.
- **Frequency analysis logic** to detect intensity in different bands (Bass, Mid, Treble).
- **LED Matrix output** for vibrant, real-time visualization.

---

## 🎯 Project Goals
- **Real-time Processing** → Acquire audio and extract frequency information with minimal latency.
- **Custom Architecture** → Leverage a home-grown RISC‑V processor to manage the visualization logic.
- **Hardware/Software Co-design** → Balance tasks between dedicated hardware accelerators (for FFT/Filtering) and the CPU.

---

## 🛠️ System Architecture
The system is composed of several key modules:

1. **Audio Acquisition (Microphone)**
   - Interfaces with an external microphone via ADC.
   - Samples audio at a fixed rate for digital processing.

2. **Processing Unit (RISC‑V CPU)**
   - Implements the RV32I instruction set.
   - Manages the overall system flow and visualization patterns.
   - Coordinates with hardware filters/FFT logic.

3. **Frequency Detection**
   - Segments audio into Bass, Mid, and Treble components.
   - Calculates intensity/volume for each band.

4. **LED Matrix Driver**
   - Drives a LED matrix to display the audio spectrum or intensity patterns.

---

## 📅 Current Status
- [x] Base RISC‑V CPU implementation (RV32I)
- [ ] Audio acquisition module (ADC/Microphone interface)
- [ ] Bass/Mid/Treble detection logic
- [ ] LED Matrix driver implementation
- [ ] Integration and Final Demo

---

## 👥 Team
- **Giacomo Radin**
- **Stefano Luciani**
- **Federico Cattelan**

---

## 📜 License
This project is released under the MIT License – see the [LICENSE](LICENSE) file for details.
