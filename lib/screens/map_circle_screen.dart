import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCircleScreen extends StatefulWidget {
  @override
  _MapCircleScreenState createState() => _MapCircleScreenState();
}

class _MapCircleScreenState extends State<MapCircleScreen> {
  late GoogleMapController _mapController;
  LatLng? _center = LatLng(25.2048, 55.2708); 
  LatLng? _circleCenter;
  LatLng? _dragHandlePosition;
  double _radiusInMeters = 2300;
  Set<Marker> _markers = {};
  Circle? _circle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center!, zoom: 13),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onLongPress: _onLongPress,
            onCameraMove: (pos) {
              _center = pos.target;
            },
            markers: _markers,
            circles: _circle != null ? {_circle!} : {},
            onTap: _onMapTap,
          ),

  
          if (_circleCenter != null)
            Positioned(
              top: 80,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_radiusInMeters / 1000).toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              children: [
                _circleIconButton(Icons.undo, 'Undo', _undo),
                _circleIconButton(Icons.clear, 'Clear', _clear),
                _circleIconButton(Icons.save, 'Save', _save),
              ],
            ),
          ),

  
          if (_circleCenter == null)
            Positioned(
              bottom: 140,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _instructionRow(Icons.location_pin, 'Long-press to drop pin'),
                  _instructionRow(Icons.pan_tool_alt, 'Drag to draw circle'),
                ],
              ),
            ),

    
          if (_circle != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '23 properties found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Long-press to drop pin'),
                    Text('• Drag to draw circle'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onLongPress(LatLng latLng) {
    setState(() {
      _circleCenter = latLng;
      _updateCircle();
      _updateDragHandle();
      _markers = {
        Marker(
          markerId: MarkerId('pin'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: MarkerId('handle'),
          position: _dragHandlePosition!,
          draggable: true,
          onDrag: _onHandleDrag,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
        ),
      };
    });
  }

  void _onHandleDrag(LatLng newPos) {
    if (_circleCenter == null) return;
    final dist = _calculateDistance(_circleCenter!, newPos);
    setState(() {
      _radiusInMeters = dist;
      _updateCircle();
      _updateDragHandle();
      _updateHandleMarker();
    });
  }

  void _onMapTap(LatLng _) {
    FocusScope.of(context).unfocus();
  }

  void _updateCircle() {
    if (_circleCenter == null) return;
    _circle = Circle(
      circleId: CircleId('circle'),
      center: _circleCenter!,
      radius: _radiusInMeters,
      strokeWidth: 2,
      strokeColor: Colors.yellow,
      fillColor: Colors.indigo.withOpacity(0.3),
    );
  }

  void _updateDragHandle() {
    final double handleLat =
        _circleCenter!.latitude +
        (_radiusInMeters / 111000); 
    _dragHandlePosition = LatLng(handleLat, _circleCenter!.longitude);
  }

  void _updateHandleMarker() {
    _markers.removeWhere((m) => m.markerId.value == 'handle');
    _markers.add(
      Marker(
        markerId: MarkerId('handle'),
        position: _dragHandlePosition!,
        draggable: true,
        onDrag: _onHandleDrag,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
  }

  void _undo() {
    setState(() {
      _radiusInMeters = 2300;
      _updateCircle();
      _updateDragHandle();
      _updateHandleMarker();
    });
  }

  void _clear() {
    setState(() {
      _circleCenter = null;
      _markers.clear();
      _circle = null;
    });
  }

  void _save() {
    
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Area saved')));
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double R = 6371000; 
    double dLat = _toRadians(p2.latitude - p1.latitude);
    double dLon = _toRadians(p2.longitude - p1.longitude);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(p1.latitude)) *
            cos(_toRadians(p2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRadians(double deg) => deg * pi / 180;

  Widget _circleIconButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade800,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size(90, 36),
        ),
      ),
    );
  }

  Widget _instructionRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigo),
          SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
