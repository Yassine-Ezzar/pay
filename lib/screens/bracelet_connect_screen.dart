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
        colorText: Colors.black,
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
      Get.snackbar('Error', 'Failed to scan for devices: $e', backgroundColor: Color.fromRGBO(0, 102, 255, 0.362));
      setState(() => _isScanning = false);
    });

    Future.delayed(const Duration(seconds: 10), () {
      setState(() => _isScanning = false);
    });
  }

  Future<void> _connectToBracelet() async {
    if (_selectedDevice == null) {
      Get.snackbar('Error', 'Please select a bracelet', backgroundColor:Color.fromRGBO(0, 102, 255, 0.362));
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
          color: Colors.white, // Background already set to white
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
                    child: const Text(
                      'Connect Your Bracelet',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF063B87), // Major title color updated to #063b87
                        shadows: [
                          Shadow(
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
                                const Icon(
                                  Icons.watch,
                                  size: 90,
                                  color: Colors.white,
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
                 
                  FadeInUp(
                    child: Container(
                      padding: EdgeInsets.all(Styles.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'How to Connect',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF063B87), 
                            ),
                          ),
                          SizedBox(height: Styles.defaultPadding / 2),
                          const Text(
                            'Step 1: Ensure Bluetooth is enabled\nStep 2: Scan for your bracelet\nStep 3: Select and connect',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.black, 
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding * 2),
                  FadeInUp(
                    child: _isScanning
                        ? Shimmer.fromColors(
                            baseColor: const Color(0xFF0066FF), 
                            highlightColor: Colors.white,
                            child: Container(
                              width: 363,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xFF0066FF), 
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Scanning...',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.white, 
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 363,
                            height: 68,
                            child: ElevatedButton(
                              onPressed: _startScan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066FF), 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), 
                                ),
                              ),
                              child: const Text(
                                'Search for Bracelets',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white, 
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
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: DropdownButton<DiscoveredDevice>(
                        hint: const Text(
                          'Select a Bracelet',
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.black), // Dropdown hint in black
                        ),
                        value: _selectedDevice,
                        items: _devices.map((device) {
                          return DropdownMenuItem<DiscoveredDevice>(
                            value: device,
                            child: Text(
                              device.name?.isNotEmpty == true ? device.name! : 'Unknown Device (${device.id})',
                              style: const TextStyle(fontFamily: 'Poppins', color: Colors.black), // Dropdown items in black
                            ),
                          );
                        }).toList(),
                        onChanged: (device) {
                          setState(() {
                            _selectedDevice = device;
                          });
                        },
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Icon in black
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding * 2),
                  FadeInUp(
                    child: SizedBox(
                      width: 363,
                      height: 68,
                      child: ElevatedButton(
                        onPressed: _isConnecting ? null : _connectToBracelet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF), // Updated to #0066FF
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Radius 15
                          ),
                        ),
                        child: _isConnecting
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Connecting...',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.white, // Button text in white
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Connect',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white, // Button text in white
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  FadeInUp(
                    child: TextButton(
                      onPressed: () => Get.offNamed('/home'),
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black, // Other text in black
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