# Fleet - Vehicle Rental System 🚗

โปรเจกต์นี้เป็นส่วนหนึ่งของรายวิชา **ITDS283 Mobile Application Development**  
แอปพลิเคชัน Fleet ถูกพัฒนาขึ้นด้วย **Flutter** เพื่อใช้สำหรับเป็นระบบจัดการการเช่ายานพาหนะที่ครอบคลุม  
โดยมีการแบ่งสิทธิ์การใช้งานออกเป็น 2 ส่วนหลัก ได้แก่ ผู้ใช้งานทั่วไป (User) ซึ่งแบ่งได้อีก 2 ประเภทคือ ผู้เช่า (Renter) กับ ผู้ให้เช่า (Owner) และ พนักงาน (Staff)  
และใช้ Firebase เป็น Backend ในการจัดการข้อมูล

---

## 🌟 ฟีเจอร์หลัก

- **Role-Based Access:**  
  ระบบล็อกอินและการแสดงผล UI ที่แยกกันชัดเจนระหว่าง ผู้ใช้งานทั่วไป (User) และพนักงาน (Staff)

- **Booking System:**  
  ระบบสำหรับการจองยานพาหนะ

- **Notifications:**  
  ระบบการแจ้งเตือนสถานะต่างcๆ ภายในแอปพลิเคชัน

- **Firebase Integration:**  
  การเชื่อมต่อฐานข้อมูลแบบเรียลไทม์ผ่าน Firebase

---

## 🔑 บัญชีสำหรับการทดสอบ (Test Accounts)

ในการทดสอบการทำงานของแอปพลิเคชัน สามารถเข้าสู่ระบบได้ตามสิทธิ์การใช้งานดังนี้:

### 👤 ผู้ใช้ทั่วไป / ผู้เช่า (Renter)
สามารถลงทะเบียนสร้างบัญชีใหม่ได้ด้วยตัวเองผ่านหน้า **Sign Up** ในแอปพลิเคชัน

### 🧑‍💼 พนักงาน (Staff)
สำหรับการทดสอบระบบในส่วนจัดการของพนักงาน กรุณาใช้บัญชีที่เตรียมไว้ให้ดังนี้:

- **Email:** `admin@gmail.com`  
- **Password:** `staffside`

---

## 🛠 เทคโนโลยีที่ใช้ (Tech Stack)

- **Frontend:** Flutter & Dart  
- **Backend:** Firebase (Authentication, Firestore) & Imgbb (สำหรับเก็บรูป) 

---

## 🚀 วิธีการติดตั้งและการรันโปรเจกต์ (Getting Started)

### 📌 สิ่งที่ต้องมีเบื้องต้น (Prerequisites)

ก่อนที่จะเริ่มรันโปรเจกต์ กรุณาตรวจสอบให้แน่ใจว่าได้ติดตั้งเครื่องมือเหล่านี้แล้ว:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- IDE เช่น:
  - [VS Code](https://code.visualstudio.com/)
  - [Android Studio](https://developer.android.com/studio)

---

### ▶️ ขั้นตอนการรันแอปพลิเคชัน

1. **Clone repository นี้ลงเครื่องของคุณ**
   ```bash
   git clone [ใส่_URL_ของ_GitHub_Repository_ที่นี่]
   cd fleet

2.  **ติดตั้ง Packages ทั้งหมดที่จำเป็น**
    ```bash
   flutter pub get

3. **รันแอปพลิเคชัน**
    เปิด Emulator (เช่น Android Emulator หรือ iOS Simulator)
    จากนั้นใช้คำสั่ง
    ```bash
    flutter run

## Developed by
1. Pimthida Butsra
    ID: 6787062

2. Sukrit Chatchawal
    ID: 6787083
