import 'package:flutter/material.dart' as m;

import '../model/m_printer_model.dart';
import '../view/v_printable.dart';

Future<ImageData> imageFromWidget(m.GlobalKey printableKey) async {
  var widget = printableKey.currentContext?.widget;
  if (widget == null) {
    throw Exception(
      "No printable widget found with the provided key. Make sure you apply the globalKey to a `Printable` widget.",
    );
  }
  if (widget is! Printable) {
    throw Exception(
      "The widget with the provided key is not a `Printable` widget.",
    );
  }
  return await (widget).asImage();
}
