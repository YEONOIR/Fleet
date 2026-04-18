# 🚗 Fleet - Vehicle Rental System

โปรเจกต์นี้เป็นส่วนหนึ่งของรายวิชา **ITDS283 Mobile Application Development**
แอปพลิเคชัน **Fleet** ถูกพัฒนาขึ้นด้วย **Flutter** เพื่อใช้เป็นระบบจัดการการเช่ายานพาหนะแบบครบวงจร

ระบบมีการแบ่งสิทธิ์การใช้งานออกเป็น 3 กลุ่มหลัก:

* 👤 **User**

  * ผู้เช่า (Renter)
  * ผู้ให้เช่า (Owner)
* 🧑‍💼 **Staff**

โดยใช้ **Firebase** เป็น Backend สำหรับจัดการข้อมูลแบบเรียลไทม์

---

## 🌟 Features

### 🔐 Role-Based Access

ระบบล็อกอินและการแสดงผล UI ที่แตกต่างกันตามประเภทผู้ใช้งาน
(User / Staff)

### 📅 Booking System

ระบบสำหรับจองยานพาหนะ พร้อมจัดการสถานะการเช่า

### 🔔 Notifications

ระบบแจ้งเตือนสถานะต่าง ๆ ภายในแอปพลิเคชัน

### ☁️ Firebase Integration

เชื่อมต่อฐานข้อมูลแบบเรียลไทม์ผ่าน Firebase

---

## 🔑 Test Accounts

### 👤 ผู้ใช้ทั่วไป (Renter)

สามารถสมัครบัญชีใหม่ได้ผ่านหน้า **Sign Up** ในแอป

### 🧑‍💼 Staff

ใช้สำหรับทดสอบระบบฝั่งพนักงาน

* **Email:** `admin@gmail.com`
* **Password:** `staffside`

---

## 🛠 Tech Stack

* **Frontend:** Flutter, Dart
* **Backend:** Firebase (Authentication, Firestore)
* **Image Storage:** ImgBB

---

## 🚀 Getting Started

### 📌 Prerequisites

ก่อนเริ่มใช้งาน กรุณาติดตั้งเครื่องมือดังนี้:

* Flutter SDK
* Dart SDK
* IDE:

  * VS Code
  * Android Studio

---

## ▶️ Run Application

สามารถรันแอปได้ 2 วิธี:

### 📱 วิธีที่ 1: ติดตั้งผ่าน APK

1. ไปที่โฟลเดอร์:

   ```
   /fleet/build/app/outputs/flutter-apk
   ```
2. ดาวน์โหลดไฟล์:

   ```
   app-release.apk
   ```
3. ติดตั้งลงบนอุปกรณ์ Android

---

### 💻 วิธีที่ 2: รันผ่าน Emulator / Device

#### 1. Clone Repository

```bash
git clone [YOUR_GITHUB_REPOSITORY_URL]
cd fleet
```

#### 2. ติดตั้ง Dependencies

```bash
flutter pub get
```

#### 3. รันแอป

```bash
flutter run
```

---

## 👨‍💻 Developed By

* **Pimthida Butsra**
  ID: 6787062

* **Sukrit Chatchawal**
  ID: 6787083

---

## ✨ Notes

* โปรเจกต์นี้ถูกพัฒนาเพื่อการศึกษา
* สามารถนำไปต่อยอดหรือปรับปรุงเพิ่มเติมได้ตามต้องการ
