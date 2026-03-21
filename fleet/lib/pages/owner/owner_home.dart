import 'package:flutter/material.dart';
import '../../components/vehicle_mini_card.dart';
import '../../components/take_photo.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  // ==========================================
  // 💡 Dummy Data (อิงตาม Data Dictionary)
  // ==========================================
  final List<Map<String, dynamic>> dummyRequests = [
    {
      "Request Type": "Rent", // ใช้แยกประเภท UI (เช่า / คืน)
      "Rent Status": "Pending",
      "Rent_Start": "08-02-2026 12:00", // DATETIME
      "Rent Handin": "12-02-2026 14:00", // DATETIME
      "Rent Price": 750.0,
      "Acc FName": "Sukrit",
      "Acc LName": "Chatchawal",
      "Acc Phone": "0848978975",
      "Acc Rate": 3.0,
      "Acc Email": "sukrit@email.com",
      "renterImage": "assets/icons/avatar.jpg", // รูป Mockup
      "vehicleData": {
        "V Name": "Pimthida's Bike",
        "V_Rate": 4.5,
        "imagePath": "assets/images/bike.jpg", // รูป Mockup
        "V Plate": "BB 567",
        "V Brand": "Yamaha",
        "V Model": "GRAND FILANO HYBRID",
        "V Type": "Motorcycle",
        "V Fuel": "Hybrid",
        "V Address": "222 JJ village, Loo Road, Llama, Penguin, Bangkok 10120",
        "V Price": 300.0,
        "V Deposit": 1000.0,
        "typeIcon": Icons.local_gas_station, // รูป Mockup
      },
    },
    {
      "Request Type": "Hand in",
      "Rent Status": "Using",
      "Rent_Start": "01-02-2026 10:00",
      "Rent Handin": "05-02-2026 10:00",
      "Rent Price": 1000.0,
      "Acc FName": "Pimthida",
      "Acc LName": "Butsra",
      "Acc Phone": "0812345678",
      "Acc Rate": 3.7,
      "Acc Email": "pimthida@email.com",
      "renterImage": "assets/icons/avatar.jpg",
      "vehicleData": {
        "V Name": "Sukrit's Honda",
        "V_Rate": 4.5,
        "imagePath": "assets/images/car.jpg",
        "V Plate": "AB 1222",
        "V Brand": "Honda",
        "V Model": "Civic e:HEV",
        "V Type": "4 Door Car",
        "V Fuel": "Hybrid",
        "V Address": "111/11, Ander Road, Cromium, Roselina, Bangkok 11111",
        "V Price": 250.0,
        "V Deposit": 5000.0,
        "typeIcon": Icons.ev_station,
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      body: SingleChildScrollView( // ย้าย SafeArea เข้าไปข้างในเพื่อให้ Gradient ชิดขอบบน
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 💡 1. New Header with Purple Gradient (เหมือน Smart Garage)
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(172, 114, 161, 1.0),
                    Color.fromRGBO(7, 14, 42, 1.0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'Sukrit! 👋',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // 💡 2. ย้าย Summary Card มาซ้อนไว้ใน Gradient ให้ดูเป็นเนื้อเดียวกัน
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '฿ 12,500.00',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. Request Section (รายการคำขอ)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Requests',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(7, 14, 42, 1.0),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // วนลูปสร้างการ์ด Request
                  ...dummyRequests.map(
                    (request) => _buildRequestCard(context, request),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Widget สำหรับสร้างการ์ด 1 ใบ (เพิ่ม BuildContext context เข้ามา)
  // ==========================================
  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    final isRent = request['Request Type'] == 'Rent';

    // หั่น string DATETIME ออกเป็น Date กับ Time
    final startDateParts = request['Rent_Start'].toString().split(' ');
    final endDateParts = request['Rent Handin'].toString().split(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5)),
      ),
      child: Column(
        children: [
          // ----------------------------------------
          // 3.1 ข้อมูลผู้เช่า (Header สีม่วงเข้ม)
          // ----------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(42, 35, 66, 1.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(request['renterImage']),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ดึงชื่อและนามสกุลมาต่อกัน
                      Text(
                        '${request['Acc FName']} ${request['Acc LName']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // ดึงเบอร์โทรศัพท์
                      Text(
                        'Tel: ${request['Acc Phone']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      request['Acc Rate'].toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ----------------------------------------
          // 3.2 เนื้อหาคำขอ (วันที่ + ข้อมูลรถ)
          // ----------------------------------------
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRent ? 'Request to rent' : 'Request to hand in',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(isRent ? 'Rent' : 'Hand in', isRent),
                  ],
                ),
                const SizedBox(height: 5),

                // แสดงวันและเวลา (ที่หั่นมาจาก DATETIME)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${startDateParts[0]}    ${startDateParts.length > 1 ? startDateParts[1] : ''}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${endDateParts[0]}    ${endDateParts.length > 1 ? endDateParts[1] : ''}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // 💡 เรียกใช้ VehicleMiniCard (ส่งข้อมูลให้ตรงตาม Data Dictionary)
                VehicleMiniCard(
                  vName: request['vehicleData']['V Name'],
                  vRate: request['vehicleData']['V_Rate'],
                  imagePath: request['vehicleData']['imagePath'],
                  vPlate: request['vehicleData']['V Plate'],
                  vBrand: request['vehicleData']['V Brand'],
                  vModel: request['vehicleData']['V Model'],
                  vType: request['vehicleData']['V Type'],
                  vFuel: request['vehicleData']['V Fuel'],
                  vAddress: request['vehicleData']['V Address'],
                  vPrice: request['vehicleData']['V Price'],
                  typeIcon: request['vehicleData']['typeIcon'],
                ),

                const SizedBox(height: 15),

                // ----------------------------------------
                // 3.3 ปุ่มกด Action (รับ/ปฏิเสธ) พร้อม Modal
                // ----------------------------------------
                isRent
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(Icons.close, const Color(0xFFF07B75), () {
                              _showRejectReasonModal(context, request); // ❌ กดกากบาท
                            }),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionButton(Icons.check, const Color(0xFF75DB73), () {
                              _showAcceptModal(context, request); // ✅ กดติ๊กถูก
                            }),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          // 💡 วางคำสั่งย้ายไปหน้า TakePhotoPage ตรงนี้ครับ!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakePhotoPage(
                                vehicleName: request['vehicleData']['V Name'],
                              ),
                            ),
                          );
                        },
                        child: _buildAcceptButton(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Modal: 1. พิมพ์เหตุผลการยกเลิก
  // ==========================================
  void _showRejectReasonModal(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Request',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(7, 14, 42, 1.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please state the reason for declining this request:',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g., The car is currently unavailable...',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(172, 114, 161, 1.0),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF07B75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showConfirmRejectModal(context, request, reasonController.text);
            },
            child: const Text(
              'Next',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Modal: 2. ยืนยันการส่งการปฏิเสธให้ Renter
  // ==========================================
  void _showConfirmRejectModal(
    BuildContext context,
    Map<String, dynamic> request,
    String reason,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Rejection',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(7, 14, 42, 1.0),
          ),
        ),
        content: Text(
          'Are you sure you want to decline ${request['Acc FName']}\'s request?\n\nYour Reason:\n"$reason"',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Rejection sent to the renter.',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              );
            },
            child: const Text(
              'Send to Renter',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Modal: 3. ยืนยันการปล่อยเช่า (เมื่อกด ✅)
  // ==========================================
  void _showAcceptModal(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Accept Request',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(7, 14, 42, 1.0),
          ),
        ),
        content: Text(
          'Do you confirm to rent "${request['vehicleData']['V Name']}" to ${request['Acc FName']}?',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF75DB73),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Rental accepted successfully!',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              );
            },
            child: const Text(
              'Confirm Rent',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ป้ายกำกับเล็กๆ (Rent สีทอง / Hand in สีม่วง)
  Widget _buildStatusBadge(String text, bool isRent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRent ? const Color(0xFFD39A3D) : const Color(0xFF6B66CA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ปุ่ม (กากบาท / เครื่องหมายถูก) เพิ่ม onTap เข้าไป
  // ปุ่ม (กากบาท / เครื่องหมายถูก) รับค่า onTap มาทำงาน
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12), 
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), 
        child: Icon(icon, color: Colors.black87, size: 28),
      ),
    );
  }

  // ปุ่ม Accept ใหญ่
  Widget _buildAcceptButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF6B66CA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'Accept',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
