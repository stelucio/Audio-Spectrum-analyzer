# Audio Spectrum Analyzer on FPGA

An optimized, real-time Audio Spectrum Analyzer implemented on the **Nexys 4 DDR** FPGA board using the AMD Vivado Design Suite. The system captures live audio via an onboard MEMS microphone, processes the signal digitally, and visualizes the frequency spectrum on a VGA display.

## 🚀 System Architecture & Data Flow

The project implements a full digital signal processing (DSP) hardware pipeline:

1. **Audio Frontend (PDM Acquisition):**
   * **Sensor:** Omnidirectional MEMS microphone (*Analog Devices ADMP421*), featuring a high SNR of 61 dBA and sensitivity of -26 dBFS.
   * **Modulation:** Captures raw audio as a 1-bit **Pulse Density Modulation (PDM)** stream at an oversampled frequency of **2.4 MHz** (derived via an internal clock divider from the 100 MHz system clock).
   * **Formatting:** A dedicated *PDM Wrapper* converts the 1-bit stream into a signed 8-bit Two's Complement (CA2) format.

2. **Digital Downconversion & Filtering (DSP Pipeline):**
   * **CIC Filter (Cascaded Integrator-Comb):** Decimates the high-frequency 1-bit stream by a factor of $R=50$, converting it into 16-bit PCM samples at a **48 kHz** sampling rate, perfectly matching the audible spectrum.
   * **Compensation FIR Filter:** Equalizes the characteristic *passband droop* introduced by the CIC stage (approx. -3 dB at 15.28 kHz). Designed in MATLAB to achieve flat response (0-20 kHz) and remove high-frequency noise above 24 kHz to prevent aliasing. Generates an optimized 24-bit output.

3. **Spectral Analysis (Frequency Domain Accelerators):**
   * **FFT IP Core:** Computes a Discrete Fourier Transform (DFT) using an AMD Xilinx *FFT Compiler* over a window of **2048 points**, yielding a highly precise spectral resolution of **23.43 Hz** per bin.
   * **Hardware Optimizations:** Configured in *Pipelined Streaming I/O* and *Unscaled* modes to maximize Signal-to-Noise-and-Distortion ratio (SINAD) and eliminate arithmetic overflow. Truncation rounding is applied to balance mathematical precision with logic area constraints.
   * **DSP Utilization:** Complex multipliers are mapped into a 3-multiplier structure using native DSP48E1 slices, reducing the required hardware multiplier area by 25%.

4. **Energy Isolation & Storage Bridge:**
   * **Spectrum Isolator:** Exploits the Hermitian symmetry of the FFT output for real inputs, discarding the redundant upper half to isolate the first 1024 bins.
   * **Energy Matrix:** To avoid resource-heavy square-root hardware blocks, the system computes the squared magnitude (Energy Spectrum): $|X(k)|^2 = Re^2 + Im^2$.
   * **Dual-Port BRAM:** Acts as an asynchronous memory bridge, safely buffering the spectral energy matrix between the 100 MHz processing clock domain and the 25 MHz VGA video clock domain.

5. **Video Backend & Visualization (VGA Controller):**
   * **Display Output:** Renders a $640 \times 480$ @ 60 Hz VGA layout partitioning the audio spectrum into **32 distinct vertical bars** up to ~19.6 kHz.
   * **UI Styling:** Styled as a classic graphic equalizer VU-Meter with dynamic color gradients (Green $\rightarrow$ Yellow $\rightarrow$ Orange $\rightarrow$ Red).
   * **Peak Hold Engine:** Implements advanced envelope tracking with configurable Attack phases, an exact 20-frame Hold matrix, and a controlled exponential decay (Release) to cleanly track instantaneous musical peaks.

## 📊 Synthesis & Implementation Results

* **Power Dissipation:** Highly optimized power profile with an estimated total on-chip power consumption of just **0.455 W**.
* **FPGA Resource Allocation:** Excellent balancing across the Artix-7 fabric. The most dense block remains the Block RAM (44% utilization) due to the spectral depth required for visual interpolation.
* **Timing Closure:** All hardware timing constraints met with positive margins ($WNS = +0.623\text{ ns}$), guaranteeing reliable long-term system stability on-silicon.


## # <img src="https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png" width="35"> Run Matlab simulations
* Open 	MATLAB_SCRIPT_ DIGITAL _FILTER,FFT simulations.pdf
* Copy the code on Matlab editor and run
* Change the frequency of the input signal to see the output after filtering 
  


## 🚀 How to run the project
* Downlaod the folder PROGETTO_VIVADO
* Open the folder in vivado
* Run simulation, implementation and bitstream
* Open target and connect the board
* Connect the vga cable from the board to the monitor
* Use a tone simulator in audible spectrum to see the spectrum on the monitor and enjoy the project

