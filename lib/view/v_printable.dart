import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

import '../model/m_printer_model.dart';

class Printable extends StatelessWidget {
  final Widget child;
  Printable({required super.key, required this.child});

  final GlobalKey globalKey = GlobalKey();

  Future<ImageData> asImage() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 6.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return img.decodePng(Uint8List.view(pngBytes.buffer))!;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(color: Colors.white, child: child),
    );
  }
}
