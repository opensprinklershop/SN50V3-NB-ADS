#ifndef __ADS1115_H__
#define __ADS1115_H__

#include "stm32l0xx_hal.h"
#include "i2c.h"

/* I2C address: ADDR pin = GND → 0x48 */
#define ADS1115_I2C_ADDR   0x48

/*
 * Read a single-ended channel (0–3) of the ADS1115 via I2C.
 * PGA configured for ±4.096 V → 0.125 mV/LSB.
 * Requires MX_I2C1_Init() to be called before and
 * HAL_I2C_MspDeInit() after the measurement block.
 * Returns voltage in mV, or 0 on I2C error / negative result.
 */
uint16_t ADS1115_ReadChannel_mV(uint8_t channel);

#endif /* __ADS1115_H__ */
