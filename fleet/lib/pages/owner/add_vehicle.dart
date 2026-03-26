import 'dart:io';
import 'package:flutter/material.dart';
import '../../components/take_photo.dart'; // 💡 อย่าลืม import หน้ากล้องกลับมาด้วย

class AddVehiclePage extends StatefulWidget {
  final List<String>? vehicleImagePaths;
  const AddVehiclePage({super.key, this.vehicleImagePaths});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedType;
  String? selectedFuel;

  // 💡 ตัวแปรเก็บรูปล่าสุด (Save State)
  List<String>? _currentImagePaths;

  final List<String> vehicleTypes = [
    'Sedan (4-Door Car)',
    'Hatchback (5-Door Car)',
    'SUV / PPV (Sport Utility)',
    'MPV (Family Car)',
    'Pickup Truck (Open Bed)',
    'Van (Passenger Van)',
    'Scooter (Automatic)',
    'Motorcycle (Manual Gear)',
    'Big Bike (Large Engine)',
    'Campervan (Motorhome)',
    'Luxury Car (Premium)',
    'Others (Unspecified)',
  ];

  final List<String> fuelTypes = [
    'Gasohol 95 (E10 Blend)',
    'Gasohol 91 (E10 Blend)',
    'Gasohol E20 (20% Ethanol)',
    'Gasohol E85 (85% Ethanol)',
    'Gasoline 95 (Pure Benzine)',
    'Diesel (Standard Diesel)',
    'EV (100% Electric)',
    'Hybrid / PHEV (Gas & Electric)',
    'LPG / CNG (Autogas)',
  ];

  @override
  void initState() {
    super.initState();
    // 💡 ตอนเปิดหน้ามาครั้งแรก ให้เอารูปที่ส่งมาใส่ใน State ก่อน
    _currentImagePaths = widget.vehicleImagePaths;
  }

  Widget _buildImageSlider() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.only(top: 15, bottom: 5, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _currentImagePaths!.map((imgPath) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imgPath),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 💡 ปุ่ม Edit Photos (กดเพื่อไปถ่ายใหม่)
          TextButton.icon(
            onPressed: () async {
              // เปิดหน้า TakePhoto รอรับค่ากลับมา (await)
              final newPhotos = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TakePhotoPage(vehicleName: 'Edit Photos'),
                ),
              );

              // ถ่ายเสร็จส่งรูปกลับมา อัปเดต State เลย!
              if (newPhotos != null && newPhotos is List<String>) {
                setState(() {
                  _currentImagePaths = newPhotos;
                });
              }
            },
            icon: const Icon(
              Icons.edit,
              size: 16,
              color: Color.fromRGBO(172, 114, 161, 1.0),
            ),
            label: const Text(
              'Edit Photos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color.fromRGBO(172, 114, 161, 1.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(172, 114, 161, 1.0),
                Color.fromRGBO(7, 14, 42, 1.0),
              ],
            ),
          ),
        ),
        title: const Text(
          'Add New Vehicle',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (_currentImagePaths != null && _currentImagePaths!.isNotEmpty)
            _buildImageSlider()
          else
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No images selected',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'General Info',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(7, 14, 42, 1.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField('Vehicle Name', 'e.g., Sukrit\'s Honda'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField('Brand', 'e.g., Honda'),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField('Model', 'e.g., Civic'),
                        ),
                      ],
                    ),
                    _buildTextField('License Plate', 'e.g., AB 1222'),

                    const SizedBox(height: 10),

                    // 💡 แก้ Type & Fuel ให้อยู่คนละบรรทัดเรียบร้อย
                    const Text(
                      'Type & Fuel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(7, 14, 42, 1.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      'Vehicle Type',
                      vehicleTypes,
                      selectedType,
                      (val) => setState(() => selectedType = val),
                    ),
                    _buildDropdown(
                      'Fuel/Energy',
                      fuelTypes,
                      selectedFuel,
                      (val) => setState(() => selectedFuel = val),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Location & Pricing',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(7, 14, 42, 1.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      'Pickup Address',
                      'Enter full address...',
                      maxLines: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Price / Hour (฿)',
                            '0.00',
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            'Deposit (฿)',
                            '0.00',
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            172,
                            114,
                            161,
                            1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (selectedType == null || selectedFuel == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select Vehicle Type and Fuel.',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                              );
                              return;
                            }

                            // 💡 1. เปลี่ยนข้อความ SnackBar แจ้งเตือน และเพิ่มพื้นหลังสีดำให้ดูเท่ขึ้น
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Add vehicle request sent to staff!',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                backgroundColor: Colors.black87,
                              ),
                            );

                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                        },
                        // 💡 2. เปลี่ยนข้อความบนปุ่ม
                        child: const Text(
                          'Send Add Request',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(172, 114, 161, 1.0),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Please enter $label';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true, // 💡 ตัวนี้ช่วยกันข้อความทะลุจอ
            value: selectedValue,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(172, 114, 161, 1.0),
                  width: 1.5,
                ),
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            hint: const Text(
              'Select',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
