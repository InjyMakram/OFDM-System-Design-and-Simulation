
This project focuses on the design and simulation of an OFDM (Orthogonal Frequency Division Multiplexing) communication system, covering both theoretical analysis and practical implementation.

Key Points:
- **Objective**: To calculate system capacity and optimize power allocation across subcarriers using the water-filling algorithm, followed by simulating OFDM under realistic channel conditions.
- **Tools Used**: MATLAB for coding, QAM modulation/demodulation, AWGN noise, Rayleigh fading channels.
- **Outcomes**: Visualized BER vs. SNR performance for 4, 16, and 64 QAM under multipath fading, demonstrating practical system resilience.


Key Responsibilities:
- **Capacity Calculation**: 
  - Performed hand analysis to calculate the capacity of an OFDM system with four subcarriers.
  - Analyzed power distribution using the water-filling algorithm to maximize capacity.
- **Power Allocation Optimization**:
  - Developed a water-filling algorithm in MATLAB that can handle any number of subcarriers and noise/channel conditions.
- **OFDM Simulation**:
  - Simulated an OFDM system, generating QAM (Quadrature Amplitude Modulation) symbols, applying them to multipath Rayleigh fading channels, and adding AWGN (Additive White Gaussian Noise) to simulate real-world conditions.
  - Implemented equalization and QAM demodulation, then plotted Bit Error Rate (BER) vs. Signal-to-Noise Ratio (SNR) for different QAM schemes (4, 16, 64 QAM).
  - Simulated a multi-path Rayleigh fading channel with 6 paths and relative delays.
  
