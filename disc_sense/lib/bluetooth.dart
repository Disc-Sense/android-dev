import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPeripheral {
  static final _serviceUUID = Guid("TODO: Integration");
  static final _characteristicUUID = Guid("TODO: Integration");
  static dynamic _services;
  static dynamic _service;
  static dynamic _ch;
  static dynamic _device; 

  BluetoothPeripheral();

  // Setup Bluetooth communication with the Raspberry Pi
  static Future<dynamic> connectBluetooth() async {
    // TODO: Check if Bluetooth is turned on
    // TODO: Check if user granted permissions
    // TODO: Check if device disconnects

    // Scan for device
    await FlutterBluePlus.startScan (
      withServices: [_serviceUUID],
      timeout: const Duration(seconds: 5),
    );

    final results = await FlutterBluePlus.scanResults.firstWhere((r) => r.isNotEmpty);
    await FlutterBluePlus.stopScan();
    _device = results.first.device;

    // Connect to device
    await _device.connect(license: License.nonprofit);
    _services = await _device.discoverServices();
    _service = _services.firstWhere((s) => s.uuid == _ch);
    _ch = _service.characteristics.firstWhere((c) => c.uuid == _characteristicUUID);

    return _device.isConnected();
  }

  // Send data to Pi
  static Future<void> sendData(dynamic data) async {
    await _ch.write(data, withoutResponse: false);
  }

  // Get data from Pi and put it in a buffer
  static Future<dynamic> receiveData() async {
    // Subscribe to get data from Pi
    await _ch.setNotifyValue(true);
    _ch.onValueReceived.listen((value) {
      // Handle incoming data from Pi
      return value;
    });
  }

  static Future<void> endConnection() async {
    await _device.disconnect();
  }
}