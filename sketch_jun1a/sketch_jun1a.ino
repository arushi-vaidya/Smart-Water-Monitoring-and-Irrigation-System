#include <WiFi.h> 
#include <HTTPClient.h> 
#include <LiquidCrystal_I2C.h> 
#include "DHT.h" 
 
const int pumpPin = 26; // GPIO pin to control relay module for pump 
bool isTankLow = false; // Track if tank is low 
bool pumpRunning = false; // Track pump state
unsigned long pumpStartTime = 0; // Track when pump started
const unsigned long PUMP_DURATION = 5000; // 5 seconds pump duration
 
// LCD at I2C address 0x27 
LiquidCrystal_I2C lcd(0x27, 16, 2);  
 
// DHT setup 
#define DHTPIN 33          
#define DHTTYPE DHT11      
DHT dht(DHTPIN, DHTTYPE); 
 
// Wi-Fi credentials 
const char* ssid = "OnePlus 12R"; 
const char* password = "JojoToyo"; 
 
// ThingSpeak 
const char* serverName = "http://api.thingspeak.com/update"; 
String apiKey = "1M9ICIK0E5PGX051"; 
 
// Sensor pins 
const int trigPin = 5; 
const int echoPin = 18; 
const int buzzer = 13; 
const int soilPin = 34; // analog pin 
 
// Constants 
#define SOUND_SPEED 0.034  // cm/us 
#define CM_TO_INCH 0.393701 
 
// Variables 
float temperature, humidity, distanceCm; 
int moisture, waterLevel; 
int sendCounter = 0; 
 
void setup() { 
  Serial.begin(115200); 
  pinMode(pumpPin, OUTPUT); 
  digitalWrite(pumpPin, HIGH); // Ensure pump is OFF initially (HIGH = OFF for active LOW relay)
 
  // Initialize LCD 
  lcd.init(); 
  lcd.backlight(); 
  lcd.clear(); 
  lcd.print("IoT Water Level"); 
  lcd.setCursor(0, 1); 
  lcd.print("Monitoring..."); 
  delay(2000); 
 
  // Initialize sensors 
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT); 
  pinMode(buzzer, OUTPUT); 
  dht.begin(); 
 
  // Connect to Wi-Fi 
  WiFi.begin(ssid, password); 
  Serial.print("Connecting to WiFi"); 
  while (WiFi.status() != WL_CONNECTED) { 
    delay(500); 
    Serial.print("."); 
  } 
  Serial.println("\nConnected to WiFi!"); 
  Serial.print("IP: "); 
  Serial.println(WiFi.localIP()); 
 
  // Initial alert 
  alarm(3); 
} 
 
void loop() { 
  readUltrasonic(); 
  readDHT(); 
  readSoil(); 
  controlPump(); 
 
  sendCounter++; 
  if (sendCounter >= 3) { 
    sendCounter = 0; 
    sendToThingSpeak(); 
  } 
  
  delay(1000); // Add small delay to prevent overwhelming the loop
} 
 
// =================== FUNCTIONS ==================== 
 
void readDHT() { 
  temperature = dht.readTemperature(); 
  humidity = dht.readHumidity(); 
 
  if (isnan(temperature) || isnan(humidity)) { 
    Serial.println("Failed to read from DHT sensor!"); 
    return; 
  } 
 
  Serial.printf("Humidity: %.1f%%, Temperature: %.1f°C\n", humidity, temperature + 23); 
 
  // Only update LCD if pump is not running to avoid conflicts
  if (!pumpRunning) {
    lcd.clear(); 
    lcd.print("Humidity: "); 
    lcd.print(humidity, 1); 
    lcd.setCursor(0, 1); 
    lcd.print("Temp: "); 
    lcd.print(temperature + 23, 1); 
    lcd.print(" C"); 
    delay(2000); 
  }
} 
 
void controlPump() { 
  int actualMoisture = moisture * 2; // Calculate actual moisture percentage
  
  Serial.printf("DEBUG: Moisture = %d%%, Tank Low = %s, Pump Running = %s\n", 
                actualMoisture, isTankLow ? "YES" : "NO", pumpRunning ? "YES" : "NO");
  
  // Check if pump should start - soil is dry (moisture < 25%) and tank has water
  if (!pumpRunning && !isTankLow && actualMoisture < 25) {
    // Start the pump
    digitalWrite(pumpPin, LOW);  // Turn pump ON (active LOW)
    pumpRunning = true;
    pumpStartTime = millis();
    Serial.printf("Pump STARTED - Soil moisture: %d%% (dry)\n", actualMoisture);
    lcd.clear();
    lcd.print("Pumping Water...");
    lcd.setCursor(0, 1);
    lcd.printf("Moisture: %d%%", actualMoisture);
  }
  
  // Check if pump should stop due to sufficient moisture
  if (pumpRunning && actualMoisture >= 30) { // Stop when moisture reaches 30%
    digitalWrite(pumpPin, HIGH); // Turn pump OFF
    pumpRunning = false;
    Serial.printf("Pump STOPPED - Soil moisture sufficient: %d%%\n", actualMoisture);
    lcd.clear();
    lcd.print("Pump Stopped");
    lcd.setCursor(0, 1);
    lcd.print("Soil Watered");
    delay(2000);
  }
  
  // Check if pump should stop (time-based)
  if (pumpRunning && (millis() - pumpStartTime >= PUMP_DURATION)) {
    // Stop the pump
    digitalWrite(pumpPin, HIGH); // Turn pump OFF (active LOW logic)
    pumpRunning = false;
    Serial.println("Pump STOPPED - Timer expired");
    lcd.clear();
    lcd.print("Pump Stopped");
    lcd.setCursor(0, 1);
    lcd.print("Watering Done");
    delay(2000);
  }
  
  // Emergency stop if tank becomes low while pumping
  if (pumpRunning && isTankLow) {
    digitalWrite(pumpPin, HIGH); // Turn pump OFF
    pumpRunning = false;
    Serial.println("Pump STOPPED - Tank is low!");
    lcd.clear();
    lcd.print("Pump Stopped");
    lcd.setCursor(0, 1);
    lcd.print("Tank Low!");
    delay(2000);
  }
  
  // Display pump status
  if (pumpRunning) {
    unsigned long remainingTime = (PUMP_DURATION - (millis() - pumpStartTime)) / 1000;
    Serial.printf("Pump running... %lu seconds left\n", remainingTime);
  }
}

void readUltrasonic() { 
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2); 
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10); 
  digitalWrite(trigPin, LOW); 
 
  long duration = pulseIn(echoPin, HIGH); 
  distanceCm = duration * SOUND_SPEED / 2; 
 
  Serial.printf("Water Distance: %.2f cm\n", distanceCm); 
 
  // Update tank status based on distance
  if (distanceCm <= 1) { 
    waterLevel = 90; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 90%"); 
    }
  } else if (distanceCm <= 2) { 
    waterLevel = 80; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 80%"); 
    }
  } else if (distanceCm <= 3) { 
    waterLevel = 70; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 70%"); 
    }
  } else if (distanceCm <= 4) { 
    waterLevel = 60; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 60%"); 
    }
  } else if (distanceCm <= 5) { 
    waterLevel = 50; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 50%"); 
    }
  } else if (distanceCm <= 6) { 
    waterLevel = 40; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 40%"); 
    }
  } else if (distanceCm <= 7) { 
    waterLevel = 30; 
    isTankLow = false;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 30%"); 
    }
  } else if (distanceCm <= 8) { 
    waterLevel = 20; 
    isTankLow = true; // Set tank low at 20%
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 20% LOW"); 
    }
    alarm(2); 
  } else if (distanceCm <= 9) { 
    waterLevel = 10; 
    isTankLow = true;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: 10% LOW"); 
    }
    alarm(2); 
  } else if (distanceCm <= 10) { 
    waterLevel = 0; 
    isTankLow = true;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: EMPTY"); 
    }
    alarm(3); 
  } else { 
    waterLevel = 0; 
    isTankLow = true;
    if (!pumpRunning) {
      lcd.clear(); 
      lcd.print("Water: EMPTY"); 
    }
    alarm(3); 
  } 
 
  if (!pumpRunning) {
    delay(2000); 
  }
} 
 
void readSoil() { 
  int rawValue = analogRead(soilPin); 
  // Adjust calibration based on your sensor 
  moisture = 100 - ((rawValue / 4095.0) * 100); 
 
  Serial.printf("Soil Moisture: %d%% (Raw: %d)\n", moisture, rawValue); 
 
  if (!pumpRunning) {
    lcd.clear(); 
    lcd.print("Moisture: "); 
    lcd.print(moisture * 2); 
    lcd.print("%"); 
    delay(2000); 
  }
} 
 
void sendToThingSpeak() { 
  if (WiFi.status() == WL_CONNECTED) { 
    WiFiClient client; 
    HTTPClient http; 
 
    String postData = "api_key=" + apiKey; 
    postData += "&field1=" + String(waterLevel); 
    postData += "&field2=" + String(temperature); // Adjusted temperature
    postData += "&field3=" + String(humidity); 
    postData += "&field4=" + String(moisture); // Adjusted moisture
 
    http.begin(client, serverName); 
    http.addHeader("Content-Type", "application/x-www-form-urlencoded"); 
 
    int httpResponseCode = http.POST(postData); 
    Serial.print("HTTP Response Code: "); 
    Serial.println(httpResponseCode); 
    http.end(); 
  } else { 
    Serial.println("WiFi disconnected!"); 
  } 
} 
 
void alarm(int times) { 
  for (int i = 0; i < times; i++) { 
    digitalWrite(buzzer, HIGH); 
    delay(200); // Shorter delay to avoid blocking
    digitalWrite(buzzer, LOW); 
    delay(200); 
  } 
}