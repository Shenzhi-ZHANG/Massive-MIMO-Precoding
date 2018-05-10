# Massive-MIMO-Precoding

This repository contains MATLAB code for simulation of the downlink precoding of Massive MIMO system. I proposed two optimizations for downlink precoding under the use of 1-bit DAC and imperfect CSI.

**Note**: Change the parameters to make the system correspond to your need. I have been playing around with these parameters. So the current parameters setting are NOT consistent with the sample output. Several parameters that need more attention:

* **Num_BS_Antennas**: The numebr of antennas at the base station.

* **Num_UE**: The number of UEs, assume each UE just has a single antenna.

* **SNR**: The range of SNR we simulate.

* **Symbols**: The constellation points specified to the modulation scheme chosen.

* **f_dop**: The doppler spread of the channel.

* **f_symb**: The sampling rate of channel matrix.

* **multi**: The weight of additive estimation error to channel estimation.

System Model
---

Figure taken from *Jacobsson S, Durisi G, Coldrey M, et al. Quantized Precoding for Massive MU-MIMO[J]. 2016*

![image](https://github.com/Shenzhi-ZHANG/Massive-MIMO-Precoding/blob/master/system-model.png)

Files
---

* **main.m**: The entry function for robust ZF precoder.

* **main_linear.m**: The entry function for comparing three conventional precoders.

* **Transmit.m**: Complete source data generation, modulation, precoding, transmission and detection.

* **Transmit_linear.m**: Same functionality as transit.m, but designed for the conventional precoders.

* **MF_Precoder.m**: Conventional Matched Filter Precoder. Aim to maximize the SNR at receiving end.

* **ZF_Precoder.m**: Conventional Zero Forcing Precoder. Aim to eliminate the interference among users.

* **WF_Precoder.m**: Conventional Wiener Filter Precoder. Aim to minimize MSE between sending sequence and received sequence.

* **Gen_Channel2.m**: Generate a Rayleigh and flat-fading channel given doppler spread and sampling rate.

* **Robust_CSI.m**: Implementation of robust CSI algorithm.

* **Robust_DAC.m**: Implementation of robust 1-bit DAC algorithm.

* **Robust_ZF_Precoder.m**: Integrate Robust_CSI and Robust_DAC. Implement robust ZF precoder.

* **Quantize_x.m**: Simulate DAC, realize quantization.

* **Decider.m**: Detect the received constellation point. 

Sample Output
---

Comparison between MF, ZF, WF precoders:

![image](https://github.com/Shenzhi-ZHANG/Massive-MIMO-Precoding/blob/master/conventional-precoders.png)
