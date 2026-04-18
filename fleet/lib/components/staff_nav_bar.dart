import 'package:flutter/material.dart';

class StaffNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StaffNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<StaffNavBar> createState() => _StaffNavBarState();
}

class _StaffNavBarState extends State<StaffNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;

  static const List<IconData> _outlinedIcons = [
    Icons.home_outlined,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];

  static const List<IconData> _filledIcons = [
    Icons.home,
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _positionAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // 💡 เปลี่ยน Curve ให้พริ้วไหลลื่นขึ้น
    ));
  }

  @override
  void didUpdateWidget(covariant StaffNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _positionAnimation = Tween<double>(
        begin: oldWidget.currentIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 100, 
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. ตัวพื้นหลัง Gradient พร้อมรอยเว้าแบบใหม่
              Positioned(
                bottom: 0,
                child: CustomPaint(
                  size: Size(screenWidth, 80), 
                  painter: _NavBarPainter(
                    animatedIndex: _positionAnimation.value,
                    itemCount: 3,
                  ),
                ),
              ),
              
              // 2. แถวของไอคอน (Unselected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) {
                    final bool isActive = _positionAnimation.value.round() == index;
                    return GestureDetector(
                      onTap: () => widget.onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: screenWidth / 3,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isActive ? 0.0 : 1.0,
                          child: Icon(
                            _outlinedIcons[index],
                            color: Colors.white.withOpacity(0.8),
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 3. วงกลมที่ลอยอยู่ในรอยเว้า (Selected)
              Positioned(
                left: _getActiveIconX(screenWidth, _positionAnimation.value),
                top: 8, // 💡 ปรับให้จมลงไปในหลุมเว้าพอดีตามภาพ
                child: Container(
                  width: 56, // 💡 ขยายขนาดขึ้นนิดนึงให้ดูเต็มหลุม
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200, // 💡 สีเทาอ่อนเหมือนในภาพเรฟเฟอเรนซ์
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _filledIcons[_positionAnimation.value.round().clamp(0, 2)],
                    color: const Color.fromRGBO(7, 14, 42, 1.0),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getActiveIconX(double screenWidth, double animatedIndex) {
    final itemWidth = screenWidth / 3;
    return (animatedIndex * itemWidth) + (itemWidth / 2) - 28; // 28 คือครึ่งนึงของ width 56
  }
}

// 💡 สร้างรูปร่างรอยเว้าใหม่ทั้งหมด
class _NavBarPainter extends CustomPainter {
  final double animatedIndex;
  final int itemCount;

  _NavBarPainter({required this.animatedIndex, required this.itemCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromRGBO(172, 114, 161, 1.0),
          Color.fromRGBO(7, 14, 42, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final itemWidth = size.width / itemCount;
    final notchCenterX = (animatedIndex * itemWidth) + (itemWidth / 2);

    final path = Path();
    const double notchWidth = 96.0; // ความกว้างของรอยเว้า (ให้กว้างพอรับกับวงกลม 56px)
    const double notchDepth = 48.0; // ความลึกของรอยเว้า
    
    path.moveTo(0, 0); 
    
    // เส้นตรงด้านซ้ายก่อนถึงรอยเว้า
    path.lineTo(notchCenterX - (notchWidth / 2), 0);
    
    // 💡 วาดส่วนเว้า (Notch) ทรงกระดิ่งคว่ำให้สมูทที่สุด (Bezier Curve)
    // โค้งซ้ายลง
    path.cubicTo(
      notchCenterX - 25, 0, 
      notchCenterX - 35, notchDepth, 
      notchCenterX, notchDepth,
    );
    // โค้งขวาขึ้น
    path.cubicTo(
      notchCenterX + 35, notchDepth, 
      notchCenterX + 25, 0, 
      notchCenterX + (notchWidth / 2), 0,
    );
    
    // เส้นตรงด้านขวาไปจนสุด
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // วาดเงาเพื่อเพิ่มมิติให้ตัวบาร์
    canvas.drawShadow(path.shift(const Offset(0, -3)), Colors.black.withOpacity(0.2), 10.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) => oldDelegate.animatedIndex != animatedIndex;
}