##########################################################################################################################
# Makefile for SN50V3-NB firmware (arm-none-eabi-gcc)
##########################################################################################################################

TARGET = NBSN95
BUILD_DIR = build

# Toolchain
PREFIX = C:/msys64/mingw64/bin/arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

# MCU flags
MCU = -mcpu=cortex-m0plus -mthumb

# Compile Flags
CFLAGS = $(MCU) -Wall -fdata-sections -ffunction-sections
CFLAGS += -DUSE_HAL_DRIVER -DSTM32L072xx -DUSE_STM32L0XX_NUCLEO -DSHT3x
CFLAGS += -Os

# Include paths
CFLAGS += -IInc
CFLAGS += -IDrivers/STM32L0xx_HAL_Driver/Inc
CFLAGS += -IDrivers/STM32L0xx_HAL_Driver/Inc/Legacy
CFLAGS += -IDrivers/CMSIS/Device/ST/STM32L0xx/Include
CFLAGS += -IDrivers/CMSIS/Include
CFLAGS += -IDrivers/BSP/inc

# Linker flags
LDFLAGS = $(MCU) -specs=nano.specs -specs=nosys.specs -TSTM32L072CZYx_FLASH.ld
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref

# C Sources
C_SOURCES = \
Src/adc.c \
Src/dma.c \
Src/gpio.c \
Src/i2c.c \
Src/iwdg.c \
Src/main.c \
Src/rtc.c \
Src/stm32l0xx_hal_msp.c \
Src/stm32l0xx_it.c \
Src/system_stm32l0xx.c \
Src/usart.c \
Src/hw_rtc.c \
Src/low_power_manager.c \
Src/queue.c \
Src/stm32l0xx_nucleo.c \
Src/timeServer.c \
Src/tiny_sscanf.c \
Src/trace.c \
Src/utilities.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_adc_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_adc.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_cortex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_dma.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_exti.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_flash_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_flash_ramfunc.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_flash.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_gpio.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_i2c_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_i2c.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_iwdg.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_pwr_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_pwr.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_rcc_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_rcc.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_rtc_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_rtc.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_tim_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_tim.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_uart_ex.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal_uart.c \
Drivers/STM32L0xx_HAL_Driver/Src/stm32l0xx_hal.c \
Drivers/BSP/src/at.c \
Drivers/BSP/src/battery_read.c \
Drivers/BSP/src/common.c \
Drivers/BSP/src/ds18b20.c \
Drivers/BSP/src/flash_eraseprogram.c \
Drivers/BSP/src/lidar.c \
Drivers/BSP/src/lowpower.c \
Drivers/BSP/src/maxsonar.c \
Drivers/BSP/src/nb_coap.c \
Drivers/BSP/src/nb_mqtt.c \
Drivers/BSP/src/nb_payload.c \
Drivers/BSP/src/nb_tcp.c \
Drivers/BSP/src/nb_udp.c \
Drivers/BSP/src/nbInit.c \
Drivers/BSP/src/ne117.c \
Drivers/BSP/src/sht20.c \
Drivers/BSP/src/sht31.c \
Drivers/BSP/src/time_server.c \
Drivers/BSP/src/ult.c \
Drivers/BSP/src/ultrasound.c \
Drivers/BSP/src/weight.c \
Drivers/BSP/src/ads1115.c

# Assembly sources
ASM_SOURCES = \
Drivers/CMSIS/Device/ST/STM32L0xx/Source/Templates/gcc/startup_stm32l072xx.s

# Object files
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

clean:
	rmdir /s /q $(BUILD_DIR)

.PHONY: all clean



