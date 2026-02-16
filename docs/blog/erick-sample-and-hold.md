A sample-and-hold circuit is an essential building block in any mixed-signal
system. It captures a snapshot of the continuously varying analogue input at a
precise instant, holding it steady for the duration of an ADC conversion. I've
been developing a Verilog-AMS behavioural model of a sample-and-hold for our
analogue front-end, together with a Cadence Virtuoso testbench to verify its
operation.

## Why Sample-and-Hold?

Our SAR ADC performs a binary search over multiple clock cycles. If the input
voltage drifts during that conversion window, the result will be corrupted —
a problem known as aperture error. A sample-and-hold placed before the ADC
eliminates this by:

- Freezing the input at the sampling instant, so the comparator sees a stable voltage
- Decoupling the sensor signal path from the charge-redistribution DAC inside the SAR
- Allowing the anti-aliasing filter and amplifier to settle before the sample is taken

For our 8-bit, 100 kHz system the hold time must cover at least 8 clock cycles
of the SAR conversion, and the droop must stay well below one LSB (4.69 mV).

## How the Circuit Works

The model uses a trigger-edge sampling approach. On every rising edge of the
`trigger` signal, the instantaneous analogue input voltage is captured into an
internal register. Between trigger events, the held voltage is driven to the
output through a resistive output stage.

Here is the Verilog-AMS implementation:

```verilog
`include "constants.vams"
`include "disciplines.vams"
`timescale 1ns/1ps
module sample_Hold (inSig, trigger, holdSig);
    input inSig, trigger;
    output holdSig;
    electrical inSig, holdSig;
    logic trigger;
    parameter real Rout = 100;
    real vhold;
    analog begin
        @(posedge(trigger))
            vhold = V(inSig);
        I(holdSig) <+ (V(holdSig) - vhold) / Rout;
    end
endmodule
```

> The output is modelled as a voltage source behind a 100 $\Omega$ resistor
> (`Rout`). The expression `I(holdSig) <+ (V(holdSig) - vhold) / Rout`
> implements Ohm's law: current flows to drive the output node towards the
> held voltage `vhold`, with the finite output impedance naturally modelling
> the loading effect on downstream circuitry.

## Mixed-Signal Testbench

The testbench (`sample_Hold_1`) is set up as a mixed-signal AMS simulation in
Cadence ADE Maestro. The configuration binds the sample-and-hold instance to
its Verilog-AMS view while the surrounding passive components (resistors and
voltage sources) are simulated at the Spectre circuit level:

- **R0, R2, R3** — Spectre resistor instances forming the input network
- **V0, V1** — Spectre voltage sources providing the analogue stimulus and trigger
- **I0** — the `sample_Hold` Verilog-AMS behavioural model

Monitored outputs include the held voltage (`/I0/holdSig`), the input network
node (`/net2`), and current through the circuit (`/Current`). Multiple
simulation runs — both Explorer and Interactive — are stored in the Maestro
history for comparison and debugging.

## Integration with the Analogue Signal Chain

The sample-and-hold sits between Jaime's variable-gain amplifier/filter stage
and Hee's SAR ADC in the signal chain:

$$
\text{Sensor} \;\rightarrow\; \text{Amp + Filter} \;\rightarrow\; \textbf{Sample-and-Hold} \;\rightarrow\; \text{SAR ADC} \;\rightarrow\; \text{Digital}
$$

By providing a stable voltage to the ADC input, the sample-and-hold relaxes
the settling-time requirements on the upstream amplifier and ensures the SAR's
binary search operates on a constant value throughout its conversion cycle.

## Next Steps

The next steps are to integrate this sample-and-hold model into the full
analogue signal chain alongside the amplifier, filter, and SAR ADC, and to run
end-to-end transient simulations with realistic sensor waveforms. We also plan
to characterise hold-mode droop and acquisition time to confirm the design
meets the noise and timing budgets for our 8-bit system.
