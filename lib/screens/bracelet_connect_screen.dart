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
        'error'.tr,
        'bluetooth_permissions_required'.tr,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultRedColor
            : Styles.defaultRedColor,
        colorText: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultLightWhiteColor
            : Colors.black,
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
      Get.snackbar(
       'error'.tr,
        'failed_scan_devices'.tr + e.toString(),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultRedColor
            : Styles.defaultRedColor,
        colorText: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultLightWhiteColor
            : Colors.black,
      );
      setState(() => _isScanning = false);
    });

    Future.delayed(const Duration(seconds: 10), () {
      setState(() => _isScanning = false);
    });
  }

  Future<void> _connectToBracelet() async {
    if (_selectedDevice == null) {
      Get.snackbar(
        'error'.tr,
        'select_bracelet'.tr,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultRedColor
            : Styles.defaultRedColor,
        colorText: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultLightWhiteColor
            : Colors.black,
      );
      return;
    }

    setState(() => _isConnecting = true);
    try {
      await _ble
          .connectToDevice(id: _selectedDevice!.id)
          .firstWhere((state) => state.connectionState == DeviceConnectionState.connected);

      await ApiService.addBracelet(userId!, _selectedDevice!.id, _selectedDevice!.name ?? 'My Bracelet');
      await ApiService.connectBracelet(_selectedDevice!.id);
      Get.snackbar(
        'success'.tr,
        'bracelet_connected'.tr,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultBlueColor
            : Styles.defaultBlueColor,
        colorText: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultLightWhiteColor
            : Colors.white,
      );
      Get.offNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultRedColor
            : Styles.defaultRedColor,
        colorText: Theme.of(context).brightness == Brightness.dark
            ? Styles.darkDefaultLightWhiteColor
            : Colors.black,
      );
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                      'connect_bracelet'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black45,
                            offset: const Offset(2, 2),
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
                                colors: [
                                  Theme.of(context).brightness == Brightness.dark
                                      ? Colors.blue[300]!
                                      : Colors.blue[400]!,
                                  Theme.of(context).brightness == Brightness.dark
                                      ? Colors.blue[700]!
                                      : Colors.blue[800]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.blue[300]!.withOpacity(0.3)
                                      : Colors.blueAccent.withOpacity(0.5),
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
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Styles.darkDefaultLightWhiteColor
                                      : Colors.white,
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
                                    child: Center(
                                      child: Icon(
                                        Icons.bluetooth,
                                        size: 12,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Styles.darkDefaultLightWhiteColor
                                            : Colors.white,
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Styles.darkDefaultLightGreyColor.withOpacity(0.1)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black54
                                : Colors.black26,
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                           'how_to_connect'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          SizedBox(height: Styles.defaultPadding / 2),
                          Text(
                            'step_1'.tr + '\n' + 'step_2'.tr + '\n' + 'step_3'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                            baseColor: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultBlueColor
                                : Styles.defaultBlueColor,
                            highlightColor: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightWhiteColor
                                : Colors.white,
                            child: Container(
                              width: 363,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Styles.darkDefaultBlueColor
                                    : Styles.defaultBlueColor,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Styles.darkDefaultLightWhiteColor
                                        : Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'scanning'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Styles.darkDefaultLightWhiteColor
                                          : Colors.white,
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
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? Styles.darkDefaultBlueColor
                                    : Styles.defaultBlueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'search_bracelets'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Styles.darkDefaultLightWhiteColor
                                      : Colors.white,
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Styles.darkDefaultLightGreyColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Styles.darkDefaultGreyColor.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButton<DiscoveredDevice>(
                        hint: Text(
                         'select_bracelet'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        value: _selectedDevice,
                        items: _devices.map((device) {
                          return DropdownMenuItem<DiscoveredDevice>(
                            value: device,
                            child: Text(
                              device.name?.isNotEmpty == true
                                  ? device.name!
                                  : 'unknown_device'.tr + ' (${device.id})',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (device) {
                          setState(() {
                            _selectedDevice = device;
                          });
                        },
                        dropdownColor: Theme.of(context).brightness == Brightness.dark
                            ? Styles.darkScaffoldBackgroundColor
                            : Colors.white,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
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
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Styles.darkDefaultBlueColor
                              : Styles.defaultBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isConnecting
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Styles.darkDefaultLightWhiteColor
                                        : Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                  'connecting'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Styles.darkDefaultLightWhiteColor
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                               'connect'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Styles.darkDefaultLightWhiteColor
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  FadeInUp(
                    child: TextButton(
                      onPressed: () => Get.offNamed('/home'),
                      child: Text(
                       'skip_for_now'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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