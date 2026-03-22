import 'package:flutter/material.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>(); // ใช้สำหรับ Validation

  // ตัวแปรเก็บค่าจากฟอร์ม
  String? selectedType;
  String? selectedFuel;
  
  // ตัวเลือกสำหรับ Dropdown
  final List<String> vehicleTypes = ['4 Door Car', 'Motorcycle', 'Van', 'Truck', 'SUV'];
  final List<String> fuelTypes = ['Sohol 95', 'Sohol 91', 'Diesel', 'EV', 'LPG'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text('Add New Vehicle', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // 💡 ผูก FormKey เพื่อดักจับข้อมูล
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. Image Upload Mockup
              // ==========================================
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: ใส่ฟังก์ชันเลือกรูปภาพจาก Gallery
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open Image Gallery...', style: TextStyle(fontFamily: 'Poppins'))),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text('Tap to upload vehicle image', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ==========================================
              // 2. ข้อมูลทั่วไป (General Information)
              // ==========================================
              const Text('General Info', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
              const SizedBox(height: 15),
              _buildTextField('Vehicle Name', 'e.g., Sukrit\'s Honda'),
              Row(
                children: [
                  Expanded(child: _buildTextField('Brand', 'e.g., Honda')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField('Model', 'e.g., Civic')),
                ],
              ),
              _buildTextField('License Plate', 'e.g., AB 1222'),

              const SizedBox(height: 10),

              // ==========================================
              // 3. ประเภทและพลังงาน (Type & Fuel)
              // ==========================================
              Row(
                children: [
                  Expanded(child: _buildDropdown('Vehicle Type', vehicleTypes, selectedType, (val) => setState(() => selectedType = val))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDropdown('Fuel/Energy', fuelTypes, selectedFuel, (val) => setState(() => selectedFuel = val))),
                ],
              ),
              const SizedBox(height: 10),

              // ==========================================
              // 4. ที่อยู่และราคา (Address & Pricing)
              // ==========================================
              const Text('Location & Pricing', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
              const SizedBox(height: 15),
              _buildTextField('Pickup Address', 'Enter full address...', maxLines: 3),
              Row(
                children: [
                  Expanded(child: _buildTextField('Price / Hour (฿)', '0.00', isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField('Deposit (฿)', '0.00', isNumber: true)),
                ],
              ),
              const SizedBox(height: 30),

              // ==========================================
              // 5. Submit Button
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    // 💡 เช็คว่ากรอกข้อมูลครบไหม (รวมถึง Dropdown)
                    if (_formKey.currentState!.validate()) {
                      if (selectedType == null || selectedFuel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Vehicle Type and Fuel.', style: TextStyle(fontFamily: 'Poppins'))));
                        return;
                      }
                      
                      // ถ้าผ่านหมด ให้ทำอะไรต่อ (เช่น บันทึกเข้า Database)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle added successfully!', style: TextStyle(fontFamily: 'Poppins'))));
                      Navigator.pop(context); // เด้งกลับไปหน้าก่อนหน้า
                    }
                  },
                  child: const Text('Add Vehicle', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 💡 Helper Widgets: สำหรับสร้างช่องกรอกข้อมูล
  // ==========================================
  
  // 1. ฟังก์ชันสร้าง TextField
  Widget _buildTextField(String label, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0), width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label'; // 💡 แจ้งเตือนถ้าไม่กรอก
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // 2. ฟังก์ชันสร้าง Dropdown
  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedValue,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0), width: 1.5)),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontFamily: 'Poppins')));
            }).toList(),
            onChanged: onChanged,
            hint: const Text('Select', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}