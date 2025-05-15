import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothConnection? connection;
  String receivedData = "";
  bool isConnecting = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }

    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
  }

  void connectToBluetooth() async {
    try {
      setState(() {
        isConnecting = true;
      });

      // Check if Bluetooth is enabled
      final isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (!isEnabled!) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }

      // Get bonded devices
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      if (devices.isEmpty) {
        setState(() {
          isConnecting = false;
        });
        showErrorDialog(
            "No bonded devices found. Please pair your device first.");
        return;
      }

      // Find the target device
      final targetDevice = devices.firstWhere(
        (device) => device.name == "HC-05",
        orElse: () {
          setState(() {
            isConnecting = false;
          });
          throw Exception("Device HC-05 not found");
        },
      );

      // Attempt connection
      BluetoothConnection.toAddress(targetDevice.address).then((_connection) {
        print('Connected to the device');
        setState(() {
          connection = _connection;
          isConnected = true;
          isConnecting = false;
        });

        // Listen for data
        connection!.input?.listen((data) {
          print('Raw data: $data');
          setState(() {
            receivedData = String.fromCharCodes(data).trim();
            print(receivedData);
          });
        })?.onDone(() {
          print('Disconnected');
          setState(() {
            isConnected = false;
          });
        });
      }).catchError((error) {
        print('Connection error: $error');
        setState(() {
          isConnecting = false;
        });
        showErrorDialog("Failed to connect to the device.");
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isConnecting = false;
      });
      showErrorDialog(e.toString());
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    connection?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Plug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Everything you need about your electricity connection 🔌\nis between your hands 🤳',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 200),
                Container(
                  padding: const EdgeInsets.all(46),
                  decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    receivedData.isNotEmpty
                        ? 'Received Data: $receivedData'
                        : 'No data received yet',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 200),
                ElevatedButton.icon(
                  icon: const Icon(color: Colors.blue, Icons.bluetooth),
                  onPressed:
                      isConnecting || isConnected ? null : connectToBluetooth,
                  label: isConnecting
                      ? const CircularProgressIndicator(color: Colors.blue)
                      : Text(
                          style: TextStyle(
                            color: Colors.blue[800],
                          ),
                          isConnected
                              ? 'Connected'
                              : 'Connect Your Smart Plug'),
                ),
                const SizedBox(height: 20),
                if (isConnected)
                  ElevatedButton(
                    onPressed: () {
                      connection?.finish();
                      setState(() {
                        isConnected = false;
                        receivedData = "";
                      });
                    },
                    child: const Text('Disconnect'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
