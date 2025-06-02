import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _controller2 = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0, end: 1).animate(_controller1);
    _animation2 = Tween<double>(begin: 0, end: 1).animate(_controller2);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF64B5F6)],
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation1, _animation2]),
        builder: (context, child) {
          return CustomPaint(
            painter: BackgroundPainter(_animation1.value, _animation2.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation1;
  final double animation2;

  BackgroundPainter(this.animation1, this.animation2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Floating circles
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + (50 * animation1),
        size.height * 0.2 + (30 * animation1),
      ),
      60 + (20 * animation1),
      paint1,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.2 - (30 * animation2),
        size.height * 0.6 + (40 * animation2),
      ),
      80 + (15 * animation2),
      paint2,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.6 + (40 * animation1),
        size.height * 0.8 - (20 * animation1),
      ),
      40 + (25 * animation1),
      paint1,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
