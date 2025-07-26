import "package:image/image.dart" as img;

import "model/m_printer_model.dart";
import "util.dart";

/// if labelSize is undefined, it will adapt to the image being printed
/// this however only works when only printing one image
/// [spacing] specifies how many labels to leave free between prints
Future<PrintData> sendPrintJob({
  required Future<void> Function(List<int>) send,
  required PrinterModel printer,
  required ImageData image,
  required PrintConfig config,
}) async {
  if (config.labelSize.width <= 1 || config.labelSize.height <= 1) {
    throw ArgumentError(
      "Label size must be greater than 1 in both dimensions.",
    );
  }
  if (image.width <= 0 || image.height <= 0) {
    throw ArgumentError("Image dimensions must be greater than zero.");
  }

  if (printer.rotateImage) {
    //config = config.withRotatedLabel();
    image = img.copyRotate(image, angle: 90);
  }

  final fittedImg = ImageTools.resizeToFit(image, printer, config.labelSize);

  final pData = printer.serialize(printer, fittedImg, config);
  final packets = splitIntoPackets(pData.serialized, config.packetSize);
  for (final packet in packets) {
    await send(packet);
  }
  return pData;
}

List<List<int>> splitIntoPackets(List<int> data, int packetSize) {
  final packets = <List<int>>[];
  for (int i = 0; i < data.length; i += packetSize) {
    final end = (i + packetSize < data.length) ? i + packetSize : data.length;
    packets.add(data.sublist(i, end));
  }
  return packets;
}
