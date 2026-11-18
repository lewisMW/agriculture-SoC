# The OpenFrame boot ROM (of_boot.c). Makes of_bootrom.hex, one byte per line,
# the form nanosoc_tech's bootrom target takes as BOOTROM_HEX:
#   make -C nanosoc/nanosoc_tech ASIC=yes NODE=SKY130 BOOTROM_ADDRW=9 \
#        BOOTROM_HEX=<build directory>/of_bootrom.hex bootrom
# (../../Cadence/scripts/run_flow.sh does both). Variables:
#   OF_CLK_HZ      the system clock in Hz, for UART2's 38,400 baud (default 10 MHz)
#   OF_IMEM_BYTES  the largest program the loader accepts (default 4096)
#   OUT            where to build (default: here)
NANOSOC_TECH  ?= $(SOCLABS_NANOSOC_TECH_DIR)
CMSIS          = $(NANOSOC_TECH)/software/cmsis
OUT           ?= .
OF_CLK_HZ     ?= 10000000
OF_IMEM_BYTES ?= 4096
CC      = arm-none-eabi-gcc
CFLAGS  = -mthumb -mcpu=cortex-m0 -Os -ffreestanding -nostdlib -nostartfiles \
          -ffunction-sections -fdata-sections -Wall -Wextra -DCORTEX_M0 \
          -DOF_CLK_HZ=$(OF_CLK_HZ)u -DOF_IMEM_BYTES=$(OF_IMEM_BYTES)u \
          -I $(CMSIS)/Device/ARM/CMSDK_CM0/Include -I $(CMSIS)/CMSIS/Include
LDFLAGS = -Wl,--gc-sections -Wl,-T,of_boot.ld -Wl,-Map,$(OUT)/of_bootrom.map

$(OUT)/of_bootrom.hex: of_boot.c of_boot_start.c of_boot.ld Makefile
	@mkdir -p $(OUT)
	$(CC) $(CFLAGS) of_boot_start.c of_boot.c $(LDFLAGS) -o $(OUT)/of_bootrom.elf
	arm-none-eabi-objdump -d $(OUT)/of_bootrom.elf > $(OUT)/of_bootrom.lst
	arm-none-eabi-objcopy -O binary $(OUT)/of_bootrom.elf $(OUT)/of_bootrom.bin
	od -v -A n -t x1 --width=1 $(OUT)/of_bootrom.bin > $(OUT)/of_bootrom.hex
	@wc -c $(OUT)/of_bootrom.bin

clean:
	rm -f $(OUT)/of_bootrom.elf $(OUT)/of_bootrom.lst $(OUT)/of_bootrom.bin $(OUT)/of_bootrom.hex $(OUT)/of_bootrom.map
