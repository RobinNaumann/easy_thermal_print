import 'dart:async';

import '../print.dart';
import 'm_printer_model.dart';

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

  Future<void> print(ImageData image, PrintConfig config) async {
    final res = await sendPrintJob(
      send: config.dryRun ? (_) async {} : send,
      printer: model,
      image: image,
      config: config,
    );
    _printedController.add(res);
  }
}
