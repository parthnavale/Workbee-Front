import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/user_roles.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/gradient_background.dart';
import '../constants/job_designations.dart'; // Added import for JobDesignations
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedJobTitle;
  LatLng _pickedLatLng = const LatLng(19.0760, 72.8777); // Default to Mumbai
  GoogleMapController? _googleMapController;
  final _hourlyRateController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  bool _isLoading = false;
  // No tile caching needed for Google Maps
  final List<String> _rateTypes = [
    'Per Hour',
    'Per Day',
    'Per Week',
    'Per Month',
  ];
  String? _selectedRateType = 'Per Hour';

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  // No tile caching needed for Google Maps
  @override
  void initState() {
    super.initState();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    bool isDarkMode = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
      prefixIcon: Icon(
        prefixIcon,
        color: isDarkMode ? Colors.grey : Colors.black54,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey : Colors.black26,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey : Colors.black26,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to post jobs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (authProvider.userRole != UserRole.poster) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only business owners can post jobs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final job = Job(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: authProvider.businessOwnerId?.toString() ?? '',
        businessName: authProvider.userName ?? 'My Business',
        title: _selectedJobTitle ?? '',
        description: '',
        requiredSkills: [_selectedJobTitle ?? ''],
        location: '',
        address: '',
        state: '',
        city: '',
        pinCode: '',
        hourlyRate: double.parse(_hourlyRateController.text),
        estimatedHours: int.tryParse(_estimatedTimeController.text) ?? 0,
        postedDate: DateTime.now(),
        latitude: _pickedLatLng.latitude,
        longitude: _pickedLatLng.longitude,
      );
      await Provider.of<JobProvider>(context, listen: false).postJob(job);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final snackBarMessage = 'Error posting job: $e';
        print('[SNACKBAR ERROR] $snackBarMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBarMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final cardColor = isDarkMode
        ? AppColors.backgroundSecondary.withOpacity(0.95)
        : AppColors.lightBackgroundSecondary.withOpacity(0.95);
    final textColor = isDarkMode
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final borderColor = isDarkMode
        ? AppColors.borderSecondary
        : AppColors.lightBorderSecondary;
    final inputFillColor = isDarkMode
        ? AppColors.backgroundPrimary
        : Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Job',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode
            ? AppColors.backgroundSecondary
            : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode
            ? AppColors.textPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLatLng,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _googleMapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('picked'),
                position: _pickedLatLng,
              ),
            },
            onTap: (latlng) {
              setState(() {
                _pickedLatLng = latlng;
              });
              _googleMapController?.animateCamera(
                CameraUpdate.newLatLng(latlng),
              );
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            mapType: MapType.normal,
          ),
          // Overlay card for job title and compensation
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedJobTitle,
                      items: JobDesignations.designations
                          .map(
                            (designation) => DropdownMenuItem(
                              value: designation,
                              child: Text(
                                designation,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobTitle = value;
                        });
                      },
                      decoration: _buildInputDecoration(
                        labelText: 'Job Title',
                        prefixIcon: Icons.title,
                        isDarkMode: isDarkMode,
                      ).copyWith(filled: true, fillColor: inputFillColor),
                      dropdownColor: inputFillColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a job title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRateType,
                      items: _rateTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRateType = value;
                        });
                      },
                      decoration: _buildInputDecoration(
                        labelText: 'Rate Type',
                        prefixIcon: Icons.schedule,
                        isDarkMode: isDarkMode,
                      ).copyWith(filled: true, fillColor: inputFillColor),
                      dropdownColor: inputFillColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a rate type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _estimatedTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Estimated Time',
                        prefixIcon: Icon(Icons.timer, color: textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        filled: true,
                        fillColor: inputFillColor,
                        labelStyle: TextStyle(color: textColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter estimated time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Hourly Rate (₹)',
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('₹', style: TextStyle(fontSize: 18)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        filled: true,
                        fillColor: inputFillColor,
                        labelStyle: TextStyle(color: textColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hourly rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedScaleButton(
                      onTap: _isLoading
                          ? null
                          : () {
                              _submitJob();
                            },
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Post Job',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
