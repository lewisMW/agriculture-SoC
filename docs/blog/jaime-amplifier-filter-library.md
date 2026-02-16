As part of our analogue front-end development, I've been working on creating
reusable Verilog-A behavioural models for the signal conditioning stage that sits
between our soil sensors and the ADC. The goal is to have a library of components
that can be composed, simulated, and eventually replaced with transistor-level
implementations as we move towards tape-out.

## Why Verilog-A Behavioural Models?

At this stage in the project, we need to verify the overall analogue signal chain
behaviour without getting bogged down in transistor-level design. Verilog-A models
let us capture the key analogue properties — gain, bandwidth, slew rate,
noise — and co-simulate them with the digital RTL in the NanoSoC environment.
Once the system-level behaviour is validated, we can swap in transistor-level
schematics one block at a time.

## Variable-Gain Amplifier with Low-Pass Filter

The main component in the library is a variable-gain amplifier (`var_amp_va`)
that also integrates first-order low-pass filtering. This block models the analogue
conditioning needed before the ADC — amplifying weak sensor signals while
rejecting high-frequency noise above the Nyquist frequency.

Key parameters of the model:

- **Gain:** configurable (default 10x), set to 1 to use as a pure filter
- **3 dB bandwidth:** 50 kHz (Nyquist-matched for our 100 kHz sampling rate)
- **Input impedance:** 1 kΩ (finite, modelling real amplifier behaviour)
- **Output impedance:** 10 Ω with thermal noise contribution
- **Slew rate:** ±70 kV/s (modelling amplifier output rate limiting)

Here's the core of the Verilog-A implementation:

```verilog
// Calculate time constant from 3 dB cutoff frequency
tau = 1/(2*`M_PI*f3db);

// Build Laplace transfer function arrays
num[0] = gain;     // numerator: [gain]
den[0] = 1.0;     // denominator: [1, tau]
den[1] = tau;

// Slew rate limiting on input
V(m_internal) <+ slew(V(in), 0.7e5, -0.7e5);

// Amplifier + filter via Laplace transform
V(n_internal) <+ laplace_nd(V(m_internal), num, den);

// Output impedance with thermal noise
I(n_internal, out) <+ V(n_internal, out)/Rout
    + white_noise(4*`P_K*$temperature*Rout, "thermal");
```

> The `laplace_nd` function applies a continuous-time transfer function
> (gain / (1 + s·τ)), giving us a proper first-order low-pass response.
> Combined with the `slew()` function for rate limiting and
> `white_noise()` for thermal noise, this captures the key non-ideal
> behaviours we need to validate at the system level.

## Reusable Resistor Primitive

I also added a simple resistor Verilog-A primitive (`resistor_va`) to the library.
While basic, having a parameterised Verilog-A resistor is useful for building
more complex analogue networks in the testbench without depending on a specific PDK:

```verilog
module resistor_va(p, n);
  inout p, n;
  electrical p, n;
  parameter real R = 1k from (0:inf);

  analog begin
    I(p, n) <+ V(p, n) / R;  // Ohm's law
  end
endmodule
```

## Verification with Cadence Maestro

Both components have testbenches set up in Cadence Virtuoso with ADE Maestro
for simulation orchestration. The `var_amp_tb` testbench verifies:

- Gain accuracy across the passband
- 3 dB roll-off at the specified cutoff frequency
- Slew rate limiting behaviour on fast transients
- Noise floor contribution from the output stage

The `resistor_tb` testbench validates basic I-V characteristics.
Both testbenches include Maestro simulation history for reproducibility.

## Next Steps

This library is part of the broader Behavioural Modelling milestone. The next
steps are to integrate these blocks with Hee's SAR ADC model to form a complete
analogue signal chain, and to co-simulate the full path from sensor input
through to digital readout on the NanoSoC processor.
