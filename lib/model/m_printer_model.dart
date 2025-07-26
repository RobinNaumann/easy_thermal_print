import 'dart:ui';

import 'package:image/image.dart' as img;

import 'm_phomemo.dart';

/// an alias for the image library's Image class
typedef ImageData = img.Image;

class PrintData {
  final List<List<int>>? debugImage;
  final List<int> serialized;

  const PrintData({required this.debugImage, required this.serialized});
}

/// Configuration for printing.
/// [labelSize] specifies the size of the label to print on.
/// [printSpeed] is the speed of the printer, default is 1.
/// [packetSize] is the size of each packet sent to the printer, default is 64.
/// [halfTones] indicates whether to use half-tones for printing, default is false.
/// [dryRun] indicates whether to simulate the print job without sending data to the printer,
/// default is false.
class PrintConfig {
  /// Size of the label to print on in millimeters.
  final Size labelSize;
  final int printSpeed;
  final int packetSize;
  final bool halfTones;
  final bool dryRun;

  PrintConfig({
    required this.labelSize,
    this.printSpeed = 1,
    this.packetSize = 64,
    this.halfTones = false,
    this.dryRun = false,
  });

  PrintConfig withRotatedLabel() => PrintConfig(
    labelSize: labelSize.flipped,
    printSpeed: printSpeed,
    packetSize: packetSize,
    halfTones: halfTones,
    dryRun: dryRun,
  );
}

/// Configuration for Bluetooth Low Energy (BLE) communication.
class BLEConfig {
  final String sendServiceUuid;
  final String sendCharacteristicUuid;

  const BLEConfig({
    required this.sendServiceUuid,
    required this.sendCharacteristicUuid,
  });
}

/// Represents a printer model with its properties and serialization method.
/// The [serialize] function is used to convert the image data into a format
/// suitable for printing.
/// The [bleConfig] contains the necessary BLE service and characteristic UUIDs.
/// The [dpmm] (dots per millimeter) is used to calculate the image size
/// and is derived from the printer's DPI (dots per inch).
/// The [rotateImage] flag indicates whether the image should be rotated before printing.
/// The [brand] and [deviceName] provide identification for the printer model.
class PrinterModel {
  final String brand;
  final String deviceName;
  final bool rotateImage;

  /// dots per millimeter. used to calculate the image size <br>
  /// FYI: `dpi / 25.4 = dpmm`
  final double dpmm;
  final PrintData Function(
    PrinterModel self,
    ImageData image,
    PrintConfig config,
  )
  serialize;
  final BLEConfig bleConfig;

  const PrinterModel({
    required this.brand,
    required this.deviceName,
    required this.dpmm,
    this.rotateImage = false,
    required this.serialize,
    required this.bleConfig,
  });

  const PrinterModel.phomemo({
    this.brand = 'Phomemo',
    required this.deviceName,
    this.rotateImage = false,
    required this.dpmm,
    this.serialize = phomemoSerialize,
    this.bleConfig = phomemoBLEConfig,
  });
}

final List<PrinterModel> phomemoPrinters = [
  PrinterModel.phomemo(deviceName: 'M110', dpmm: 203 / 25.4, rotateImage: true),
  PrinterModel.phomemo(deviceName: 'D30', dpmm: 203 / 25.4),
  PrinterModel.phomemo(deviceName: 'M220', dpmm: 203 / 25.4, rotateImage: true),
  PrinterModel.phomemo(
    deviceName: 'P12Pro',
    dpmm: 203 / 25.4,
    rotateImage: true,
  ),
];
