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
  double? distanceToBracelet; // Distance in kilometers
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
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
      setState(() => isLoadingBracelets = false);
    }
  }

  Future<void> _getUserLocation() async {
    setState(() => isLoadingUserLocation = true);
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
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

      // Get the current position
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
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
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
              50, // Padding
            ),
          );
        }
        isLoadingLocation = false;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
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
      distanceToBracelet = distanceInMeters / 1000; // Convert to kilometers
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
        Get.offNamed('/notifications');
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
          50, // Padding
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
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFF0A0E21),
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
                              const Text(
                                'Locate Your Bracelet',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
                                  hint: const Text(
                                    'Select a Bracelet',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white70,
                                    ),
                                  ),
                                  items: bracelets.map<DropdownMenuItem<String>>((bracelet) {
                                    return DropdownMenuItem<String>(
                                      value: bracelet['braceletId'],
                                      child: Text(
                                        bracelet['name'],
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
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
                                  dropdownColor: const Color(0xFF1E2A44),
                                  style: const TextStyle(color: Colors.white),
                                  iconEnabledColor: Colors.white,
                                  isExpanded: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
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
                                  'Bracelet Location: $braceletAddress',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                if (distanceToBracelet != null)
                                  Text(
                                    'Distance: ${distanceToBracelet!.toStringAsFixed(2)} km',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        Expanded(
                          child: isLoadingBracelets || isLoadingUserLocation
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : bracelets.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No bracelets found.\nPlease connect a bracelet first.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : isLoadingLocation
                                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                      : userLocation == null
                                          ? const Center(
                                              child: Text(
                                                'Unable to fetch your location.',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white70,
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