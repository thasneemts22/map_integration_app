import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RadiusSelectorScreen extends StatefulWidget {
  const RadiusSelectorScreen({super.key});

  @override
  State<RadiusSelectorScreen> createState() => _RadiusSelectorScreenState();
}

class _RadiusSelectorScreenState extends State<RadiusSelectorScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  double _radius = 5;
  int _propertyCount = 0;
  final List<double> radiusOptions = [1, 3, 5, 10, 15];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Marker? _searchedMarker;
  Marker? _currentLocationMarker;

  
  final LatLng _initialPosition = LatLng(10.0080, 76.3616);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final currentLatLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _currentPosition = currentLatLng;
        _currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: currentLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      });

    
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 13),
        );
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        _updatePropertyCount();
      });
    }
  }

  void _updateRadius(double radius) {
    setState(() {
      _radius = radius;
      _updatePropertyCount();
    });
  }

  void _updatePropertyCount() {
    _propertyCount = (_radius * 28).toInt() + 10;
  }

  Set<Circle> _buildCircles() {
    if (_currentPosition == null) return {};
    const navyBlue = Color(0xFF1D3557);

    return {
      Circle(
        circleId: const CircleId('selected_radius'),
        center: _currentPosition!,
        radius: (_radius * 1000).toDouble(),
        fillColor: navyBlue.withOpacity(0.05),
        strokeColor: navyBlue,
        strokeWidth: 3,
      ),
    };
  }

  Future<void> _searchAndMove(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPosition = LatLng(loc.latitude, loc.longitude);

        setState(() {
          _currentPosition = newPosition;
          _searchedMarker = Marker(
            markerId: const MarkerId("searched_location"),
            position: newPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          );
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 13),
        );

        _updatePropertyCount();
      }
    } catch (e) {
    
    }
  }

  bool _isWithinRadius(LatLng from, LatLng to, double radiusKm) {
    final distanceInMeters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return distanceInMeters <= radiusKm * 1000;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(_initialPosition, 13),
              );
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            circles: _buildCircles(),
            markers: {
              if (_currentLocationMarker != null) _currentLocationMarker!,
              if (_searchedMarker != null) _searchedMarker!,
            },
          ),

  
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchAndMove,
                decoration: const InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Search around me",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                  const SizedBox(height: 16),

          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: radiusOptions.map((radius) {
                      final isSelected = _radius == radius;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () => _updateRadius(radius),
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFD4AF37)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${radius.toInt()}km",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

            
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF1D3557),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _radius,
                      min: radiusOptions.first,
                      max: radiusOptions.last,
                      divisions: (radiusOptions.last - radiusOptions.first)
                          .toInt(),
                      label: "${_radius.toInt()} km",
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                          _updatePropertyCount();
                        });
                      },
                    ),
                  ),

        
                  Text(
                    "$_propertyCount properties found within ${_radius.toInt()} km",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
