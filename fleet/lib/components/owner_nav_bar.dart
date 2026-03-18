import 'package:flutter/material.dart';

class OwnerNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const OwnerNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<OwnerNavBar> createState() => _OwnerNavBarState();
}

class _OwnerNavBarState extends State<OwnerNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late int _previousIndex;

  static const List<IconData> _outlinedIcons = [
    Icons.home_outlined,
    Icons.description_outlined,
    Icons.calendar_today_outlined,
    Icons.notifications_outlined,
    Icons.person_outline,
  ];

  static const List<IconData> _filledIcons = [
    Icons.home,
    Icons.description,
    Icons.calendar_month, 
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _positionAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant OwnerNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _positionAnimation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
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
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background with notch
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 90),
                painter: _NavBarPainter(
                  animatedIndex: _positionAnimation.value,
                  itemCount: 5,
                ),
              ),
              // Icons row
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    return _buildNavItem(index);
                  }),
                ),
              ),
              Positioned(
                left: _getActiveIconX(
                    MediaQuery.of(context).size.width, _positionAnimation.value),
                top: -2,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(217, 217, 217, 1.0),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _filledIcons[_getNearestIndex(_positionAnimation.value)],
                    color: const Color.fromRGBO(7, 14, 42, 1.0),
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getNearestIndex(double value) {
    return value.round().clamp(0, 4);
  }

  double _getActiveIconX(double screenWidth, double animatedIndex) {
    final itemWidth = screenWidth / 5;
    return (animatedIndex * itemWidth) + (itemWidth / 2) - 26;
  }

  Widget _buildNavItem(int index) {
    final bool isActive =
        (_getNearestIndex(_positionAnimation.value) == index);

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isActive ? 0.0 : 1.0,
          child: Icon(
            _outlinedIcons[index],
            color: Colors.white.withOpacity(0.85),
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final double animatedIndex;
  final int itemCount;

  _NavBarPainter({
    required this.animatedIndex,
    required this.itemCount,
  });

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

    const notchRadius = 34.0;
    const notchDepth = 22.0;
    const curveWidth = 38.0;

    final barTop = 20.0;

    final path = Path();

    path.moveTo(0, barTop);

    final notchStartX = notchCenterX - notchRadius - curveWidth;
    path.lineTo(notchStartX.clamp(0, size.width), barTop);

    path.cubicTo(
      notchCenterX - notchRadius - (curveWidth * 0.3),
      barTop,
      notchCenterX - notchRadius,
      barTop - notchDepth * 0.4,
      notchCenterX - notchRadius * 0.7,
      barTop - notchDepth,
    );


    path.cubicTo(
      notchCenterX - notchRadius * 0.35,
      barTop - notchDepth - 8,
      notchCenterX + notchRadius * 0.35,
      barTop - notchDepth - 8,
      notchCenterX + notchRadius * 0.7,
      barTop - notchDepth,
    );

    path.cubicTo(
      notchCenterX + notchRadius,
      barTop - notchDepth * 0.4,
      notchCenterX + notchRadius + (curveWidth * 0.3),
      barTop,
      (notchCenterX + notchRadius + curveWidth).clamp(0, size.width),
      barTop,
    );

    path.lineTo(size.width, barTop);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex;
  }
}