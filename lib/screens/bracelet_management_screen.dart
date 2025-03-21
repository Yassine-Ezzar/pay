import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    } else {
      _fetchBracelets();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bracelet', style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor)),
        backgroundColor: Styles.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
            : bracelets.isEmpty
                ? Center(
                    child: Text(
                      'No bracelets found.\nConnect a new bracelet to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultLightWhiteColor,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: bracelets.length,
                    itemBuilder: (context, index) {
                      final bracelet = bracelets[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                        color: Styles.defaultGreyColor,
                        child: ListTile(
                          title: Text(
                            bracelet['name'],
                            style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                          ),
                          subtitle: Text(
                            'ID: ${bracelet['braceletId']}\nStatus: ${bracelet['connected'] ? 'Connected' : 'Disconnected'}',
                            style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultLightWhiteColor),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  bracelet['connected'] ? Icons.bluetooth_disabled : Icons.bluetooth_connected,
                                  color: Styles.defaultYellowColor,
                                ),
                                onPressed: () {
                                  if (bracelet['connected']) {
                                    _disconnectBracelet(bracelet['braceletId']);
                                  } else {
                                    _connectBracelet(bracelet['braceletId']);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Styles.defaultRedColor),
                                onPressed: () => _deleteBracelet(bracelet['braceletId']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}