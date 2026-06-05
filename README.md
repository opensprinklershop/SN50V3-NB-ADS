# Dragino SN50V3-NB ADS1115 MQTT Firmware

Dieses Repository enthält die modifizierte Open-Source-Firmware für das **Dragino SN50V3-NB** NB-IoT Sensor-Modul (MCU: STM32L072, NB-IoT: BC660K-GL).

Die Firmware wurde speziell für das Auslesen von **4 zusätzlichen analogen Messkanälen** über einen externen **ADS1115 16-Bit ADC** angepasst und überträgt alle Sensordaten direkt strukturiert über **MQTT im JSON-Format** (unterstützt durch `AT+PRO=3,5`).

Das Projekt wird auf GitHub unter **[OpenSprinklerShop/SN50V3-NB-ADS](https://github.com/OpenSprinklerShop/SN50V3-NB-ADS)** publiziert.

---

## 1. Features & Modifikationen

*   **ADS1115 Integration (I2C)**: Kontinuierliches Auslesen der 4 hochauflösenden Kanäle des ADS1115.
*   **Vollwertiges MQTT & JSON Payload**: Bei Aktivierung von `AT+CFGMOD=12` und `AT+PRO=3,5` werden die Daten direkt als lesbares JSON-Objekt übertragen.
*   **Integrierte SMT50-Konvertierung**: Die Firmware berechnet die Bodenfeuchtigkeit (% VWC) und die Temperatur (°C) von zwei angeschlossenen Truebner SMT50-Sensoren automatisch mit ressourcenschonender Integer-Arithmetik und liefert diese direkt im JSON-Uplink mit (verhindert Float-Printf Overhead).

---

## 2. Hardware-Anschluss & Verkabelung

Der ADS1115 wird an den internen bzw. externen 11-poligen Anschluss des SN50V3-NB angeschlossen. Der ADS1115 benötigt 5V Betriebsspannung und wird über den geschalteten Pin 2 versorgt. Um Energie zu sparen, schaltet die Firmware den 5V-Pin vor der Messung ein und direkt danach wieder ab.

### Anschlussbelegung (Pinout)

| Klemme (Pin) | Bezeichnung | ADS1115 Pin | Beschreibung |
| :---: | :--- | :---: | :--- |
| **2** | **+5V geschaltet** | **VDD / VCC** | Betriebsspannung ADS1115 |
| **3** | PA4 (ADC1) | - | Freier analoger Eingang 1 (0..3.3V) |
| **4** | **SCL** | **SCL** | I2C Clock (PB6 oder PB8) |
| **5** | **SDA** | **SDA** | I2C Data (PB7 oder PB9) |
| **9** | PA0 (ADC3) | - | Freier analoger Eingang 3 (Klemme beschriftet mit "PA8") |
| **11**| **GND** | **GND & ADDR**| Masse & I2C-Adresse (ADDR auf GND = `0x48`) |

---

## 3. MQTT JSON Payload Struktur (`AT+CFGMOD=12`)

Bei der Übertragung via MQTT (`AT+PRO=3,5`) sendet das Gerät ein JSON-Objekt mit folgendem Aufbau:

```json
{
  "IMEI": "86xxxxxxxxxxxxx",
  "IMSI": "46xxxxxxxxxxxxx",
  "Model": "SN50V3-NB",
  "mod": 12,
  "battery": 3.61,
  "signal": 18,
  "time": "2026/06/05 23:15:00",
  "adc1": 1200,
  "adc3": 2400,
  "ads1115_a0_mv": 1800,
  "ads1115_a1_mv": 900,
  "ads1115_a2_mv": 0,
  "ads1115_a3_mv": 500,
  "smt50_1_moisture_vwc": 30.00,
  "smt50_1_temp_c": 40.0,
  "smt50_2_moisture_vwc": 0.00,
  "smt50_2_temp_c": 0.0
}
```

### JSON-Felderbeschreibung:
*   `battery`: Batteriespannung (V)
*   `adc1` / `adc3`: Interne MCU Analogwerte (mV)
*   `ads1115_a0_mv` bis `_a3_mv`: Gemessene Spannungen am ADS1115 (mV)
*   `smt50_1_moisture_vwc` / `smt50_2_moisture_vwc`: Bodenfeuchtigkeit in % Volumetric Water Content (skaliert: 0..3V entspricht 0..50% VWC)
*   `smt50_1_temp_c` / `smt50_2_temp_c`: Bodentemperatur in °C (skaliert: 0..3V entspricht -40 °C bis +60 °C)

---

## 4. Kompilieren & Flashen

### A. Kompilieren über MSYS2 (Makefile)
1. Öffnen Sie die MSYS2 / MinGW64 Shell.
2. Stellen Sie sicher, dass die arm-none-eabi GCC Toolchain installiert ist.
3. Führen Sie folgende Befehle aus:
   ```bash
   export PATH=/mingw64/bin:/usr/bin:/bin:$PATH
   cd /d/projekte/Dragino-SN50V3-NB
   make
   ```
4. Die flashbare Datei befindet sich anschließend unter `build/NBSN95.bin`.

### B. Firmware flashen (ISP-Modus)
Flashen Sie die Applikations-Firmware immer ab Adresse **`0x08007800`** (nicht `0x08000000`, sonst überschreiben Sie den Bootloader!).

Führen Sie das Flashen über die STM32 Programmer CLI aus:
```bat
STM32_Programmer_CLI.exe -c port=COM3 br=115200 parity=EVEN -d build/NBSN95.bin 0x08007800 -v
```

**Vorgehensweise:**
1. SW1 auf dem Board auf **ISP** stellen.
2. **USB-Kabel trennen** und wieder einstecken (Reset-Button allein reicht nicht).
3. Flashen ausführen.
4. SW1 zurück auf **Normal** schieben.
5. USB-Kabel trennen und wieder anschließen → Das Gerät bootet die neue Firmware.
