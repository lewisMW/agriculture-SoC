The comparator is a fundamental building block in our SAR ADC — it makes
the one-bit decision at every step of the binary search. I've been developing
a Verilog-A behavioural model of a voltage comparator, together with a Cadence
Virtuoso testbench to verify its threshold behaviour with DC inputs.

## Role of the Comparator

During each cycle of the SAR conversion, the comparator answers a simple
question: is the sampled input voltage above or below the current DAC
reference? Its output steers the successive approximation logic to set or
clear the corresponding bit. For our system this means the comparator must
reliably resolve voltages around the 1 V reference with minimal offset
and hysteresis.

In the analogue signal chain the comparator sits inside the ADC:

$$
\text{Sensor} \;\rightarrow\; \text{Amp + Filter} \;\rightarrow\; \text{Sample-and-Hold} \;\rightarrow\; \underbrace{\text{Comparator}}_{\text{inside SAR ADC}} \;\rightarrow\; \text{Digital}
$$

## Verilog-A Implementation

The behavioural model takes a differential-style approach with explicit
supply rails. The input voltage is compared against a 1 V reference; when
the input exceeds the reference the output is driven to the `high` rail,
otherwise to the `low` rail.

```verilog
`include "constants.vams"
`include "disciplines.vams"

module comparator_va(in, out, high, low);

    inout in, out, high, low;
    electrical in, out, high, low, gnd;
    ground gnd;

    parameter real Vref = 1; // 1 V reference

    analog begin
        if (V(in) > Vref)
            V(out) <+ V(high); // output high
        else
            V(out) <+ V(low);  // output low
    end

endmodule
```

> The model exposes separate `high` and `low` supply ports rather than
> using fixed voltage levels. This lets the testbench — or a future
> system-level integration — set the output swing to match the logic
> levels required by the downstream SAR register. The internal `ground`
> node provides the absolute reference for the `Vref` comparison.

## Testbench & Results

The testbench (`comparator_tb`) is configured in Cadence ADE Maestro and
applies DC voltages to the comparator input while monitoring the output.
Two key test cases verify the threshold behaviour:

- **5 V DC input (above $V_{\text{ref}}$):** the comparator output follows the
  `high` supply rail, confirming that an above-threshold input is correctly
  detected.

![Simulation result with 5 V DC input — output follows the high rail](https://github.com/user-attachments/assets/65321f4c-ff4a-4ba3-8be1-cc05699d150e)

- **500 mV DC input (below $V_{\text{ref}}$):** the comparator output follows the
  `low` supply rail, confirming correct below-threshold detection.

These DC checks establish that the basic comparison logic is sound before
moving on to more demanding transient and noise-sensitivity tests.

## Current Limitations

This first version of the model operates on DC inputs only — it does not yet
capture dynamic behaviours such as propagation delay, metastability near the
threshold, or input-referred offset voltage. These are important for the full
SAR ADC timing closure and will be added in subsequent revisions.

## Next Steps

The immediate next steps are to extend the model with finite propagation
delay and hysteresis, then integrate it with Hee's SAR ADC model so the
successive approximation loop uses this comparator rather than an idealised
internal comparison. We also plan to characterise the comparator's noise
sensitivity to ensure it does not degrade the 8-bit resolution established
by the system noise budget.
