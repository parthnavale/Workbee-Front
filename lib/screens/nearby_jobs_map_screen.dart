import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/job.dart';
import 'job_detail_screen.dart';

class NearbyJobsMapScreen extends StatefulWidget {
  const NearbyJobsMapScreen({super.key});

  @override
  State<NearbyJobsMapScreen> createState() => _NearbyJobsMapScreenState();
}

class _NearbyJobsMapScreenState extends State<NearbyJobsMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  List<Job> _jobs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNearbyJobs();
  }

  Future<void> _fetchNearbyJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) serviceEnabled = await location.requestService();
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      }
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _error = 'Location permission denied.';
          _loading = false;
        });
        print('[ERROR] Location permission denied.');
        return;
      }
      final locData = await location.getLocation();
      final lat = locData.latitude;
      final lng = locData.longitude;
      if (lat == null || lng == null) {
        setState(() {
          _error = 'Could not get current location.';
          _loading = false;
        });
        print('[ERROR] Could not get current location.');
        return;
      }
      _currentLatLng = LatLng(lat, lng);
      final url = Uri.parse(
        'https://myworkbee.duckdns.org/jobs/nearby?lat=$lat&lng=$lng&radius_km=20',
      );
      print('[DEBUG] Request URL: $url');
      final response = await http.get(url);
      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response headers: ${response.headers}');
      print('[DEBUG] Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _jobs = data.map((j) => Job.fromJson(j)).toList();
        print('Nearby jobs: \n\n\n');
        print(_jobs);
        setState(() {
          _loading = false;
        });
        // Auto-zoom to fit all markers if jobs are found
        if (_jobs.isNotEmpty && _mapController != null) {
          Future.delayed(Duration(milliseconds: 500), () {
            _fitMapToMarkers();
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch jobs. Status: ${response.statusCode}';
          _loading = false;
        });
        print('[ERROR] Failed to fetch jobs. Status: ${response.statusCode}');
        print('[ERROR] Response body: ${response.body}');
      }
    } catch (e, stack) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _loading = false;
      });
      print('[ERROR] Exception in _fetchNearbyJobs: ${e.toString()}');
      print('[ERROR] Stack trace: \n$stack');
    }
  }

  void _fitMapToMarkers() {
    if (_jobs.isEmpty || _mapController == null) return;
    final latLngs = _jobs
        .where((job) => job.latitude != null && job.longitude != null)
        .map((job) => LatLng(job.latitude!, job.longitude!))
        .toList();
    if (_currentLatLng != null) latLngs.add(_currentLatLng!);
    if (latLngs.length < 2) return;
    double minLat = latLngs
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = latLngs
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = latLngs
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = latLngs
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = _jobs
        .map((job) {
          if (job.latitude == null || job.longitude == null) return null;
          return Marker(
            markerId: MarkerId(job.id),
            position: LatLng(job.latitude!, job.longitude!),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: job.title,
              snippet: job.businessName,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                );
              },
            ),
          );
        })
        .whereType<Marker>()
        .toSet();
    if (_currentLatLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: _currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(title: 'You are here'),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Jobs on Map')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _currentLatLng == null
          ? const Center(child: Text('Could not get location.'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng!,
                zoom: 13,
              ),
              markers: _buildMarkers(),
              onMapCreated: (controller) {
                _mapController = controller;
                controller.setMapStyle(
                  '[{"featureType":"poi","elementType":"all","stylers":[{"visibility":"off"}]}]',
                );
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapType: MapType.normal,
            ),
    );
  }
}
