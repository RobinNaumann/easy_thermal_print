import 'dart:async';

import 'package:easy_thermal_print/easy_thermal_print.dart';
import 'package:flutter/widgets.dart';

import '../print.dart';

/// Represents a thermal printer with its properties and methods for printing.
/// The [deviceId] is a unique identifier for the printer.
/// The [model] is the printer model containing its specifications.
/// The [send] function is used to send print data to the printer.
/// The [printed] stream emits print data after a print job is completed.
class ThermalPrinter {
  final String deviceId;
  final PrinterModel model;
  final Future<void> Function(List<int>) send;
  final StreamController<PrintData> _printedController =
      StreamController.broadcast();

  Stream<PrintData> get printed => _printedController.stream;

  ThermalPrinter({
    required this.deviceId,
    required this.model,
    required this.send,
  });

  /// Prints a text string using the provided [config] and [style].
  /// The [text] is the content to be printed.
  /// The [style] defines the text style for printing.
  Future<void> printText(
    String text,
    PrintConfig config, {
    TextStyle style = presetTextStyle,
  }) async => print(
    await imageFromText(text, style: style, size: config.labelSize),
    config,
  );

  /// Prints a widget identified by [printableKey] using the provided [config].
  /// Make sure the widget is a `Printable`-Widget. Only this
  /// is able to extract the image data from the widget.
  Future<void> printWidget(GlobalKey printableKey, PrintConfig config) async =>
      print(await imageFromWidget(printableKey), config);

  Future<void> print(ImageData image, PrintConfig config) async {
    final res = await sendPrintJob(
      send: config.dryRun ? (_) async {} : send,
      printer: model,
      image: image,
      config: config,
    );
    _printedController.add(res);
  }

  void dispose() {
    _printedController.close();
  }
}
