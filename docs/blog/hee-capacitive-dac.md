With the behavioural SAR ADC model validated, the next step is to break it
apart into structural sub-blocks that can eventually be replaced with
transistor-level circuits. I've been building an 8-bit binary-weighted
capacitive DAC — the charge-redistribution core of the SAR ADC — along with
the supporting analogue primitives it needs, all inside a new `SoC_AFE`
library in Cadence Virtuoso.

## Why a Capacitive DAC?

In a charge-redistribution SAR ADC, the DAC is a binary-weighted capacitor
array. During the sample phase, all capacitor top plates are precharged to a
common-mode voltage. Then, during conversion, the SAR logic toggles the
bottom plates between supply rails one bit at a time, redistributing charge
on the floating top plate. The resulting voltage shift is what the comparator
reads to make each bit decision.

This architecture is attractive for our application because:

- Capacitors are well-matched in CMOS processes, giving good INL/DNL
- No static power — charge redistribution is inherently low-energy
- The same array serves as both the DAC and the sampling element
- Scales naturally with resolution (8 bits = 256 unit capacitors)

## Capacitor Array Implementation

The `cap_array_8b_cp` module implements the full differential array. Each bit
$k$ has a capacitor of weight $2^k \times C_{\text{unit}}$, plus a dummy
capacitor of weight $1 \times C_{\text{unit}}$ to bring the total to
$256 \times C_{\text{unit}}$. An inverter sits between each SAR control line
and the corresponding bottom plate, so that the logic levels are
rail-to-rail.

The core of the charge redistribution:

```verilog
genvar k;

analog begin
    // Dummy capacitors (1 * C)
    I(voutp, np_dummy) <+ ddt(V(voutp, np_dummy)) * (1*C);
    I(voutn, nn_dummy) <+ ddt(V(voutn, nn_dummy)) * (1*C);

    // Binary-weighted array
    for (k=0; k<8; k=k+1) begin
        I(voutp, np[k]) <+ (C*(1<<k)) * ddt(V(voutp, np[k]));
        I(voutn, nn[k]) <+ (C*(1<<k)) * ddt(V(voutn, nn[k]));
    end
end
```

> The `ddt()` operator computes the time derivative of the voltage across
> each capacitor, implementing $I = C \cdot dV/dt$. The binary weighting
> `(1<<k)` doubles the capacitance for each successive bit. A differential
> structure (`voutp`/`voutn`) is used to reject common-mode noise and
> improve linearity — important for meeting the 8-bit noise budget.

## Supporting Primitives

To keep the array model self-contained, I also built two reusable Verilog-A
primitives:

**Ideal switch (`ideal_sw`)** — a voltage-controlled resistor that toggles
between 1 $\Omega$ (on) and 1 T$\Omega$ (off). This models the precharge
switches that connect the top plates to the common-mode voltage before
conversion begins:

```verilog
analog begin
    if (V(ctrl) > vth)
        I(p,n) <+ V(p,n) / ron;   // 1 ohm
    else
        I(p,n) <+ V(p,n) / roff;  // 1 T-ohm
end
```

**Inverter (`inverter`)** — drives the capacitor bottom plates rail-to-rail
from the SAR control signals, with a 10 ns transition time to model realistic
switching.

## Self-Checking Testbench

The `cap_array_8b_tb` testbench goes beyond simple stimulus — it includes a
built-in self-checker that computes the expected top-plate voltage
analytically and compares it against the simulation result at each code step.

The test sequence:

1. Precharge both top plates to $V_{\text{CM}}$ = 0.6 V via the ideal switches
2. Open the switches to float the top plates
3. Step through a series of differential code pairs (`00/FF`, `01/FE`,
   `80/7F`, `55/AA`, `A5/5A`)
4. At each transition, compute the expected voltage shift from the charge
   redistribution equation and check within 1 mV tolerance

This automated checking catches wiring errors and weighting mistakes
immediately, without needing to inspect waveforms manually.

## What's Next: the SAR FSM

The commit message says it plainly — "dac block, fsm not yet." The
`sarlogic` module is currently a placeholder. The next step is to implement
the SAR finite state machine that sequences through the 8-bit conversion:
sampling, then toggling each bit from MSB to LSB while reading back the
comparator output. Once the FSM is in place, the full structural SAR ADC
(capacitive DAC + comparator + FSM) can be assembled and verified against
the existing behavioural model.
