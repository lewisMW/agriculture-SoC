# To do before tape-out

Open items found while putting nanosoc in the OpenFrame wrapper and checking it
(`README.md` has the background for each). Recorded 17 Nov 2026, last worked
through 18 Nov. Tick an item when it is settled, or delete it with a line in the
commit message saying why. A ticked item says in one line what settled it.

## Decisions that change the chip

These change the layout, so they come before the final sign-off run.

- [x] **Program storage.** The boot ROM now copies the program from the
      development board's SPI flash, and the flash can be written from the
      board's USB port with the FLASH_PROG strap high (README, "Booting from
      the board's flash"). Port bits P1[8..11] are on GPIO 39-42.
- [x] **Sensing interrupt.** `adc_apb_wrapper_rev2` has `irq_enable` (0x118) and
      an interrupt output on `EXP_IRQ[0]`, the processor's interrupt 11:
      "FIFO holds a sample" and "FIFO full". `sensing_irq_test`.
- [x] **ADC supply.** Stays on the frame's `vdda1`. The wiring (header J11 pin 16
      to 1.8 V, not to the 3.3 V pin beside it) is in the README's pad map.
- [x] **Reset value of the RTC prescaler:** 5,000,000, 1 Hz from the board's
      10 MHz oscillator. The boot ROM's UART2 divider is for 10 MHz too.
- [x] **Reset values of the ADC dividers:** `adc_clkdiv` 4 and `adc_samplediv`
      8, from the mixed-signal runs (README, "Mixed-signal runs with the clock
      registers"): a sampling phase of 480 ns at 33 MHz and 1.6 us at 10 MHz.
      The sensor's source impedance is still to come; firmware can lengthen
      the sampling phase to 51 us at 10 MHz.
- [ ] **RTC power-on reset** is tied to the system reset, so the time is lost on
      every reset, a debugger's or the program's included. A reset that only
      power-on and the reset pad assert would need a port through three levels
      of the SoC Labs hierarchy. Not taken up on 18 Nov.
- [ ] **A 32.768 kHz input for the RTC tick** (optional; GPIO 12, 13 and 22 are
      spare). Only worth it if the system clock will change at run time. It can
      be sampled by the system clock and used as the prescaler's count enable,
      which avoids a second clock domain.

## The ADC macro

- [ ] `MR_capm.SP.2` (capacitor spacing) in `sar_afe__bootstrap_sw`: the one
      violation ChipFoundry's FEOL deck still reports, and a hard precheck
      failure.
- [ ] `sar_afe__carray_8b` has a solid met2 plate 76 um across; ChipFoundry's
      guideline for solid metal is 30 um.
- [ ] **The comparator trim's capacitor is 1.00 fF, not 1.25 fF.** The unit
      `sarcta__C0` is plain metal fingers; every netlist so far, the extracted
      one included, had it as an ideal 1.25 fF. Extracted from the layout it is
      1.00 fF (ratios 8.02 : 3.99 : 2.00 : 1 : 1), so a trim step is 2.8 mV and
      the range 36 mV where the schematic says 4.0 mV and 49 mV. Decide whether
      the schematic value or the layout changes (README, "The comparator
      trim's capacitor").
- [ ] Trim bits 0 and 1 are one unit each, so the 32 trim codes give 17 levels.
      Intended?
- [ ] The reference reaches the macro through an `analog_io` pad, which has a
      150 ohm series resistor; `analog_noesd_io` is the direct path. Decide
      which the reference should use.
- [ ] **+2.2 % gain in the extracted macro**, at every clock and sampling
      setting. The extraction has 0.21 pF of parasitic on each capacitor
      array's top plate, which accounts for it. (The "+3 % on back-to-back
      conversions" open since October was this plus 1.4 % of the previous
      sample carried over by a 240 ns sampling phase; the sampling phase is
      now 480 ns or more by default.)

## Checks not yet run

- [x] **Mixed-signal (AMS) flow with the clock-register RTL**, at 30 ns and at
      the board's 100 ns: the codes are within 1 LSB with the schematic macro
      and 2 LSB with the extracted one at every setting with 400 ns or more of
      sampling.
- [ ] **Mixed-signal flow, the rest:** the team's test suite on the extracted
      macro; corners other than typical; a source with real impedance.
- [x] **IR drop.** Static, Innovus early rail analysis: 4.4 mV on vccd1 and
      4.2 mV on vssd1 at 41.5 mW, twice that with every current doubled, against
      a 90 mV limit; largest wire current 6 % of the technology's DC limit
      (`signoff/run_ir_drop.sh`). Not covered: inside the macros, dynamic drop,
      RMS and peak current limits.
- [ ] **Power.** 41.5 mW at 33.33 MHz, typical: 18 mW of logic and 24 mW of
      memory, whose latch arrays clock a gate per byte every cycle. The memory
      blocks' libraries carry no power data, so the tools report 18 mW. Not
      measured at 10 MHz or with the clock gated.
- [ ] **Process antennas in the pad-ring flow.** The OpenFrame flow inserts
      diodes and is clean; the pad-ring flow only writes the report.
- [ ] **Timing to the outside.** The input and output delays in the constraints
      are nominal. README, "Timing at the pins", has what the layout does.
- [x] **Instruction memory's write path.** The boot ROM writes the whole program
      through it in the gate-level simulations with the memories as gates
      (`FLASH=boot`).
- [ ] **The DFFRAM compiler's blocks** (the 10 kbyte builds) have not been
      simulated as gates, and carry unrepaired antenna violations of their own
      (61 to 295 nets a block). Only matters if that option is taken up.
- [ ] **Transistor level** (optional). One 512 byte block (300,000
      transistors) runs 16 clock cycles in Spectre X in about 80 s and reads
      back correctly; scaled to the whole chip that is about a minute a cycle.
      Schematic level only, no wire parasitics.
- [ ] **On hardware:** nothing here has been. The flash loader and the
      pass-through were simulated against a flash model written for the
      purpose.

## Firmware and board

- [x] `sensing_driver_test` waits for a conversion under way before it clears
      the FIFO.
- [x] **Linker script for the real memories:** `sw/openframe.ld` (4 kbyte and
      1 kbyte, the stack at the top of the data memory).
- [ ] **The application's size** against 4 kbyte. The eleven test programs are
      1.3 to 2.8 kbyte built small, with under 160 bytes of data.
- [ ] **A program that runs with no host connected must not print on the stream
      port** (the SoC Labs `UartPutc`): it waits for ever unless GPIO 8 is low.
      Print on UART2, or fit a pull-down on GPIO 8. The boot ROM gives up after
      a time-out.
- [ ] **Pulls on the board** for every port pin the firmware leaves as an input:
      a bidirectional pad has none. The mode strap (GPIO 11) and the host
      link's "host has data" input (GPIO 0) now have the pad's pull-up.
- [ ] **Check the pad map against the board:** which of GPIO 5 and 6 the FTDI
      transmits on (taken as the chip receiving on 5), the LED's polarity, and
      whether the flash's IO2 and IO3 have pull-ups or the part ignores them
      (the chip drives both high while it reads the flash, and not otherwise;
      a Caravel chip's pass-through does not drive them either).
- [ ] **Writing the flash from the USB port:** find the programming tool that
      suits the board's FTDI wiring, and try it.
- [ ] **A host adapter** on the header pins for the host link (HOSTIO4 or
      FT1248): the board has none. A host that uploads a program while the
      flash holds one must also write 0x50494B53 to 0x30000000, or the boot
      ROM loads the flash's program over it. A debug probe on GPIO 20 and 21
      needs neither.

## The pad-ring flow (#137)

- [ ] In "use VDDA pad for VDDIO_Q/VSSIO_Q" (e38d4a6), each pad's VDDA pin and
      its quiet-rail pin are on single-pin nets of their own. The strap that is
      planned will short them in the layout, so LVS will not match unless the
      netlist puts them on one net.
- [ ] Decide whether the pad-ring flow is kept, now that the tape-out goes
      through the OpenFrame wrapper. It still has the SoC Labs boot ROM (no
      flash loader; UART2 divider for 240 MHz).

## Submission

- [ ] Confirm that the processor IP's licence terms cover sending the layout and
      the gate netlist to the foundry.
- [ ] The foundry's export-compliance classification, which is the customer's
      responsibility.
- [ ] ChipFoundry account, `cf init`, and a slot on a shuttle. The submission
      repository has to be private: the GDS and the gate netlist contain the
      synthesised processor.
- [ ] `cf precheck` in ChipFoundry's container on the final layout.
