import 'package:flutter/material.dart';

IconData getFuelIcon(String fuelType) {
  String type = fuelType.toUpperCase();
  if (type == 'EV') {
    return Icons.ev_station;
  } else if (type.contains('GAS') ||
      type.contains('LPG') ||
      type.contains('CNG')) {
    return Icons.gas_meter;
  } else {
    return Icons.local_gas_station;
  }
}
