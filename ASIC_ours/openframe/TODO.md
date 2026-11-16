# To do before tape-out

Open items found while putting nanosoc in the OpenFrame wrapper and checking it
(`README.md` has the background for each). Recorded 17 Nov 2026. Tick an item
when it is settled, or delete it with a line in the commit message saying why.

## Decisions that change the chip

These change the layout, so they come before the final sign-off run.

- [ ] **Program storage.** The instruction memory is RAM, and the simulations
      preload it. On silicon a host has to upload the program over the host
      link after every power-up. Either accept that, or boot from the
      development board's SPI flash: there is no SPI controller, so the boot
      ROM would bit-bang it through port pins. That needs port bits on GPIO
      39-42 (unused in the present pad map) and a loader in the boot ROM, which
      is fixed at tape-out.
- [ ] **Sensing interrupt.** `adc_apb_wrapper_rev2` has no interrupt output and
      `accelerator_subsystem`'s `EXP_IRQ` lines are tied low, so firmware can
      only poll and the processor cannot sleep until a sample arrives. Add a
      "sample ready" interrupt with an enable bit.
- [ ] **ADC supply.** The macro's `vdda` is the frame's `vdda1`. The
      development board brings `vdda1` to a header beside its 3.3 V pins and
      leaves the jumper to the user; the macro's devices are 1.8 V. Either put
      the wiring (to 1.8 V) where nobody can miss it, or move the supply to the
      frame's spare 1.8 V pair `vccd2`/`vssd2`, whose pins are on the far edge.
- [ ] **RTC power-on reset** is tied to the system reset, so the time is lost on
      every reset. The frame supplies a power-on reset (`porb_l`) that could
      feed it.
- [ ] **Reset values of the clock registers.** `rtc_prescale` resets to
      16,666,667 (1 Hz from 33.33 MHz), `adc_clkdiv` to 4, `adc_samplediv` to 0.
      Needs the board's clock frequency, whether it changes at run time, and
      the sensor's source impedance. Try a slower ADC clock and a longer
      sampling phase in the mixed-signal flow before changing the ADC defaults.
- [ ] **A 32.768 kHz input for the RTC tick** (optional; GPIO 39-42 are spare).
      Only worth it if the system clock will change at run time. It can be
      sampled by the system clock and used as the prescaler's count enable,
      which avoids a second clock domain.

## The ADC macro

- [ ] `MR_capm.SP.2` (capacitor spacing) in `sar_afe__bootstrap_sw`: the one
      violation ChipFoundry's FEOL deck still reports, and a hard precheck
      failure.
- [ ] `sar_afe__carray_8b` has a solid met2 plate 76 um across; ChipFoundry's
      guideline for solid metal is 30 um.
- [ ] The reference reaches the macro through an `analog_io` pad, which has a
      150 ohm series resistor; `analog_noesd_io` is the direct path. Decide
      which the reference should use.
- [ ] Open since October: +3 % gain on conversions that follow each other within
      10 us, in the extracted macro only. The sampling phase is a suspect, and
      its length is now a register.

## Checks not yet run

- [ ] **Mixed-signal (AMS) flow** with the clock-register RTL. `sar_ams_shim`
      passes the two new ports through, untested.
- [ ] **IR drop and electromigration.** Not analysed. Estimated power is about
      14 mW at 33 MHz.
- [ ] **Process antennas in the pad-ring flow.** The OpenFrame flow now inserts
      diodes and is clean; the pad-ring flow only writes the report.
- [ ] **Timing to the outside.** The input and output delays in the constraints
      are nominal, and the frame's pad delays are not modelled.
- [ ] **Instruction memory, lower block, write path:** exercised on 32 words
      (the interrupt vectors) in the gate-level simulation with the memories as
      gates; the rest of that block is only read.
- [ ] **The DFFRAM compiler's blocks** (the 10 kbyte builds) have not been
      simulated as gates, and carry unrepaired antenna violations of their own
      (61 to 295 nets a block). Only matters if that option is taken up.
- [ ] **Transistor level** (optional). One 512 byte block (300,000
      transistors) runs 16 clock cycles in Spectre X in about 80 s and reads
      back correctly; scaled to the whole chip that is about a minute a cycle.
      Schematic level only, no wire parasitics.

## Firmware and board

- [ ] `sensing_driver_test` clears the FIFO before the settle delay, so a
      conversion already under way delivers its sample after the clear. Move
      the delay between `sensing_polling_disable()` and `sensing_clear_fifo()`;
      consider doing that wait in the driver.
- [ ] **Linker script for the real memories** (4 kbyte of code, 1 kbyte of
      data). The present one assumes 64 kbyte and 15 kbyte; programs run on the
      1 kbyte data memory only because addresses wrap, which puts the stack at
      its top by accident.
- [ ] **The application's size** against 4 kbyte, built as "Firmware size" in
      the README describes.
- [ ] **Pulls on the board** for every port pin the firmware leaves as an input:
      a bidirectional pad has none. That includes the host-link mode strap,
      P1[7] on GPIO 11.
- [ ] **Check the pad map against the board:** which of GPIO 5 and 6 the FTDI
      transmits on (taken as the chip receiving on 5), and the LED's polarity.
- [ ] **A host adapter** on the header pins for the host link (HOSTIO4 or
      FT1248): the board has none.

## The pad-ring flow (#137)

- [ ] In "use VDDA pad for VDDIO_Q/VSSIO_Q" (e38d4a6), each pad's VDDA pin and
      its quiet-rail pin are on single-pin nets of their own. The strap that is
      planned will short them in the layout, so LVS will not match unless the
      netlist puts them on one net.
- [ ] Decide whether the pad-ring flow is kept, now that the tape-out goes
      through the OpenFrame wrapper.

## Submission

- [ ] Confirm that the processor IP's licence terms cover sending the layout and
      the gate netlist to the foundry.
- [ ] The foundry's export-compliance classification, which is the customer's
      responsibility.
- [ ] ChipFoundry account, `cf init`, and a slot on a shuttle. The submission
      repository has to be private: the GDS and the gate netlist contain the
      synthesised processor.
- [ ] `cf precheck` in ChipFoundry's container on the final layout.
