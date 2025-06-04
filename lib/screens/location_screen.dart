import 'package:app/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int _selectedIndex = 1;
  GoogleMapController? _mapController;
  List<dynamic> bracelets = [];
  String? selectedBraceletId;
  LatLng? braceletLocation;
  LatLng? userLocation;
  String? braceletAddress;
  double? distanceToBracelet;
  bool isLoadingBracelets = true;
  bool isLoadingLocation = false;
  bool isLoadingUserLocation = false;
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
      _getUserLocation();
    }
  }

  Future<void> _fetchBracelets() async {
    setState(() => isLoadingBracelets = true);
    try {
      final fetchedBracelets = await ApiService.getBracelets(userId!);
      setState(() {
        bracelets = fetchedBracelets;
        if (bracelets.isNotEmpty) {
          selectedBraceletId = bracelets[0]['braceletId'];
          _fetchBraceletLocation();
        }
        isLoadingBracelets = false;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent.withOpacity(0.8));
      setState(() => isLoadingBracelets = false);
    }
  }

  Future<void> _getUserLocation() async {
    setState(() => isLoadingUserLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLoadingUserLocation = false;
        if (_mapController != null && userLocation != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(userLocation!),
          );
        }
        _calculateDistance();
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent.withOpacity(0.8));
      setState(() => isLoadingUserLocation = false);
    }
  }

  Future<void> _fetchBraceletLocation() async {
    if (selectedBraceletId == null) return;

    setState(() => isLoadingLocation = true);
    try {
      final locationData = await ApiService.getBraceletLocation(selectedBraceletId!);
      setState(() {
        braceletLocation = LatLng(
          locationData['latitude'],
          locationData['longitude'],
        );
        _getBraceletAddress();
        _calculateDistance();
        if (_mapController != null && braceletLocation != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  userLocation!.latitude < braceletLocation!.latitude
                      ? userLocation!.latitude
                      : braceletLocation!.latitude,
                  userLocation!.longitude < braceletLocation!.longitude
                      ? userLocation!.longitude
                      : braceletLocation!.longitude,
                ),
                northeast: LatLng(
                  userLocation!.latitude > braceletLocation!.latitude
                      ? userLocation!.latitude
                      : braceletLocation!.latitude,
                  userLocation!.longitude > braceletLocation!.longitude
                      ? userLocation!.longitude
                      : braceletLocation!.longitude,
                ),
              ),
              50,
            ),
          );
        }
        isLoadingLocation = false;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent.withOpacity(0.8));
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> _getBraceletAddress() async {
    if (braceletLocation == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        braceletLocation!.latitude,
        braceletLocation!.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        braceletAddress =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      setState(() {
        braceletAddress = 'Address not available';
      });
    }
  }

  void _calculateDistance() {
    if (userLocation == null || braceletLocation == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      braceletLocation!.latitude,
      braceletLocation!.longitude,
    );

    setState(() {
      distanceToBracelet = distanceInMeters / 1000;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/location');
        break;
      case 2:
        Get.offNamed('/card-list');
        break;
      case 3:
        Get.offNamed('/profile');
        break;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (userLocation != null && braceletLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              userLocation!.latitude < braceletLocation!.latitude
                  ? userLocation!.latitude
                  : braceletLocation!.latitude,
              userLocation!.longitude < braceletLocation!.longitude
                  ? userLocation!.longitude
                  : braceletLocation!.longitude,
            ),
            northeast: LatLng(
              userLocation!.latitude > braceletLocation!.latitude
                  ? userLocation!.latitude
                  : braceletLocation!.latitude,
              userLocation!.longitude > braceletLocation!.longitude
                  ? userLocation!.longitude
                  : braceletLocation!.longitude,
            ),
          ),
          50,
        ),
      );
    } else if (userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(userLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Styles.defaultPadding,
                            vertical: Styles.defaultPadding / 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'locate_bracelet'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: selectedBraceletId,
                                  hint: Text(
                                   'select_bracelet'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  items: bracelets.map<DropdownMenuItem<String>>((bracelet) {
                                    return DropdownMenuItem<String>(
                                      value: bracelet['braceletId'],
                                      child: Text(
                                        bracelet['name'],
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBraceletId = value;
                                      _fetchBraceletLocation();
                                    });
                                  },
                                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  iconEnabledColor: Theme.of(context).iconTheme.color,
                                  isExpanded: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
                                onPressed: _fetchBraceletLocation,
                              ),
                            ],
                          ),
                        ),
                        if (braceletLocation != null && braceletAddress != null) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Styles.defaultPadding,
                              vertical: Styles.defaultPadding / 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'bracelet_location'.tr + ' $braceletAddress',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: 14,
                                  ),
                                ),
                                if (distanceToBracelet != null)
                                  Text(
                                   'distance'.tr + ' ${distanceToBracelet!.toStringAsFixed(2)} km'  ,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        Expanded(
                          child: isLoadingBracelets || isLoadingUserLocation
                              ? Center(child: CircularProgressIndicator(color: Theme.of(context).iconTheme.color))
                              : bracelets.isEmpty
                                  ? Center(
                                      child: Text(
                                        'no_bracelets_found'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : isLoadingLocation
                                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).iconTheme.color))
                                      : userLocation == null
                                          ? Center(
                                              child: Text(
                                                'unable_fetch_location'.tr,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                          : GoogleMap(
                                              onMapCreated: _onMapCreated,
                                              initialCameraPosition: CameraPosition(
                                                target: userLocation!,
                                                zoom: 15,
                                              ),
                                              markers: {
                                                Marker(
                                                  markerId: const MarkerId('user'),
                                                  position: userLocation!,
                                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                                    BitmapDescriptor.hueBlue,
                                                  ),
                                                  infoWindow: const InfoWindow(
                                                    title: 'Your Location',
                                                  ),
                                                ),
                                                if (braceletLocation != null)
                                                  Marker(
                                                    markerId: const MarkerId('bracelet'),
                                                    position: braceletLocation!,
                                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                                      BitmapDescriptor.hueRed,
                                                    ),
                                                    infoWindow: InfoWindow(
                                                      title: 'Your Bracelet',
                                                      snippet: braceletAddress ?? 'Last known location',
                                                    ),
                                                  ),
                                              },
                                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
          CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onNavItemTapped,
          ),
        ],
      ),
    );
  }
}