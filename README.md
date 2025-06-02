# 💧 Smart Water Monitoring and Irrigation System

A complete IoT solution for monitoring water levels and soil conditions in real-time. This system combines an Arduino-based setup for sensor data collection with a modern Flutter app that provides a live dashboard, alerts, and data visualization.

---

## 🔧 Components & Technologies

### 🖥️ Flutter App
- Monitors and displays:
  - Water Level
  - Temperature
  - Humidity
  - Soil Moisture
- Animated UI with monitoring cards
- Emergency alert button to send emails
- Live chart screen with ThingSpeak integration

### ⚙️ Arduino (ESP32) Setup
- Microcontroller: ESP32
- Sensors Used:
  - Ultrasonic sensor (for water level)
  - DHT11 (for temperature and humidity)
  - Soil moisture sensor
- Sends sensor data to ThingSpeak every 15 seconds

---

## 📁 Project Structure

- `lib/main.dart`: Entry point of the Flutter app
- `lib/screens/home_screen.dart`: Main dashboard UI
- `lib/widgets/`: Custom UI components (e.g., monitoring cards, header)
- `lib/services/email_service.dart`: Email alert handling
- `sketch_jun1a/sketch_jun1a.ino`: ESP32 code for reading sensors and sending data

---

## 📲 App Features

- Animated cards show sensor readings in real-time
- Tap any card to view a historical chart of that parameter
- Emergency alert button triggers a pre-written email
- Responsive, clean UI designed for mobile devices
- Real-time values fetched from ThingSpeak

---

## Hardware FUnctionaliy

1. When tank level is 0, the buzzer is sounded.
2. If Soil Moisture reading is less than 25% and tank has water, the pump starts and irrigates the soil.

---

## 🌐 How It Works

1. **Sensors** collect environmental data using ESP32.
2. ESP32 connects to Wi-Fi and pushes the data to ThingSpeak.
3. The Flutter app fetches live data from ThingSpeak’s API.
4. Users can view sensor readings, detailed charts, and send emergency alerts.

---

## 📦 Requirements

### Hardware
- ESP32 microcontroller
- Ultrasonic sensor (HC-SR04)
- DHT11 sensor
- Soil moisture sensor
- Breadboard, jumper wires, power supply

### Software
- Arduino IDE
- Flutter SDK (3.x or later)
- ThingSpeak account (free)
- SMTP-compatible email credentials (for alerts)

---

## 🚀 Getting Started

### Arduino
1. Open the `.ino` file in Arduino IDE.
2. Enter your Wi-Fi credentials and ThingSpeak API key.
3. Upload to ESP32 and monitor serial output.

### Flutter App
1. Run `flutter pub get`
2. Replace email and ThingSpeak credentials in the code.
3. Launch the app on an emulator or device using `flutter run`.

---

## 🛡️ Alert System

The app includes an **Emergency Alert** button. Tapping it will:
- Automatically open the device’s default email client.
- Populate it with a predefined message and recipient (configurable).
- Notify the admin to check the water system immediately.

---
