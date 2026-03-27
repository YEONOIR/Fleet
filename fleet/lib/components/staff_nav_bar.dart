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
      curve: Curves.easeOutBack, // 💡 ใช้ curve แบบสะท้อนนิดๆ จะดูพรีเมียมขึ้น
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
        curve: Curves.easeOutBack,
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
          height: 100, // 💡 เพิ่มความสูงให้ครอบคลุมส่วนที่ลอยขึ้นมา
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. ตัวพื้นหลัง Gradient พร้อมรอยเว้า
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
                            color: Colors.white.withOpacity(0.7),
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 3. 💡 วงกลมสีขาวที่ลอยอยู่เหนือรอยเว้า (Selected)
              Positioned(
                left: _getActiveIconX(screenWidth, _positionAnimation.value),
                top: 5, // 💡 ขยับให้ลอยอยู่กึ่งกลางรอยเว้าพอดี
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
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
    return (animatedIndex * itemWidth) + (itemWidth / 2) - 27;
  }
}

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
    const curveRadius = 38.0; // 💡 ความกว้างของปากรอยเว้า
    
    path.moveTo(0, 0); // เริ่มที่มุมซ้ายบนของตัว Bar (ที่ความสูง 80)
    
    // วาดเส้นตรงมาจนถึงก่อนเริ่มรอยเว้า
    path.lineTo(notchCenterX - curveRadius - 15, 0);
    
    // วาดส่วนโค้งเว้าลงไป (Notch) แบบพริ้วๆ
    path.quadraticBezierTo(
      notchCenterX - curveRadius, 0, 
      notchCenterX - curveRadius + 10, 8,
    );
    path.arcToPoint(
      Offset(notchCenterX + curveRadius - 10, 8),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    path.quadraticBezierTo(
      notchCenterX + curveRadius, 0, 
      notchCenterX + curveRadius + 15, 0,
    );
    
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // วาดเงาให้ตัว Bar นิดนึงให้ดูมีมิติ
    canvas.drawShadow(path.shift(const Offset(0, -1)), Colors.black.withOpacity(0.3), 5.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) => oldDelegate.animatedIndex != animatedIndex;
}