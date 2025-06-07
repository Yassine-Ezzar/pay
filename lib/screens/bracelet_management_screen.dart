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
        Get.snackbar('Bluetooth', 'please_turn_bluetooth_on'.tr, backgroundColor: const Color.fromARGB(160, 244, 67, 54));
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
      Get.snackbar('scan_error'.tr, e.toString(), backgroundColor: Colors.red);
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
      Get.snackbar('error'.tr, e.toString(), backgroundColor: Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> _connectBracelet(String braceletId) async {
    try {
      await ApiService.connectBracelet(braceletId);
      Get.snackbar('success'.tr, 'bracelet_connected'.tr, backgroundColor: const Color(0xFF85C6EB));
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> _disconnectBracelet(String braceletId) async {
    try {
      await ApiService.disconnectBracelet(braceletId);
      Get.snackbar('success'.tr, 'bracelet_disconnected'.tr, backgroundColor: const Color(0xFF85C6EB));
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> _deleteBracelet(String braceletId) async {
    try {
      await ApiService.deleteBracelet(braceletId);
      Get.snackbar('success'.tr, 'bracelet_deleted'.tr, backgroundColor: const Color(0xFF85C6EB));
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(), backgroundColor: Colors.red);
    }
  }

  void _navigateToAddBracelet() {
    Get.toNamed('/bracelet-connect', arguments: {'isAddingNew': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), 
        child: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 33), 
            child: Text(
              'manage_bracelets'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF000080),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 33), 
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF000080), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          toolbarHeight: 70,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding / 2, vertical: Styles.defaultPadding / 4), 
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : bracelets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.watch_off,
                              size: 60,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(height: Styles.defaultPadding / 2),
                            Text(
                             'no_bracelets_found'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey.shade800,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: bracelets.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final bracelet = bracelets[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                            color: Colors.grey.shade100,
                            margin: EdgeInsets.symmetric(vertical: Styles.defaultPadding / 4), 
                            child: ListTile(
                              leading: Icon(
                                Icons.watch,
                                color: bracelet['connected'.tr] ? Colors.blue : Colors.grey.shade600,
                                size: 24,
                              ),
                              title: Text(
                                bracelet['name'.tr],
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'ID: ${bracelet['braceletId']}\nStatus: ${bracelet['connected'.tr] ? 'connected'.tr : 'disconnected'.tr}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      bracelet['connected'.tr]
                                          ? Icons.bluetooth_disabled
                                          : Icons.bluetooth_connected,
                                      color: bracelet['connected'.tr] ? Colors.red : Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (bracelet['connected'.tr]) {
                                        _disconnectBracelet(bracelet['braceletId']);
                                      } else {
                                        _connectBracelet(bracelet['braceletId']);
                                      }
                                    },
                                    tooltip: bracelet['connected'.tr] ? 'disconnect'.tr : 'connect'.tr,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deleteBracelet(bracelet['braceletId']),
                                    tooltip: 'delete'.tr,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30), 
        child: FloatingActionButton(
          onPressed: _navigateToAddBracelet,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, 
    );
  }
}