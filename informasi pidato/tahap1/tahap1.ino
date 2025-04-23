#include <WiFi.h>
#include <WiFiManager.h> // Tambahkan library ini
#include <PubSubClient.h>
#include <MD_Parola.h>
#include <MD_MAX72xx.h>
#include <SPI.h>

#define HARDWARE_TYPE MD_MAX72XX::FC16_HW
#define MAX_DEVICES 4
#define DATA_PIN 26
#define CLK_PIN 33
#define CS_PIN 25

const char* mqtt_server = "broker.emqx.io";

WiFiClient espClient;
PubSubClient client(espClient);
MD_Parola matrix = MD_Parola(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

unsigned long startTime = 0;
bool countdownActive = false;
int countdownSeconds = 300;

bool warned2min = false;
bool warned1min = false;
bool ended = false;

void tampilkanScroll(const char* pesan) {
  matrix.displayClear();
  matrix.displayScroll(pesan, PA_LEFT, PA_SCROLL_LEFT, 100);
  while (!matrix.displayAnimate()) {
    // Tunggu sampai animasi selesai
  }
  delay(2000);
}

void callback(char* topic, byte* message, unsigned int length) {
  String msg = "";
  for (int i = 0; i < length; i++) {
    msg += (char)message[i];
  }

  Serial.print("Pesan MQTT diterima: ");
  Serial.println(msg);

  if (msg == "mulai") {
    startTime = millis();
    countdownActive = true;
    warned2min = false;
    warned1min = false;
    ended = false;

    tampilkanScroll("Mulai");
    Serial.println("Countdown dimulai");
  }
}

void setup_wifi() {
  WiFiManager wm;

  // Konfigurasi WiFiManager
  wm.setTimeout(180); // timeout portal dalam 3 menit
  bool res;

  res = wm.autoConnect("N21-Matrix", "12345678"); // Nama dan password hotspot

  if (!res) {
    Serial.println("Gagal terhubung! Reset ESP.");
    ESP.restart();
  } else {
    Serial.println("Berhasil terkoneksi ke WiFi!");
    Serial.println(WiFi.localIP());
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Menghubungkan ke MQTT...");
    String clientId = "ESP32Client-" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("Terhubung!");
      client.subscribe("matrix/text");
    } else {
      Serial.print("Gagal, rc=");
      Serial.print(client.state());
      Serial.println(" coba lagi 5 detik...");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("Memulai setup...");

  matrix.begin();
  matrix.setIntensity(2);
  matrix.displayClear();

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  tampilkanScroll("Siap Digunakan");
  matrix.setTextAlignment(PA_CENTER);
  matrix.print("Siap");
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  if (countdownActive) {
    unsigned long elapsed = (millis() - startTime) / 1000;
    int remaining = countdownSeconds - elapsed;

    if (remaining <= 0 && !ended) {
      countdownActive = false;
      ended = true;

      tampilkanScroll("SELESAI");
      Serial.println("Waktu habis!");

      for (int i = 0; i < 6; i++) {
        matrix.displayClear();
        delay(500);
        matrix.setTextAlignment(PA_CENTER);
        matrix.print("STOP");
        delay(500);
      }

      matrix.displayClear();
      matrix.setTextAlignment(PA_CENTER);
      matrix.print("Siap");
    } 
    else if (remaining <= 60 && !warned1min) {
      warned1min = true;
      tampilkanScroll("Sebentar lagi selesai");
      Serial.println("Peringatan: 1 menit tersisa");
    } 
    else if (remaining <= 120 && !warned2min) {
      warned2min = true;
      tampilkanScroll("Waktunya akan habis");
      Serial.println("Peringatan: 2 menit tersisa");
    } 
    else {
      char buffer[10];
      int menit = remaining / 60;
      int detik = remaining % 60;
      sprintf(buffer, "%02d:%02d", menit, detik);
      matrix.setTextAlignment(PA_CENTER);
      matrix.print(buffer);
    }
  }
}

