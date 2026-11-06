import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPeripheral {
  static final _serviceUUID = Guid("TODO: Integration");
  static final _characteristicUUID = Guid("TODO: Integration");
  static dynamic _services;
  static dynamic _service;
  static dynamic _ch;
  static dynamic _device; 

  BluetoothPeripheral();

  // Setup Bluetooth communication with the Raspberry Pi
  static Future<bool> connectBluetooth() async {
    // Verify Bluetooth is enabled
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      print("Error: Bluetooth Not Enabled");
      return false;
    }

    // Request User permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
        statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
      print("Error: Permissions Not Granted");
      return false;
    }

    // Scan for device
    await FlutterBluePlus.startScan (
      withServices: [_serviceUUID],
      timeout: const Duration(seconds: 5),
    );

    final results = await FlutterBluePlus.scanResults.firstWhere((r) => r.isNotEmpty);
    await FlutterBluePlus.stopScan();
    if (results.isEmpty) {
      print("Error: No Matching Devices Found");
      return false;
    }

    // Connect to device
    _device = results.first.device;
    await _device.connect(license: License.nonprofit);
    _services = await _device.discoverServices();

    try {
      // call firstWhere inside try-catch to gracefully handle errors
      _service = _services.firstWhere((s) => s.uuid == _serviceUUID,
      orElse: () => throw Exception("Error: Service Not Found"),
      );

      _ch = _service.characteristics.firstWhere((c) => c.uuid == _characteristicUUID,
      orElse: () => throw Exception("Error: Characteristic Not Found"),
      );

      // Check if device is connected or not and return it's state (bool)
      return _device.isConnected();

    } catch (err) {
      print(err);
    }
    return false;
  }

  // Send data to Pi
  static Future<void> sendData(dynamic data) async {
    if (_ch.properties.write == true && _ch.properties.withoutResponse == false) {
      await _ch.write(data, withoutResponse: false);
    } else {
      print("Error: Characteristics Missing for Acknowledged Writes");
    }
    
  }

  // Get raw byte data from Bluetooth Peripheral and verify it before returning it
  // TODO: Verify Correct Information (no interference or intrusion)
  // Note: BLE includes 24-bit CRC which automatically handles corruption
  // Note: Tentative incomming data format should be three bytes (state, time byte1, time byte2)
  // This depends on the timestamp that is sent by the pi, which hasn't been implemented yet
  static Future<dynamic> receiveData() async {
    // Check proper characteristics
    if (_ch.properties.notify || _ch.properties.indicate) {
      // Listen first to catch the first notification (each emission is a List<int> type)
      _ch.onValueReceived.listen((bytes) {
        if (bytes.size != 3) {
          throw Exception("Incorrect Message Size");
        }
        dynamic state = bytes[0];
        dynamic time = (bytes[2] << 8) | bytes[1];

        // Handle incoming data from Bluetooth Peripheral
        // Verify little-endian order
        if (time > 10000) {
          throw Exception("Bytes are not in Little-Endian Order");
        }

        return {state, time};
      }, onError: (e) => print('Error: $e'));

      // Enable Notifications
      await _ch.setNotifyValue(true);
    
    } else {
      print("Error: Missing Notification Support Characteristics");
    }
  }

  static Future<void> endConnection() async {
    await _ch.setNotifyValue(false);
    if (_device != null && _device.isConnected) {
      await _device.disconnect();
    }
  }
}