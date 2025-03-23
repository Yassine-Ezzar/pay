import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class BraceletManagementScreen extends StatefulWidget {
  @override
  _BraceletManagementScreenState createState() => _BraceletManagementScreenState();
}

class _BraceletManagementScreenState extends State<BraceletManagementScreen> {
  List<dynamic> bracelets = [];
  bool isLoading = true;
  String? userId;
  final _ble = FlutterReactiveBle();
  List<DiscoveredDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initBle();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    } else {
      _fetchBracelets();
    }
  }

  Future<void> _initBle() async {
    _ble.statusStream.listen((status) {
      if (status != BleStatus.ready) {
        Get.snackbar('Bluetooth Error', 'Please enable Bluetooth', backgroundColor: Styles.defaultRedColor);
      }
    });
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
      Get.snackbar('Scan Error', e.toString(), backgroundColor: Styles.defaultRedColor);
      setState(() => _isScanning = false);
    });

    Future.delayed(const Duration(seconds: 10), () {
      setState(() => _isScanning = false);
    });
  }

  Future<void> _fetchBracelets() async {
    setState(() => isLoading = true);
    try {
      final fetchedBracelets = await ApiService.getBracelets(userId!);
      setState(() {
        bracelets = fetchedBracelets;
        isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
      setState(() => isLoading = false);
    }
  }

  Future<void> _connectBracelet(String braceletId) async {
    try {
      await ApiService.connectBracelet(braceletId);
      Get.snackbar('Success', 'Bracelet connected', backgroundColor: Styles.defaultBlueColor);
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  Future<void> _disconnectBracelet(String braceletId) async {
    try {
      await ApiService.disconnectBracelet(braceletId);
      Get.snackbar('Success', 'Bracelet disconnected', backgroundColor: Styles.defaultBlueColor);
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  Future<void> _deleteBracelet(String braceletId) async {
    try {
      await ApiService.deleteBracelet(braceletId);
      Get.snackbar('Success', 'Bracelet deleted', backgroundColor: Styles.defaultBlueColor);
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  void _navigateToAddBracelet() {
    Get.toNamed('/bracelet-connect', arguments: {'isAddingNew': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bracelets', style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Styles.defaultPadding),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
                : bracelets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.watch_off,
                              size: 80,
                              color: Styles.defaultLightWhiteColor,
                            ),
                            SizedBox(height: Styles.defaultPadding),
                            Text(
                              'No bracelets found.\nTap the + button to connect a new bracelet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                color: Styles.defaultLightWhiteColor,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: bracelets.length,
                        itemBuilder: (context, index) {
                          final bracelet = bracelets[index];
                          return Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                            color: Colors.white.withOpacity(0.1),
                            child: ListTile(
                              leading: Icon(
                                Icons.watch,
                                color: bracelet['connected']
                                    ? Styles.defaultBlueColor
                                    : Styles.defaultLightGreyColor,
                                size: 30,
                              ),
                              title: Text(
                                bracelet['name'],
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  color: Styles.defaultYellowColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'ID: ${bracelet['braceletId']}\nStatus: ${bracelet['connected'] ? 'Connected' : 'Disconnected'}',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  color: Styles.defaultLightWhiteColor,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      bracelet['connected']
                                          ? Icons.bluetooth_disabled
                                          : Icons.bluetooth_connected,
                                      color: bracelet['connected']
                                          ? Styles.defaultRedColor
                                          : Styles.defaultBlueColor,
                                    ),
                                    onPressed: () {
                                      if (bracelet['connected']) {
                                        _disconnectBracelet(bracelet['braceletId']);
                                      } else {
                                        _connectBracelet(bracelet['braceletId']);
                                      }
                                    },
                                    tooltip: bracelet['connected'] ? 'Disconnect' : 'Connect',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Styles.defaultRedColor),
                                    onPressed: () => _deleteBracelet(bracelet['braceletId']),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBracelet,
        backgroundColor: Styles.defaultBlueColor,
        child: Icon(Icons.add, color: Styles.defaultYellowColor),
      ),
    );
  }
}