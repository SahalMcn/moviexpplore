import 'package:flutter/material.dart';

// A custom painter for the dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 9, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// The main ticket widget
class MovieTicket extends StatefulWidget {
  final Widget top, bottom;
  const MovieTicket({super.key, required this.top, required this.bottom});

  @override
  State<MovieTicket> createState() => _MovieTicketState();
}

class _MovieTicketState extends State<MovieTicket>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTicketPart(widget.top, isTop: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomPaint(painter: DashedLinePainter()),
            ),
            _buildTicketPart(widget.bottom, isTop: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketPart(Widget child, {required bool isTop}) {
    double radius = 15;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: isTop
              ? BorderRadius.vertical(top: Radius.circular(radius))
              : BorderRadius.vertical(bottom: Radius.circular(radius)),
        ),
        padding: const EdgeInsets.all(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            // Left Cutout
            Positioned(
              left: -24 - radius,
              top: isTop ? null : -radius,
              bottom: isTop ? -radius : null,
              child: _buildCutout(isLeft: true),
            ),
            // Right Cutout
            Positioned(
              right: -24 - radius,
              top: isTop ? null : -radius,
              bottom: isTop ? -radius : null,
              child: _buildCutout(isLeft: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCutout({required bool isLeft}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0101),
        shape: BoxShape.circle,
      ),
    );
  }
}
