import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';

class BraceletConnectScreen extends StatefulWidget {
  @override
  _BraceletConnectScreenState createState() => _BraceletConnectScreenState();
}

class _BraceletConnectScreenState extends State<BraceletConnectScreen> with SingleTickerProviderStateMixin {
  final _ble = FlutterReactiveBle();
  List<DiscoveredDevice> _devices = [];
  DiscoveredDevice? _selectedDevice;
  bool _isScanning = false;
  bool _isConnecting = false;
  String? userId;
  late AnimationController _animationController;
  late Animation<double> _braceletAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _braceletAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserId();
    _requestPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted) {
      _startScan();
    } else {
      Get.snackbar(
        'Error',
        'Bluetooth permissions are required to connect to your bracelet.',
        backgroundColor: Styles.defaultRedColor,
        colorText: Styles.defaultYellowColor,
      );
    }
  }

  void _startScan() {
    setState(() => _isScanning = true);
    _devices.clear();

    _ble.scanForDevices(withServices: []).listen((device) {
      if (!_devices.any((d) => d.id == device.id)) {
        setState(() {
          _devices.add(device);
        });
      }
    }, onError: (e) {
      Get.snackbar('Error', 'Failed to scan for devices: $e', backgroundColor: Styles.defaultRedColor);
      setState(() => _isScanning = false);
    });

    Future.delayed(const Duration(seconds: 10), () {
      setState(() => _isScanning = false);
    });
  }

  Future<void> _connectToBracelet() async {
    if (_selectedDevice == null) {
      Get.snackbar('Error', 'Please select a bracelet', backgroundColor: Styles.defaultRedColor);
      return;
    }

    setState(() => _isConnecting = true);
    try {
      await _ble
          .connectToDevice(id: _selectedDevice!.id)
          .firstWhere((state) => state.connectionState == DeviceConnectionState.connected);

      await ApiService.addBracelet(userId!, _selectedDevice!.id, _selectedDevice!.name ?? 'My Bracelet');
      await ApiService.connectBracelet(_selectedDevice!.id);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Styles.defaultPadding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Styles.defaultPadding),
                  FadeInDown(
                    child: Text(
                      'Connect Your Bracelet',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Styles.defaultYellowColor,
                        shadows: [
                          const Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding * 2),
                  FadeIn(
                    child: AnimatedBuilder(
                      animation: _braceletAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _braceletAnimation.value,
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[800]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  offset: const Offset(0, 6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.watch,
                                  size: 90,
                                  color: Styles.defaultYellowColor.withOpacity(0.9),
                                ),
                                Positioned(
                                  top: 20,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isConnecting ? Colors.green : Colors.grey,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.bluetooth,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding * 2),
                  // Steps card
                  FadeInUp(
                    child: Container(
                      padding: EdgeInsets.all(Styles.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'How to Connect',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Styles.defaultYellowColor,
                            ),
                          ),
                          SizedBox(height: Styles.defaultPadding / 2),
                          Text(
                            'Step 1: Ensure Bluetooth is enabled\nStep 2: Scan for your bracelet\nStep 3: Select and connect',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 16,
                              color: Styles.defaultLightWhiteColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding * 2),
                  // Scan button with shimmer effect
                  FadeInUp(
                    child: _isScanning
                        ? Shimmer.fromColors(
                            baseColor: Styles.defaultBlueColor,
                            highlightColor: Styles.defaultYellowColor,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                              decoration: BoxDecoration(
                                borderRadius: Styles.defaultBorderRadius,
                                color: Styles.defaultBlueColor,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Styles.defaultYellowColor,
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Scanning...',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 16,
                                      color: Styles.defaultYellowColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _startScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Styles.defaultBlueColor, Styles.defaultRedColor],
                                ),
                                borderRadius: Styles.defaultBorderRadius,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                              child: Text(
                                'Scan for Bracelets',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 16,
                                  color: Styles.defaultYellowColor,
                                ),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  FadeInUp(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Styles.defaultGreyColor.withOpacity(0.3),
                        borderRadius: Styles.defaultBorderRadius,
                        border: Border.all(color: Styles.defaultYellowColor.withOpacity(0.3)),
                      ),
                      child: DropdownButton<DiscoveredDevice>(
                        hint: Text(
                          'Select a Bracelet',
                          style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultLightWhiteColor),
                        ),
                        value: _selectedDevice,
                        items: _devices.map((device) {
                          return DropdownMenuItem<DiscoveredDevice>(
                            value: device,
                            child: Text(
                              device.name?.isNotEmpty == true ? device.name! : 'Unknown Device (${device.id})',
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
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(Icons.arrow_drop_down, color: Styles.defaultYellowColor),
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding * 2),
                  FadeInUp(
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _connectToBracelet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Styles.defaultBlueColor, Styles.defaultRedColor],
                          ),
                          borderRadius: Styles.defaultBorderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        child: _isConnecting
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Styles.defaultYellowColor,
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Connecting...',
                                    style: TextStyle(fontFamily: 'Rubik', fontSize: 16, color: Styles.defaultYellowColor),
                                  ),
                                ],
                              )
                            : Text(
                                'Connect',
                                style: TextStyle(fontFamily: 'Rubik', fontSize: 16, color: Styles.defaultYellowColor),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  FadeInUp(
                    child: TextButton(
                      onPressed: () => Get.offNamed('/home'),
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14,
                          color: Styles.defaultLightWhiteColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}