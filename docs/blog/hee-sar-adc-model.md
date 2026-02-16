The analogue-to-digital converter is the critical bridge between the real-world
sensor signals and the digital processing on our Cortex-M0. I've been developing
a behavioural model of an 8-bit Successive Approximation Register (SAR) ADC in
Verilog-AMS, along with a Cadence Virtuoso testbench to verify its operation.

## Why a SAR ADC?

For our precision agriculture application, we need an ADC that balances
resolution, power consumption, and conversion speed. A SAR architecture is well
suited because:

- Low power — only one comparator, no continuous-time circuits
- Moderate speed — 100 kHz sample rate is achievable at 8-bit resolution
- Compact area — important for a multi-sensor SoC
- 8-bit resolution gives adequate precision for soil moisture and temperature readings

## How the SAR Algorithm Works

The SAR ADC performs a binary search on the input voltage. Starting from the MSB,
it sets each bit to 1, compares the resulting DAC voltage against the sampled input,
and keeps or clears the bit. After N clock cycles (one per bit), the conversion
is complete.

The core conversion loop in the Verilog-AMS model:

```verilog
always @(posedge clk or negedge resetn) begin
    if(~resetn) begin
        i <= BITS-1;
        buffer <= 1 << (BITS-1);  // Start with MSB = 1
        DATA <= {BITS{1'b0}};
        data_valid <= 1'b0;
    end else begin
        data_valid <= 1'b0;

        if(i==0) begin
            // Final bit comparison, output result
            if (sample > cmp)
                DATA <= {buffer[BITS-1:1], 1'b1};
            else
                DATA <= {buffer[BITS-1:1], 1'b0};
            data_valid <= 1'b1;

            // Reset for next conversion
            buffer <= 1 << (BITS-1);
            i <= BITS-1;
        end else begin
            // Sample on first cycle, then binary search
            if (i == BITS-1)
                sample <= V(EXTIN);  // Analogue input read

            if (sample > cmp) buffer[i] <= 1'b1;
            else buffer[i] <= 1'b0;

            buffer[i-1] <= 1'b1;  // Try next bit
            i <= i-1;
        end
    end
end
```

> The model uses the `electrical` discipline for the analogue input
> `EXTIN`, allowing it to accept continuous voltage signals from
> upstream analogue blocks. The comparator reference is computed as
> $V_{\text{REF}} \times \text{buffer} / 2^{\text{BITS}}$, performing the DAC function
> implicitly. Input clamping to the [0, VREF] range is included for robustness.

## Noise Budget & SNR Analysis

Before building the model, I derived the noise requirements that the full
analogue chain must meet. For an ideal 8-bit ADC with $V_{\text{REF}}$ = 1.2 V:

$$
\begin{aligned}
SNR_{\text{ideal}} &= 6.02N + 1.76 \\
&= 6.02(8) + 1.76 \\
&= 49.9 \text{ dB}
\end{aligned}
$$

The quantisation noise floor sets the baseline. The LSB is
$V_{\text{REF}} / 2^8$ = 4.69 mV, giving a quantisation noise RMS
of $\text{LSB} / \sqrt{12}$ = 1.35 mV.

Allowing a 3 dB SNR degradation from non-quantisation sources (amplifier noise,
resistor thermal noise, interference), the maximum permitted non-quantisation
noise is:

$$
\begin{aligned}
V_{\text{nonq}} &= V_q \times \sqrt{10^{\Delta/10} - 1} \\
&= 1.35 \text{ mV} \times \sqrt{10^{0.3} - 1} \\
&= 1.35 \text{ mV}
\end{aligned}
$$

This 1.35 mV budget is what Jaime's amplifier and filter stage must stay
within — the thermal noise modelled in the `var_amp_va`
component feeds directly into this analysis.

## Equivalent Noise Bandwidth

For the anti-aliasing filter (a first-order low-pass with $f_c$ = 40 kHz),
the equivalent noise bandwidth is:

$$
\begin{aligned}
\text{ENBW} &= 1.571 \times f_c \\
&= 1.571 \times 40 \text{ kHz} \\
&= 62.8 \text{ kHz}
\end{aligned}
$$

This is used to compute the total integrated noise from any broadband noise
sources in the signal chain, ensuring the 3 dB SNR loss target is met.

## Testbench Setup

The testbench (`ADC_tb`) instantiates the SAR ADC with a 200 kHz clock
and applies a constant 0.6 V DC input (mid-scale) as a sanity check. It includes:

- Active-low reset held for 20 μs before release
- A constant analogue stimulus via `V(EXTIN) <+ 0.6`
- Monitoring of the `data_valid` strobe and 8-bit output

A separate digital stimulus module (`dig_sti_tb`) provides an 800 kHz
clock for 8-bit conversion at 100 kHz effective sample rate, with a properly
sequenced reset.

Simulation is orchestrated through Cadence ADE Maestro, with results stored
in the project's simulation history for team review.

## Cadence Setup Documentation

As part of this work, I also contributed to a Cadence setup manual documenting
the workflow for setting up Virtuoso projects, running ADE Maestro simulations,
and managing Verilog-AMS models. This guide helps onboard team members who are
new to the Cadence environment.

## Next Steps

The immediate next steps are to connect this ADC model with Jaime's amplifier
and filter library to form the complete analogue signal chain, and to run
end-to-end simulations with realistic sensor waveforms rather than DC inputs.
We also plan to add DNL/INL characterisation to the testbench to verify
linearity.
