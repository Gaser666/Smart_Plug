# 🔌 Smart Plug Flutter App

A Flutter mobile application for monitoring electrical appliances using a smart plug connected via Bluetooth. The app reads **real-time voltage and current** values from a hardware module and displays the data in a clean, user-friendly interface.

---

## 📱 Features

- 📶 **Bluetooth Connectivity**: Automatically scans and connects to nearby compatible smart plug modules.
- 🔋 **Live Voltage & Current Monitoring**: Displays real-time electrical readings from the smart plug.
- 📈 **Data Visualization**: Dynamic charts and dashboards to track changes in power usage over time.
- ⚙️ **Device Control Ready**: Future support planned for turning appliances on/off remotely.

---

## 🔧 Tech Stack

- **Flutter** (Dart) — cross-platform mobile framework
- **Bluetooth** — communication using `flutter_blue` or `flutter_reactive_ble`

---

## 🔌 Hardware Requirements

- Smart plug embedded with:
  - A microcontroller (e.g., ESP32/Arduino with HC-05/HC-06 Bluetooth module)
  - Current & voltage sensor (e.g., ACS712, ZMPT101B)
  - Bluetooth communication protocol: UART (serial)

