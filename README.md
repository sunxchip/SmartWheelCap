# 🚗 Smart Wheel Cap 
> **측면 연석 사각지대 제로(ZERO)를 위한 순정 교체형 스마트 휠 보호 솔루션**

![Platform](https://img.shields.io/badge/Platform-Arduino%20%7C%20Flutter-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

기존 차량 범퍼 센서의 사각지대인 **측면 연석(Curb) 감지 한계**를 극복하는 융합 캡스톤 디자인 프로젝트입니다. 순정 휠캡 자리에 끼우기만 하면 되는 Plug & Play 방식을 채택하여 휠 손상을 사전에 방지합니다.

---

## 📌 1. Problem Statement
* **막대한 손실:** 연석 긁힘으로 인한 휠 복원비(15~30만 원) 및 교체비(50~100만 원+) 발생.
* **기존 센서 한계:** 전·후방 위주의 순정 범퍼 센서는 측면 사각지대(낮은 연석) 감지 불가.
* **사제 센서 한계:** 복잡한 배선 및 범퍼 타공 필요로 DIY 장착 사실상 불가능.

---

## 💡 2. Solution Overview
물체와 가장 가까운 휠 중심에서 사각지대 없이 장애물을 감지합니다.

1. **Plug & Play 디자인:** 별도 도구 없이 기존 휠캡과 1:1 교체 (10초 설치).
2. **실시간 무선 연동:** 초음파 거리 데이터를 BLE를 통해 스마트폰 및 CarPlay로 즉시 전송.
3. **직관적 위험 경보:** 연석 거리 10cm 이하 접근 시 화면 시각화 + 경고음 + 진동 알림.

---

## 🛠️ 3. System Architecture & Tech Stack

### 📐 Hardware (기계자동차공학)
* **MCU & Connectivity:** ESP32-C3 (Wi-Fi / BLE 5)
* **Sensor:** 원형 초음파 센서 모듈 (지향성 및 잔향 노이즈 최적화)
* **Integration:** 60mm 순정 휠캡 규격 내에 센서, MCU, BLE, 배터리를 통합한 고밀도 설계.

### 📱 Software (소프트웨어공학)
* **Firmware (Arduino):** * 회전 노이즈 및 센서 오차 최소화를 위한 **중간값 필터(Median Filter)** 적용.
  * 저전력 구동을 위한 데이터 변경 시에만 전송하는 **BLE Notify** 프로토콜 최적화.
* **Mobile App (Flutter):** * 실시간 BLE 데이터 스트림 파싱 엔진 및 CarPlay/Android Auto 네비게이션 화면 통합 UI 구현.

```text
[Raw Data (Ultrasonic)] ➡️ [Median Filtering] ➡️ [BLE Notify] ➡️ [Flutter / CarPlay UI]
