import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 💡 สำหรับจำกัดการพิมพ์ให้ใส่ได้แค่ตัวเลข
import 'package:firebase_auth/firebase_auth.dart'; // 💡 เชื่อม Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เชื่อม Firestore

class RenterTopUpPage extends StatefulWidget {
  const RenterTopUpPage({super.key});

  @override
  State<RenterTopUpPage> createState() => _RenterTopUpPageState();
}

class _RenterTopUpPageState extends State<RenterTopUpPage> {
  // 💡 ตัวแปรระบบ
  double _currentCredit = 0.0;
  String _userIdDisplay = "Loading...";
  double? _selectedAmount;
  int? _selectedBankIndex;
  bool _isLoading = true;
  bool _isProcessing = false; // สำหรับตอนกด Confirm

  // 💡 Controller สำหรับช่องกรอกเงิน
  final TextEditingController _amountController = TextEditingController();

  static const List<Map<String, dynamic>> _banks = [
    {'name': 'SCB', 'color': Color(0xFF4E2A84), 'image': 'assets/images/bank_scb.jpg'},
    {'name': 'KBank', 'color': Color(0xFF138D3B), 'image': 'assets/images/bank_kbank.jpg'},
    {'name': 'BBL', 'color': Color(0xFF1A3C8F), 'image': 'assets/images/bank_bbl.png'},
    {'name': 'KTB', 'color': Color(0xFF00A1E4), 'image': 'assets/images/bank_ktb.png'},
    {'name': 'GSB', 'color': Color(0xFFE91E63), 'image': 'assets/images/bank_gsb.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    
    // 💡 ดักจับเวลาพิมพ์ตัวเลข เพื่อให้ระบบคำนวณยอดเงินรวมแบบ Real-time
    _amountController.addListener(() {
      setState(() {
        _selectedAmount = double.tryParse(_amountController.text);
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ==========================================
  // 💡 ฟังก์ชันดึงข้อมูลผู้ใช้จาก Firebase
  // ==========================================
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              _currentCredit = (doc['wallet_balance'] ?? 0).toDouble();
              // เอา ID 8 ตัวแรกมาโชว์ให้ดูเท่ๆ
              _userIdDisplay = user.uid.substring(0, 8).toUpperCase(); 
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 💡 ฟังก์ชันเติมเงินเข้า Firebase (อัปเดตเพิ่มแจ้งเตือนและพากลับหน้า Home)
  // ==========================================
  Future<void> _handleTopUp() async {
    if (_selectedAmount == null || _selectedAmount! <= 0 || _selectedBankIndex == null) return;

    FocusScope.of(context).unfocus(); // ซ่อนคีย์บอร์ด
    setState(() => _isProcessing = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final bankName = _banks[_selectedBankIndex!]['name'];

        // 1. อัปเดตยอดเงินในตาราง users (ใช้ FieldValue.increment เพื่อบวกเลขเพิ่ม)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'wallet_balance': FieldValue.increment(_selectedAmount!),
        });

        // 2. บันทึกประวัติการทำรายการลงตาราง transactions
        await FirebaseFirestore.instance.collection('transactions').add({
          'user_id': user.uid,
          'type': 'topup',
          'amount': _selectedAmount,
          'bank': bankName,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'success',
        });

        // 💡 3. NEW: สร้างการแจ้งเตือน (Notification) ให้กับผู้ใช้
        await FirebaseFirestore.instance.collection('notifications').add({
          'user_id': user.uid,
          'target_role': 'Renter', // กำหนดให้ Renter เห็น
          'type': 'top up success', // ต้องตรงกับ case ใน notification_card.dart
          'title': 'Top-up Successful',
          'message': 'Your wallet has been topped up with ฿$_selectedAmount via $bankName.',
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Top up ฿$_selectedAmount successful via $bankName!', style: const TextStyle(fontFamily: 'Poppins')),
              backgroundColor: const Color(0xFF2E7D6E),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // 💡 4. NEW: พากลับไปหน้า Renter Home
          // เนื่องจาก renter_home.dart ใช้คำสั่ง await รออยู่ พอกลับไปมันจะ fetch ข้อมูลใหม่ให้อัตโนมัติ
          Navigator.pop(context, true); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // สีพื้นหลังสว่างๆ แบบ Modern
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModernCreditCard(),
                        const SizedBox(height: 30),

                        const Text(
                          'Enter top-up amount',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF070E2A)),
                        ),
                        const SizedBox(height: 12),
                        _buildAmountInput(), // 💡 เปลี่ยนเป็น Input Field
                        const SizedBox(height: 24),

                        _buildBalancePreview(),
                        const SizedBox(height: 30),

                        const Text(
                          'Select payment method',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF070E2A)),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentGrid(),
                        const SizedBox(height: 40),

                        _buildConfirmButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────── Header ───────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 16, left: 8, right: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFAC72A1), Color(0xFF070E2A)]),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
          const Expanded(
            child: Text('Top-up Wallet', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  // ─────────── Modern Credit Card ───────────
  Widget _buildModernCreditCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Balance', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                '฿${_currentCredit.toStringAsFixed(2)}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF070E2A)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(20)),
            child: Text('ID: $_userIdDisplay', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFAC72A1))),
          ),
        ],
      ),
    );
  }

  // ─────────── Amount Input Field ───────────
  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true), // ใส่ได้แค่ตัวเลข
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))], // ให้ใส่ทศนิยมได้ 2 ตำแหน่ง
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF070E2A)),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 20, top: 4),
            child: Text('฿', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFAC72A1))),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  // ─────────── Balance Preview ───────────
  Widget _buildBalancePreview() {
    final balanceAfter = _selectedAmount != null && _selectedAmount! > 0 
        ? _currentCredit + _selectedAmount! 
        : _currentCredit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFFF3E5F5).withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total after top-up', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF070E2A))),
          Text(
            '฿${balanceAfter.toStringAsFixed(2)}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFAC72A1)),
          ),
        ],
      ),
    );
  }

  // ─────────── Payment Method Grid ───────────
  Widget _buildPaymentGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.9),
      itemCount: _banks.length,
      itemBuilder: (context, index) {
        final bank = _banks[index];
        final isSelected = _selectedBankIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedBankIndex = isSelected ? null : index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? (bank['color'] as Color) : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: isSelected ? (bank['color'] as Color).withOpacity(0.3) : Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(child: Image.asset(bank['image'] as String, width: 40, height: 40, fit: BoxFit.cover)),
                const SizedBox(height: 8),
                Text(bank['name'] as String, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF070E2A))),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────── Confirm Button ───────────
  Widget _buildConfirmButton() {
    bool isReady = _selectedAmount != null && _selectedAmount! > 0 && _selectedBankIndex != null;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isReady ? const LinearGradient(colors: [Color(0xFFAC72A1), Color(0xFF070E2A)]) : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
        ),
        child: ElevatedButton(
          onPressed: isReady && !_isProcessing ? _handleTopUp : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: _isProcessing
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirm Top Up', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}