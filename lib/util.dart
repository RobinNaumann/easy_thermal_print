import "dart:ui";

import "package:image/image.dart" as img;

import "model/m_printer_model.dart";

abstract class ImageTools {
  static ImageData resizeToFit(
    ImageData image,
    PrinterModel printer,
    Size labelSize,
  ) {
    final imgRatio = image.width / image.height;
    final maxHeight = labelSize.height;
    final maxWidth =
        labelSize.width.isInfinite
            ? labelSize.height * imgRatio
            : labelSize.width;

    // resize image to fit label size
    final overflowX = maxWidth / (image.width / printer.dpmm);
    final overflowY = maxHeight / (image.height / printer.dpmm);

    final scaleFactor = overflowX < overflowY ? overflowX : overflowY;
    //if (scaleFactor == 1) return image; // no need to resize

    //throw "${scaleFactor}, ${image.width * scaleFactor}, ${image.height * scaleFactor}";

    return img.copyResize(
      image,
      width: (image.width * scaleFactor).round(),
      height: (image.height * scaleFactor).round(),
    );
  }

  static ImageData process(ImageData image) {
    image = img.grayscale(image);
    return image;
  }

  static int halfTonePixel(int brightness, int x, int y) {
    if (brightness < 128) return 1; // black pixel
    if (brightness < 180 && (y % 2 == 0 && x % 2 == 0)) return 1;
    if (brightness < 220 &&
        ((y % 4 == 0 && x % 4 == 0) || (y % 4 == 2 && x % 4 == 2)))
      return 1;
    if (brightness < 240 && (y % 4 == 0 && x % 4 == 0)) return 1;
    return 0; // white pixel
  }

  static List<List<int>> convertToRows(ImageData img, bool halfTones) {
    final List<List<int>> bitRows = [];
    for (int x = 0; x < img.width; x++) {
      final List<int> bits = [];
      for (int y = img.height - 1; y >= 0; y--) {
        final pixel = img.getPixel(x, y);
        final brightness =
            (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b);

        if (!halfTones) {
          bits.add(brightness < 128 ? 1 : 0);
          continue;
        }

        // half-tones
        bits.add(halfTonePixel(brightness.toInt(), x, y));
      }
      bitRows.add(bits);
    }

    // group into bytes

    return bitRows;
  }
}

List<int> asByteList(List<int> bits) {
  final bytes = <int>[];

  for (int i = 0; i < bits.length; i += 8) {
    int byte = 0;
    for (int j = 0; j < 8; j++) {
      if (i + j >= bits.length) continue; // avoid out of bounds
      byte |= (bits[i + j] << (7 - j));
    }
    bytes.add(byte);
  }
  return bytes;
}

clamp(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// a quick helper to convert inches to centimeters
/// useful for calculating label sizes
double inch([double value = 1]) => value * 2.54;
