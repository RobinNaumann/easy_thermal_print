import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../model/m_printer_model.dart';

const _presetStyle = TextStyle(
  fontFamily: 'Roboto',
  color: Colors.black,
  fontSize: 32.0,
);

Future<ImageData> imageFromText(
  String text, {
  Size? size,
  TextStyle style = _presetStyle,
  //TextAlign alignment = TextAlign.center,
}) async {
  m.TextPainter textPainter = m.TextPainter(
    text: TextSpan(text: text, style: style),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  size = Size(
    max(size?.width ?? 0, textPainter.width),
    max(size?.height ?? 0, textPainter.height),
  );

  final PictureRecorder recorder = PictureRecorder();
  Canvas newCanvas = Canvas(recorder);
  newCanvas.drawColor(m.Colors.white, m.BlendMode.color);
  textPainter.paint(newCanvas, Offset.zero);
  final Picture picture = recorder.endRecording();
  final res = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await res.toByteData(format: ImageByteFormat.png);

  if (data == null) throw Exception("Failed to convert image to byte data.");

  return img.decodePng(Uint8List.view(data.buffer))!;
}
