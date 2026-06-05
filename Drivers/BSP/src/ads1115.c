#include "ads1115.h"

/* ADS1115 register pointers */
#define ADS1115_REG_CONVERT  0x00
#define ADS1115_REG_CONFIG   0x01

/*
 * Config register layout (16-bit):
 *  Bit 15    : OS    = 1  (start single conversion)
 *  Bits 14-12: MUX   = 4+channel  (single-ended AINx vs GND)
 *  Bits 11-9 : PGA   = 001 (±4.096 V)
 *  Bit  8    : MODE  = 1  (single-shot)
 *  Bits  7-5 : DR    = 100 (128 SPS → ~8 ms)
 *  Bits  4-0 : comparator disabled = 0x03
 *
 *  MSB = 0xC3 | (channel << 4)
 *  LSB = 0x83
 */
uint16_t ADS1115_ReadChannel_mV(uint8_t channel)
{
    if (channel > 3) return 0;

    uint8_t dev_addr = ADS1115_I2C_ADDR << 1;

    /* Build and write config to start conversion */
    uint8_t cfg[2];
    cfg[0] = (uint8_t)(0xC3u | (channel << 4));  /* OS + MUX + PGA001 + SINGLE */
    cfg[1] = 0x83u;                               /* 128 SPS + comparator off   */

    if (HAL_I2C_Mem_Write(&hi2c1, dev_addr, ADS1115_REG_CONFIG,
                          I2C_MEMADD_SIZE_8BIT, cfg, 2, 100) != HAL_OK)
        return 0;

    /* Wait for conversion (128 SPS ≈ 8 ms, use 12 ms to be safe) */
    HAL_Delay(12);

    /* Read conversion register (2 bytes, big-endian signed) */
    uint8_t raw[2] = {0, 0};
    if (HAL_I2C_Mem_Read(&hi2c1, dev_addr, ADS1115_REG_CONVERT,
                         I2C_MEMADD_SIZE_8BIT, raw, 2, 100) != HAL_OK)
        return 0;

    int16_t value = (int16_t)((uint16_t)(raw[0] << 8) | raw[1]);
    if (value < 0) return 0;

    /* 1 LSB = 4096/32768 mV = 0.125 mV → multiply by 125, divide by 1000 */
    return (uint16_t)((int32_t)value * 125 / 1000);
}
