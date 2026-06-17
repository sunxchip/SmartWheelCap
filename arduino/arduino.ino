#include <NimBLEDevice.h>

const int TRIG_PIN = 7;
const int ECHO_PIN = 10;

static NimBLEUUID SVC_UUID("12345678-1234-1234-1234-1234567890ab");
static NimBLEUUID INT_UUID("12345678-1234-1234-1234-1234567890ac");

NimBLECharacteristic* intChr;
uint8_t lastIntensity = 0xFF;

// 차량 센서 모드 최대 거리 (150cm)
const float MAX_ALERT_DIST = 150.0f;  

float readDistanceCm() {
  //신호 누락 방지
  yield(); 

  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  //  타임아웃을 60000us(60ms)로 대폭 상향
  // 블루투스 지연이 발생해도 50cm 이상의 반사파를 놓치지 않고 끝까지 기다림
  unsigned long duration = pulseIn(ECHO_PIN, HIGH, 60000);
  
  if (duration == 0) return -1.0f; 

  // cm 변환
  return (float)duration * 0.0343f / 2.0f;
}

float median5(float a[5]) {
  for (int i = 0; i < 5; i++) {
    for (int j = i + 1; j < 5; j++) {
      if (a[j] < a[i]) { float t=a[i]; a[i]=a[j]; a[j]=t; }
    }
  }
  return a[2];
}

uint8_t toIntensity(float cm) {
  if (cm < 0.0f || cm >= MAX_ALERT_DIST) return 0;
  if (cm <= 10.0f) return 100;

  // 10cm ~ 150cm 구간 선형 변환
  float x = (MAX_ALERT_DIST - cm) / (MAX_ALERT_DIST - 10.0f); 
  int v = (int)(x * 100.0f + 0.5f);
  if (v < 0) v = 0;
  if (v > 100) v = 100;
  return (uint8_t)v;
}

void setupBLE() {
  NimBLEDevice::init("ProxAlert");
  NimBLEServer* server = NimBLEDevice::createServer();
  NimBLEService* svc = server->createService(SVC_UUID);

  intChr = svc->createCharacteristic(
    INT_UUID,
    NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
  );

  uint8_t initVal = 0;
  intChr->setValue(&initVal, 1);
  svc->start();

  NimBLEAdvertising* adv = NimBLEDevice::getAdvertising();
  adv->addServiceUUID(SVC_UUID);
  adv->start();
}

void setup() {
  Serial.begin(115200);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);

  setupBLE();
}

void loop() {
  float s[5];

  for (int i = 0; i < 5; i++) {
    float val = readDistanceCm();
    if (val < 0.0f) s[i] = 999.0f;
    else s[i] = val;
    
    // 샘플링 간격을 60ms로 늘려서 이전 초음파 잔향과 BLE 간섭 최소화
    delay(60); 
  }
  
  float cm = median5(s);
  uint8_t intensity = toIntensity(cm);

  if (intensity != lastIntensity) {
    intChr->setValue(&intensity, 1);
    intChr->notify();
    lastIntensity = intensity;
  }

  // ============== [수정된 출력 구조] ==============
  if (cm > 900.0f) {
    // 측정 범위를 벗어났을 때 (에러 또는 너무 멀 때)
    Serial.println("distance: Safe (> 1.5m) | intensity: 0");
  } 
  else if (cm <= 30.0f) {
    // 30cm 이내로 들어왔을 때 경고 메시지 출력
    Serial.print("⚠️ [경고] 물체가 너무 가깝습니다! 현재 거리: ");
    Serial.print(cm, 1);
    Serial.println(" cm");
  } 
  else {
    // 30cm 초과일 때 정상적인 측정값 출력
    Serial.print("distance: ");
    Serial.print(cm, 1);
    Serial.print(" cm  | intensity: ");
    Serial.println(intensity);
  }
  // ================================================

  // 전체 루프 대기 시간
  delay(200);
}