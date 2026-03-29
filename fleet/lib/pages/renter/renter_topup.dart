import 'package:flutter/material.dart';

class RenterTopUpPage extends StatefulWidget {
  const RenterTopUpPage({super.key});

  @override
  State<RenterTopUpPage> createState() => _RenterTopUpPageState();
}

class _RenterTopUpPageState extends State<RenterTopUpPage> {
  int _currentCredit = 100;
  int? _selectedAmount;
  int? _selectedBankIndex;

  final List<int> _amounts = [100, 200, 300, 400];

  // Bank data with logo images
  static const List<Map<String, dynamic>> _banks = [
    {'name': 'SCB', 'color': Color(0xFF4E2A84), 'image': 'assets/images/bank_scb.jpg'},
    {'name': 'KBank', 'color': Color(0xFF138D3B), 'image': 'assets/images/bank_kbank.jpg'},
    {'name': 'BBL', 'color': Color(0xFF1A3C8F), 'image': 'assets/images/bank_bbl.png'},
    {'name': 'KTB', 'color': Color(0xFF00A1E4), 'image': 'assets/images/bank_ktb.png'},
    {'name': 'GSB', 'color': Color(0xFFE91E63), 'image': 'assets/images/bank_gsb.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-up Credit + Your Credit badge
                  _buildCreditInfoRow(),
                  const SizedBox(height: 28),

                  // Select amount
                  const Text(
                    'select top - amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF070E2A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAmountSelector(),
                  const SizedBox(height: 24),

                  // Balance after top-up
                  _buildBalancePreview(),
                  const SizedBox(height: 28),

                  // Payment method
                  const Text(
                    'Select your payment method',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF070E2A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentGrid(),
                  const SizedBox(height: 30),

                  // Confirm button
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 8,
        right: 8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFAC72A1),
            Color(0xFF070E2A),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'Top - up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  // ─────────── Credit Info Row ───────────
  Widget _buildCreditInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Top-up Credit + ID
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top - up Credit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF070E2A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'your ID : **********',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        // Right side: Your credit badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFCE93D8),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'your credit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF070E2A),
                ),
              ),
              Text(
                '$_currentCredit',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF070E2A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────── Amount Selector ───────────
  Widget _buildAmountSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _amounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAmount = isSelected ? null : amount;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF070E2A) : const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF070E2A) : const Color(0xFFCE93D8),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$amount',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF070E2A),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────── Balance Preview ───────────
  Widget _buildBalancePreview() {
    final balanceAfter = _selectedAmount != null
        ? _currentCredit + _selectedAmount!
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Balance after top - up',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF070E2A),
            ),
          ),
          Text(
            balanceAfter != null ? '$balanceAfter' : '-',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF070E2A),
            ),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: _banks.length,
      itemBuilder: (context, index) {
        final bank = _banks[index];
        final isSelected = _selectedBankIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBankIndex = isSelected ? null : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (bank['color'] as Color).withValues(alpha: 0.15)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? (bank['color'] as Color)
                          : const Color(0xFFCE93D8).withValues(alpha: 0.5),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (bank['color'] as Color).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        bank['image'] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bank['name'] as String,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? bank['color'] as Color
                        : const Color(0xFF070E2A),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────── Confirm Button ───────────
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFAC72A1),
              Color(0xFF070E2A),
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: (_selectedAmount != null && _selectedBankIndex != null)
              ? () {
                  final bankName = _banks[_selectedBankIndex!]['name'];
                  setState(() {
                    _currentCredit += _selectedAmount!;
                    _selectedAmount = null;
                    _selectedBankIndex = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Top up successful via $bankName! New balance: $_currentCredit',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: const Color(0xFF4A1942),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Confirm Top Up',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: (_selectedAmount != null && _selectedBankIndex != null)
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
