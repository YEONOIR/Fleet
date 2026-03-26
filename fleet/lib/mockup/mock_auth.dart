class MockAuth {
  // 💡 ตัวแปรเก็บ Role ปัจจุบัน ('User' หรือ 'Staff')
  static String currentRole = 'User'; 

  // ข้อมูลจำลองของ User ปัจจุบัน (เผื่อเอาไปดึงชื่อหรือรูปโชว์ในหน้า Profile)
  static Map<String, dynamic> currentUserData = {
    'uid': 'user_001',
    'firstName': 'Pimthida',
    'lastName': 'Butsra',
    'email': 'pimthida@example.com',
    'role': currentRole,
    'avatar': 'assets/icons/avatar.jpg', // รูปโปรไฟล์
  };

  // ฟังก์ชันสลับ Role
  static void setRole(String role) {
    currentRole = role;
    currentUserData['role'] = role;
  }
}