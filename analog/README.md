# Analog Dir

## High Level Requirements

## 1. Quantised Error - Baseline

When the input signal is much larger than LSB, the quantised error is not significantly correlated with the signal and has approximated a uniform distribution, N(μ = 0, σ²), thus:

$$\mu = E[e] = \frac{1}{LSB} \int_{-LSB/2}^{LSB/2} e \, de = \frac{1}{LSB} \frac{e^2}{2} \bigg|_{-LSB/2}^{LSB/2} = 0$$

$$\sigma^2 = E[e^2] = \frac{1}{LSB} \int_{-LSB/2}^{LSB/2} e^2 \, de = \frac{1}{LSB} \frac{e^3}{3} \bigg|_{-LSB/2}^{LSB/2} = \frac{2}{3LSB} \left(\frac{LSB}{2}\right)^3 = \frac{LSB^2}{12}$$

For a zero mean noise, the V_noise,rms is equal to the standard deviation, σ.

$$V_{noise,rms} = \sigma = \sqrt{\frac{LSB^2}{12}} = \frac{LSB}{\sqrt{12}}$$

Considering a full swing sine wave centered at VCC/2, the RMS value is A/√2, thus the V_signal,rms is

$$V_{signal,rms} = \frac{A}{\sqrt{2}} = \frac{VCC}{2 \cdot \sqrt{2}}$$

Then proceeding to calculate the ideal SNR

$$SNR = \frac{P_{signal}}{P_{noise}} = \frac{V^2_{signal,rms}}{V^2_{noise,rms}}$$

$$SNR_{dB} = 20 \log\left(\frac{V_{signal,rms}}{V_{noise,rms}}\right) = 20 \log\left(\frac{\frac{VCC}{2\sqrt{2}}}{\frac{LSB}{\sqrt{12}}}\right) = 20 \log\left(\frac{\sqrt{12} \cdot VCC}{2\sqrt{2} \cdot LSB}\right)$$

For an ideal 8 bits ADC and 3.3V as VCC, the ideal SNR_dB is **49.9 dB**

## 2. Non-Quantised Error - Allowed SNR Loss

The allow SNR loss is relative to the quantisation floor and added to the total noise by root-sum-square. The SNR loss makes the total noise, V_tot grow by a factor a relative to the ideal case, V_q.

$$SNR_{actual} = SNR_{ideal} - \Delta = 20 \log\left(\frac{V_s}{V_{tot}}\right)$$

$$20 \log\left(\frac{V_s}{V_q}\right) - \Delta = 20 \log\left(\frac{V_s}{V_{tot}}\right)$$

$$20 \log\left(\frac{V_{tot}}{V_q}\right) = \Delta$$

$$\frac{v_{tot}}{v_q} = 10^{\Delta/20} = a$$

$$v_{tot} = a \cdot v_q$$

Then, splitting the total noise in quantised + non quantised (RSS)

$$V^2_{tot} = V^2_{nonq} + V^2_q$$

$$(a \cdot V_q)^2 = V^2_{nonq} + V^2_q$$

$$V^2_{nonq} = V^2_q(a^2 - 1)$$

$$V_{nonq} = V_q\sqrt{a^2 - 1} = V_q\sqrt{10^{\Delta/10} - 1}$$

With an allowed Δ of 3 dB, the v_nonq is **3.71 mV**.

## 3. Equivalent Noise Bandwidth (ENBW)

It is the bandwidth equivalent of noise of a perfect rectangular filter that allows the same amount of power to pass as the cumulative bandwidth.

$$ENBW = \frac{\int_{-\infty}^{\infty} |H(f)|^2 \, df}{2|H(0)|^2} = \frac{\int_0^{\infty} |H(f)|^2 \, df}{|H(0)|^2}$$

Noise density: e_n [V/√Hz], if we consider an anti-aliasing 1st order filter, 1.571 f_c, and considering a cutoff frequency of 40kHz

$$ENBW = 1.571 \times 40kHz = 62.8 \, kHz$$

The noise voltage is calculated as:

$$V_{rms} = |H_o| \cdot e_n \cdot \sqrt{ENBW}$$
