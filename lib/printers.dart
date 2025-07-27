import 'model/m_printer_model.dart';

/// a list of presets for Phomemo printers.
///
/// If you own another printer, you can add it via the `PrinterModel.phomemo` constructor.
/// otherwise, feel free to reach out to me and I will add it to the package.
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
