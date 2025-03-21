import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class BraceletConnectScreen extends StatefulWidget {
  @override
  _BraceletConnectScreenState createState() => _BraceletConnectScreenState();
}

class _BraceletConnectScreenState extends State<BraceletConnectScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initBluetooth();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    }
  }

  Future<void> _initBluetooth() async {
    // Check Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState != BluetoothState.STATE_ON) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    // Listen for state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Discover devices
    FlutterBluetoothSerial.instance.getBondedDevices().then((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }

  Future<void> _connectToBracelet() async {
    if (_selectedDevice == null) {
      Get.snackbar('Error', 'Please select a bracelet', backgroundColor: Styles.defaultRedColor);
      return;
    }

    setState(() => _isConnecting = true);
    try {
      // Simulate adding a bracelet to the backend
      await ApiService.addBracelet(userId!, _selectedDevice!.address, _selectedDevice!.name ?? 'My Bracelet');
      await ApiService.connectBracelet(_selectedDevice!.address);
      Get.snackbar('Success', 'Bracelet connected successfully', backgroundColor: Styles.defaultBlueColor);
      Get.offNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Connect Your Bracelet',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Styles.defaultYellowColor,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              // Bracelet illustration (simulated)
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue[300]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.watch,
                    size: 80,
                    color: Styles.defaultYellowColor,
                  ),
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Text(
                'Step 1: Turn on Bluetooth\nStep 2: Select your bracelet\nStep 3: Press Connect',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 16,
                  color: Styles.defaultLightWhiteColor,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              if (_bluetoothState != BluetoothState.STATE_ON)
                ElevatedButton(
                  onPressed: () async {
                    await FlutterBluetoothSerial.instance.requestEnable();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.defaultBlueColor,
                    foregroundColor: Styles.defaultYellowColor,
                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                  ),
                  child: Text('Enable Bluetooth', style: TextStyle(fontFamily: 'Rubik')),
                ),
              SizedBox(height: Styles.defaultPadding),
              DropdownButton<BluetoothDevice>(
                hint: Text(
                  'Select a Bracelet',
                  style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultLightWhiteColor),
                ),
                value: _selectedDevice,
                items: _devices.map((device) {
                  return DropdownMenuItem<BluetoothDevice>(
                    value: device,
                    child: Text(
                      device.name ?? 'Unknown Device',
                      style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                    ),
                  );
                }).toList(),
                onChanged: (device) {
                  setState(() {
                    _selectedDevice = device;
                  });
                },
                dropdownColor: Styles.defaultGreyColor,
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              ElevatedButton(
                onPressed: _isConnecting ? null : _connectToBracelet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.defaultBlueColor,
                  foregroundColor: Styles.defaultYellowColor,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                ),
                child: _isConnecting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Styles.defaultYellowColor,
                            strokeWidth: 2,
                          ),
                          SizedBox(width: 10),
                          Text('Connecting...', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
                        ],
                      )
                    : Text('Connect', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}