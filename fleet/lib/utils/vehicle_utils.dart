import 'package:flutter/material.dart';

// 💡 ย้ายฟังก์ชันมาไว้ที่นี่ที่เดียว และเอา (_) ออกจากหน้าชื่อเพื่อให้ไฟล์อื่นเรียกใช้ได้
IconData getFuelIcon(String fuelType) {
  String type = fuelType.toUpperCase();
  if (type == 'EV') {
    return Icons.ev_station;
  } else if (type.contains('GAS') || type.contains('LPG') || type.contains('CNG')) {
    return Icons.gas_meter;
  } else {
    return Icons.local_gas_station;
  }
}