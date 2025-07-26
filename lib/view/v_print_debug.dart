import 'dart:math';

import 'package:easy_thermal_print/model/m_thermal_printer.dart';
import 'package:flutter/material.dart';

/// A widget that displays the printed image from a [ThermalPrinter].
/// It listens to the printer's [printed] stream and updates the UI with the latest print data.
/// The [size] parameter defines the size of the widget.
/// The [printer] parameter is the thermal printer whose print data will be displayed.
/// The widget will show the printed image if available, or an error message if there was an error during printing.
/// If no print data is available yet, it will display a message indicating that.
class PrintedViewer extends StatelessWidget {
  final ThermalPrinter printer;
  final Size size;
  const PrintedViewer({
    super.key,
    required this.printer,
    this.size = const Size(70, 70),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: printer.printed,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.debugImage != null) {
          return Container(
            color: Colors.white,
            child: CustomPaint(
              painter: _ImagePainter(snapshot.data!.debugImage!),
              size: size,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        return const Text("No print data yet.");
      },
    );
  }
}

class _ImagePainter extends CustomPainter {
  final List<List<int>> imageBits;

  _ImagePainter(this.imageBits);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black;

    if (imageBits.isEmpty || imageBits[0].isEmpty) return;

    final width = imageBits.length;
    final height = imageBits[0].length;
    final pxSize = min(size.width / width, size.height / height);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final pixelValue = imageBits[x][y];
        if (pixelValue == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * pxSize, size.height - (y * pxSize), pxSize, pxSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
