# Testbench v1 Documentation @Last Tuesday

<aside>

Verilog-A testbench for filter and amplifier front end. Features implemented:

- Filter and amplifier action 🟢
- Input and output impedance 🟢
- Slew 🟠
    - Slew rate in simulation is consistently an order of magnitude higher than the value set in code
- White noise 🟠
    - The Verilog-A variable implements $temperature as the ‘ambient’ temperature set by the simulation, but it is not clear where this temperature is set in Maestro
    - Noise voltage is currently applied to output current, and does not appear on output voltage.
    - Function otherwise behaves as expected, adding noise to the output current signal.
</aside>

---

A single-pole filter/amplifier is implemented for a bandwidth set by the Nyquist frequency of the SocLabs ADC, and 20dB gain. The gain, cutoff frequency, input impedance, output impedance, thermal noise voltage and slew rate can be edited the Verilog-A script to represent real values in later designs$^1$. 

The only design constraints considered in this version of the amplifier/filter is the sampling rate of the ADC module given by SoCLabs, which is designed to integrate with NanoSoC. Its specifications are shown in Figure 1. For a sampling rate of 100kHz, the maximum signal frequency which can be sampled without distortion is 50kHz. This amplifier is therefore designed as an ideal component with 50kHz cutoff frequency. 

<img width="1758" height="498" alt="image" src="https://github.com/user-attachments/assets/b3723139-7689-486e-bcab-3ff5418bfa00" />

Figure 1: SAR ADC SocLabs specifications at [https://soclabs.org/project/adc-integration-nanosoc](https://soclabs.org/project/adc-integration-nanosoc)


<img width="1494" height="912" alt="image" src="https://github.com/user-attachments/assets/93a5f290-9170-4c04-986f-8e8e2927c229" />

Figure 2: Verilog-A Laplace transform filter function documentation

In Verilog-A the filter/amplifier is implemented using the Laplace transfer function (Figure 2). The Laplace transformer filter function takes in the coefficients of the s-domain polynomials which represent the numerator and denominator of the transfer function$^2$, and returns the filtered and amplified voltage waveform. The transfer function for a single-pole filter with gain $G$ is $H(s) = \frac{N(s)}{D(s)} = \frac{G}{d_1 s^1 + d_0 s^0}$. For a passive single-pole RC filter this can be expressed as $D(s) = \frac{1}{\tau} s + 1$, which can be seen by writing the voltage divider equation for an RC circuit (see [here](https://www.notion.so/SoC-Project-Amplifier-and-Readout-Electronics-2668cdd9a2608058921dd13e7dfde840?pvs=21)). The time constant of an RC filter is constrained by the corner frequency at 50kHz, which implies a time constant $\frac{1}{\tau} = \frac{1}{2 \pi (50e^3)}$ . Thus, the coefficient array representing $D(s)$ for input of the laplace_nd function should be $d = [\frac{1}{\tau}, 1]$. It is noted that this module can conveniently be adjusted by adjusting the denominator polynomial if a higher order filter is preferred in later design stages. 

---

1: Apparently parameters can be instantiated in a way which allows them to be editable from the schematic. I could not get this to work at the time. 

2: I note that this implementation does not include a value for epsilon, the tolerance. I am not sure what the default value is and how it impacts the realism of the testbench to exclude it.  

---

The behaviour of the Laplace transform filter was checked through an AC sweep, with the result shown in Figure 3. The test bench used in this simulation was unrealistic in that the filter/amplifier module defaults to infinite input impedance (zero input current) and zero output impedance, no source resistance was included. For a 1V AC input, 20dB gain is seen in the passband with a cutoff frequency at 15kHz.

<img width="945" height="647" alt="image" src="https://github.com/user-attachments/assets/455cb994-a6dc-4d1e-ac14-dc3a993d58d5" />

Figure 3: AC sweep results with 1V AC input voltage showing rolloff (-3dB gain and $45^\circ$ phase shift) at designed 3dB point and gain $20\text{dB}$ gain in passband.

<img width="598" height="267" alt="image" src="https://github.com/user-attachments/assets/e2288994-ff3e-4508-a4cc-1e0d8077a235" />

Figure 4: Schematic test bench for basic function of amplifier module


## Input Impedance

Input impedance was implemented by defining a finite current at the input node Vin, $I_{in}=\frac{V_{in}}{R}$, which implies non-ideal input resistance. A $1\text{k}\Omega$ input resistance was added as shown in Figure 5. The test bench for checking input resistance is shown in Figure 6 with source voltage $V_{s} = 1V$ and source resistance $R_s = 1k\Omega$, to create a halving voltage divider. The expected voltage at the input to the filter/amplifier module is therefore $500\text{mV}$, with output voltage $5\text{V}$. The current into the module is expected to be $I_{in} = \frac{V_{in}}{R_{in}} = \frac{500mV}{1k\Omega} = 500uA$. The simulation output results were as expected (Figure 8).

<img width="1699" height="499" alt="image" src="https://github.com/user-attachments/assets/0a30d13c-4474-4edf-a778-a55f2083ee40" />

Figure 5: Block and test bench circuit diagram 


<img width="463" height="162" alt="image" src="https://github.com/user-attachments/assets/f389cbee-b2a8-4265-85da-44aa09145849" />

Figure 6: Testbench for input impedance


<img width="1402" height="832" alt="image" src="https://github.com/user-attachments/assets/0224d161-091b-4ff6-b276-ecaa79860a35" />

Figure 8: Simulation results with input impedance added

## Output Resistance

Output resistance was implemented next. To achieve this in Verilog-A, an extra node n_internal was added between the filter and output impedance to make the output impedance in series with the source. Load impedance was added to complete the test bench according to Figure 5. The completed test bench is shown in Figure 9. It is noted that that the source frequency (50kHz  in image) is relevant to transient sweeps performed later, not the AC sweep shown in Figure 11. The expected output voltage is 9.8V with both input and output impedance included for a 1V input. 

<img width="902" height="722" alt="image" src="https://github.com/user-attachments/assets/76667169-8a80-448e-a0ce-e7bc7c05002f" />

Figure 9: completed testbench 


<img width="3024" height="4032" alt="image" src="https://github.com/user-attachments/assets/42764ef5-8872-4964-9fab-ad4b132ca501" />

Figure 10: Calculation for expected output voltage. 


<img width="463" height="644" alt="image" src="https://github.com/user-attachments/assets/38d43ac5-8eb6-47b7-99b2-38ebfc6d300e" />

Figure 11: Based on calculated values of resistance, 9.8V makes sense 

## Slew

The slew rate of the 741 op amp (0.7 V/us) is implemented in code for testing purposes, and this value can be replaced with a realistic one at a later date. The Verilog-A slew rate function (Figure 12) produces an output waveform that is the same as the input waveform except that it has bounded slope. A new node is introduced m_internal to allow for the slew to be added before gain. To check that the slew function works as expected, the slew rate was artificially inflated from 0.7V/us to 0.7 V/s, assuming that the function takes slew rate specified in units of 0.7V/s. The same test bench as in Figure 9 is used, with source is 10Hz input with 1V amplitude. 

<img width="1530" height="826" alt="image" src="https://github.com/user-attachments/assets/8e6b2e99-6ee3-4e0c-b07b-ef57dceee13f" />

Figure 12: Verilog-A slew rate function

<img width="2000" height="1221" alt="image" src="https://github.com/user-attachments/assets/15700da3-a981-40b5-a32f-fb665318655b" />

Figure 13: Diagram of implementation of slew

<img width="902" height="1032" alt="image" src="https://github.com/user-attachments/assets/aef0fe6b-819c-461e-80e8-f17856208e6b" />

Figure 14: Code with artificially inflated inputs to slew function, 0.7 instead of 0.7e-5. 

<img width="1143" height="644" alt="image" src="https://github.com/user-attachments/assets/bad356c4-fd59-48b3-bfc4-cde2bdfb8d82" />

Figure 15: Transient simulation results with expected slew rate 0.7V/s, result instead indicates ~7V/s

The gradient in the transient simulation result is $\frac{331.82\text{mV}}{47.88 \text{mV}} = 6.93 \text{ V/s}$ which is an order of magnitude higher than the rate of 0.7 V/sec set in the code. Similarly, an input of 7 in the slew function gives $\frac{2.99 \text{ V}}{43.10 \text{ mV}} = 69.30 \text{ V/s}$ as shown in Figure 16. This issue is flagged to be resolved in later iterations of the testbench.

<img width="1088" height="847" alt="image" src="https://github.com/user-attachments/assets/21a8d261-3cb1-4de8-8e6c-a00958d15866" />

Figure 16: Transient simulation results with expected slew rate 7V/s, result instead indicates ~70V/s

## Thermal Noise

The white_noise Verilog-A function (Figure 17) is implemented to add white noise to the output signal, equivalent to the thermal noise on $\text{R}_{\text{out}}=10\Omega$. It is noted that the white noise signal is applied directly to the output signal, which is a current, and that the noise is not reflected in the output voltage. This will be rectified in future implementations.

The mean square noise voltage is given by $\overline{V_n^2} = 4k_BTR\Delta f$ (with $k_B = 1.380649×10^{−23} J⋅K^{−1}$, assuming T = 300K, $R = R_{out} = 10\Omega$, and bandwidth $\Delta f = 15\text{kHz}$ in this design the mean squared voltage is expected to be $2.484e^{-15}$. The noise function in Verilog-A takes in power spectral density given by $\overline{V_n^2}/\Delta f = 4k_BTR$. Here, $\text{R}=\text{R}_{\text{out}}=10\Omega$ and it is assumed that $\text{T} = 300\text{K}$, although the variable $temperature in Verilog-A uses the ambient temperature set by simulation. It is not clear what this refers to, and this will be clarified in future iterations.

For the sake of checking the behaviour of the function, the power spectral density is raised to the power of 10, and it is shown in Figure 20 that the function adds noise to the output current signal, as expected.

<img width="1236" height="704" alt="image" src="https://github.com/user-attachments/assets/daaa11cf-d0f7-40ef-919c-8a9ba8aadaae" />

Figure 17: Verilog-A white noise function and inputs

<img width="1436" height="430" alt="image" src="https://github.com/user-attachments/assets/804378cd-b7ba-4a26-9184-3707cdc5d594" />

Figure 18: Documentation snippet showing variable for Boltzmann’s constant 

<img width="902" height="1032" alt="image" src="https://github.com/user-attachments/assets/f62b40c3-bf22-4093-b483-fa8207cc655c" />

Figure 19: White noise added to output current, with an artificially inflated value to check the behaviour of the function

<img width="915" height="701" alt="image" src="https://github.com/user-attachments/assets/d2e35e60-6360-4f21-9abb-a17330eb510f" />

Figure 20: Noise visible on output transient signal 

<img width="412" height="713" alt="image" src="https://github.com/user-attachments/assets/97b462d2-b13c-430a-acd6-02209700008b" />

Figure 21: Settings for transient simulation which allow for noise to be included
