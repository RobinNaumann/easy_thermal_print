import '../util.dart';
import 'm_printer_model.dart';

const phomemoBLEConfig = BLEConfig(
  sendServiceUuid: "0000ff00-0000-1000-8000-00805f9b34fb",
  sendCharacteristicUuid: "0000ae10-0000-1000-8000-00805f9b34fb",
);

PrintData phomemoSerialize(
  PrinterModel self,
  ImageData image,
  PrintConfig config,
) {
  if (config.labelSize.height.isInfinite) {
    throw ArgumentError("labelSize can't have infinite height");
  }

  final List<int> sendData = [];

  // ==== Add header data
  // set print speed
  sendData.addAll([0x1b, 0x4e, 0x0d]); // -> Print Speed Command
  sendData.add(clamp(config.printSpeed, 1, 5)); // range: 1 - 5 (fast)

  // set print density
  sendData.addAll([0x1b, 0x4e, 0x04]); // -> Print Density Command
  sendData.add(clamp(15, 1, 15)); // range: 1 - 15

  // set media type
  final mode = config.labelSize.width.isInfinite ? 0x0b : 0x0a;
  sendData.addAll([0x1f, 0x11]); // -> Media Type Command
  sendData.add(clamp(mode, 0xa, 0xb)); //0a:Label With Gaps, 0b:Continuous

  // ==== Add image metadata
  // block marker
  sendData.addAll([0x1d, 0x76, 0x30]); // -> print raster bits command
  sendData.add(0x00); // normal mode
  // image size
  final h = (image.height / 8).ceil();
  final w = (image.width + 1);
  sendData.addAll([h % 256, h ~/ 256]); // height
  sendData.addAll([w % 256, w ~/ 256]); // width

  // ==== Add image data
  final imgRowsBits = ImageTools.convertToRows(
    ImageTools.process(image),
    config.halfTones,
  );
  final imgRows = imgRowsBits.map((bits) => asByteList(bits)).toList();
  sendData.addAll(imgRows.reduce((a, b) => [...a, ...b]));

  // add 1 white line to turn off the heating unit
  sendData.addAll(List.filled(h, 0x00));

  // ==== Add footer data
  sendData.addAll([0x1f, 0xf0, 0x05, 0x00, 0x1f, 0xf0, 0x03, 0x00]);

  return PrintData(debugImage: imgRowsBits, serialized: sendData);
}
