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
        Get.snackbar('Bluetooth', 'Please Turn Bluetooth On', backgroundColor: const Color.fromARGB(160, 244, 67, 54));
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
      Get.snackbar('Scan Error', e.toString(), backgroundColor: Colors.red);
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
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> _connectBracelet(String braceletId) async {
    try {
      await ApiService.connectBracelet(braceletId);
      Get.snackbar('Success', 'Bracelet connected', backgroundColor: const Color(0xFF85C6EB));
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> _disconnectBracelet(String braceletId) async {
    try {
      await ApiService.disconnectBracelet(braceletId);
      Get.snackbar('Success', 'Bracelet disconnected', backgroundColor: const Color(0xFF85C6EB));
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> _deleteBracelet(String braceletId) async {
    try {
      await ApiService.deleteBracelet(braceletId);
      Get.snackbar('Success', 'Bracelet deleted', backgroundColor: const Color(0xFF85C6EB));
      _fetchBracelets();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
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
        preferredSize: Size.fromHeight(70), 
        child: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 33), 
            child: Text(
              'Manage Bracelets',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: const Color(0xFF000080),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(top: 33), 
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: const Color(0xFF000080), size: 20),
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
                ? Center(child: CircularProgressIndicator(color: Colors.blue))
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
                              'No bracelets found.\nTap the + button to connect a new bracelet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Rubik',
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
                                color: bracelet['connected'] ? Colors.blue : Colors.grey.shade600,
                                size: 24,
                              ),
                              title: Text(
                                bracelet['name'],
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'ID: ${bracelet['braceletId']}\nStatus: ${bracelet['connected'] ? 'Connected' : 'Disconnected'}',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
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
                                      color: bracelet['connected'] ? Colors.red : Colors.blue,
                                      size: 20,
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
                                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30), 
        child: FloatingActionButton(
          onPressed: _navigateToAddBracelet,
          backgroundColor: Colors.blue,
          child: Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, 
    );
  }
}