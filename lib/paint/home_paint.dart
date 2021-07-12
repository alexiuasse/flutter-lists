import 'package:flutter/material.dart';

class HomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();

    // paint.style = PaintingStyle.stroke;
    // paint.strokeWidth = 8.0;

    // path.lineTo(0, size.height * 0.66);
    // path.cubicTo(size.width / 2, size.height, size.width / 2, size.height / 5, size.width, size.height * 1.1);
    // path.lineTo(size.width, 0);
    // path.close();
    //
    // paint.color = Colors.pink;
    // canvas.drawPath(path, paint);
    //
    path = Path();
    path.lineTo(0, size.height * 0.33);
    path.cubicTo(size.width / 2, size.height, size.width / 2, size.height / 5, size.width, size.height * 1.2);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = Colors.red;
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, 0);
    path.cubicTo(size.width / 2, size.height, size.width / 2, size.height / 5, size.width, size.height * 1.3);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = Colors.black.withOpacity(0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
