import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'model/m_printer_model.dart';
import 'model/m_thermal_printer.dart';

class BluetoothPrintersService {
  final List<PrinterModel> printers;

  Map<String, ThermalPrinter> _connectedPrinters = {};
  final StreamController<List<ThermalPrinter>> _connected =
      StreamController<List<ThermalPrinter>>.broadcast();

  Stream<List<ThermalPrinter>> get connectedPrinters => _connected.stream;

  /// [printers] printers that you want to look for.
  BluetoothPrintersService({required this.printers}) {
    FlutterBluePlus.setOptions(restoreState: true);
  }

  void discover() async {
    StreamSubscription? subscription;

    await _reconnectFromSystem();

    subscription = FlutterBluePlus.scanResults.listen(
      (res) => _onDevicesVisible(res.map((r) => r.device).toList()),
    );
    FlutterBluePlus.cancelWhenScanComplete(subscription);
    FlutterBluePlus.startScan(
      timeout: const Duration(minutes: 2),
      withNames: printers.map((e) => e.deviceName).toList(),
      withServices: _printerServices,

      continuousUpdates: true,
      androidScanMode: AndroidScanMode.balanced,
    );
  }

  void stopDiscover() {
    _setConnected([]);
    FlutterBluePlus.stopScan();
  }

  Future<void> disconnectAll() async {
    _setConnected([]);
    for (final printer in FlutterBluePlus.connectedDevices) {
      try {
        await printer.disconnect();
      } catch (e) {
        print("Failed to disconnect from ${printer.platformName}: $e");
      }
    }
  }

  dispose() {
    disconnectAll();
    FlutterBluePlus.stopScan();
    _connected.close();
  }

  List<Guid> get _printerServices =>
      printers
          .map((e) => Guid.fromString(e.bleConfig.sendServiceUuid))
          .toList();

  Future<void> _reconnectFromSystem() async {
    try {
      final devices = await FlutterBluePlus.systemDevices(_printerServices);
      _onDevicesVisible(devices);
    } catch (e) {
      print("Failed to reconnect from system: $e");
    }
  }

  Future<void> _send(BluetoothCharacteristic char, List<int> data) async {
    if (data.isEmpty) return;
    try {
      await char.write(data);
    } catch (e) {
      throw Exception("Failed to send data to ${char.device.platformName}");
    }
  }

  Future<List<BluetoothCharacteristic>> _getChars(
    BluetoothDevice device,
  ) async {
    final services = await device.discoverServices(timeout: 100);
    if (services.isEmpty) {
      throw Exception("No services found for device: ${device.name}");
    }
    final List<BluetoothCharacteristic> characteristics = [];
    for (var service in services) {
      characteristics.addAll(service.characteristics);
    }
    return characteristics;
  }

  void _setConnected(List<ThermalPrinter> printers) {
    _connectedPrinters = {
      for (final printer in printers) printer.deviceId: printer,
    };
    _connected.add(printers);
  }

  Future<void> _onDevicesVisible(List<BluetoothDevice> devices) async {
    List<ThermalPrinter> connected = [];
    for (final device in devices) {
      final id = device.remoteId.toString();
      if (device.platformName.isEmpty) continue;

      if (device.isConnected && _connectedPrinters[id] != null) {
        // Printer is already connected
        connected.add(_connectedPrinters[id]!);
        continue;
      }
      if (!device.isConnected) {
        try {
          await device.connect();
        } catch (e) {
          continue; // Skip if connection fails
        }
      }
      final printer = await _mapConnected(device);
      if (printer != null) connected.add(printer);
    }
    _setConnected(connected);
  }

  Future<ThermalPrinter?> _mapConnected(BluetoothDevice device) async {
    final id = device.remoteId.toString();

    final model = printers.firstWhereOrNull(
      (p) => p.deviceName == device.platformName,
    );

    if (model == null) return null;

    final chars = await _getChars(device);
    final writeChar = chars.reversed.firstWhereOrNull(
      (c) => c.properties.write,
    );
    if (writeChar == null) return null;
    return ThermalPrinter(
      deviceId: id,
      model: model,
      send: (data) => _send(writeChar, data),
    );
  }
}
