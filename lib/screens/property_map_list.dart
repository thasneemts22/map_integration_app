import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({Key? key}) : super(key: key);

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  double _radius = 2.0;
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(25.276987, 55.296249); // Dubai

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F7F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListView(
            children: [
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home, color: Colors.indigo, size: 30),
                      SizedBox(width: 8),
                      Text(
                        "iQaama",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.flash_on, size: 16),
                    label: Text("Fast Search"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: StadiumBorder(),
                      elevation: 0,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

        
              TextField(
                decoration: InputDecoration(
                  hintText: 'Find properties near you',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.my_location_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20),

            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Nearby\n(100m)", textAlign: TextAlign.center),
                  Text("Walking\nDistance\n(1km)", textAlign: TextAlign.center),
                  Text("Driving\nDistance\n(5km)", textAlign: TextAlign.center),
                  Text("Extended\nArea\n(15km)", textAlign: TextAlign.center),
                ],
              ),

              Slider(
                value: _radius,
                min: 0.1,
                max: 15,
                divisions: 30,
                label: "${_radius.toStringAsFixed(1)} km",
                onChanged: (value) {
                  setState(() => _radius = value);
                },
                activeColor: Colors.amber,
              ),

        
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 160,
                  color: Colors.grey.shade300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("center"),
                        position: _center,
                        infoWindow: InfoWindow(title: "Dubai"),
                      ),
                    },
                    circles: {
                      Circle(
                        circleId: CircleId("radius"),
                        center: _center,
                        radius: _radius * 1000,
                        strokeColor: Colors.amber,
                        fillColor: Colors.amber.withOpacity(0.3),
                        strokeWidth: 2,
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
                    liteModeEnabled: true,
                  ),
                ),
              ),

              SizedBox(height: 20),

      
              Center(
                child: Text(
                  "247 properties found within ${_radius.toStringAsFixed(1)}km",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

          
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildPropertyOption("Just Listed", "1 hour ago"),
                  _buildPropertyOption("Near You", "150m away"),
                  _buildPropertyOption("Troding in Your Area", null),
                  _buildPropertyOption("Trending in Your Area", null),
                ],
              ),

              SizedBox(height: 20),

              // Bottom Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bottomButton(Icons.add_alert, "Create Alert"),
                  _bottomButton(Icons.favorite_border, "Saved Searches"),
                  _bottomButton(Icons.history, "Recent Views"),
                ],
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "Real-time Updates Active",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyOption(String title, String? subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }

  Widget _bottomButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
