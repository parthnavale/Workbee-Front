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

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _estimatedHoursController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  // Selected skills
  final Set<String> _selectedSkills = <String>{};

  // Available skills (same as in sign up)
  final List<String> _availableSkills = [
    'Cashier',
    'Customer Service',
    'Sales Assistant',
    'Store Associate',
    'Inventory Management',
    'Stock Management',
    'Product Display',
    'Billing/POS Operation',
    'Cleaning & Maintenance',
    'Reception/Front Desk',
    'Order Taking',
    'Product Delivery',
    'Store Security',
    'Visual Merchandising',
    'Product Packaging',
    'Quality Check',
    'Store Helper',
    'Floor Manager',
    'Customer Support',
    'Returns & Exchange',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _hourlyRateController.dispose();
    _estimatedHoursController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  // Helper method to create theme-aware input decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    bool isDarkMode = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary),
      prefixIcon: Icon(prefixIcon, color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey : AppColors.lightBorderSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey : AppColors.lightBorderSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: isDarkMode ? AppColors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary,
    );
  }

  void _showSkillsDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Required Skills',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: _availableSkills.map((skill) {
                return CheckboxListTile(
                  title: Text(
                    skill,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  value: _selectedSkills.contains(skill),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one required skill.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user is logged in
      if (!authProvider.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to post jobs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if user is a business owner
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
        // Debug print
        businessId: (() { return authProvider.businessOwnerId?.toString() ?? ''; })(),
        businessName: authProvider.userName ?? 'My Business',
        title: _titleController.text,
        description: _descriptionController.text,
        requiredSkills: _selectedSkills.toList(),
        location: _locationController.text,
        address: _addressController.text,
        state: _stateController.text,
        city: _cityController.text,
        pinCode: _pinCodeController.text,
        hourlyRate: double.parse(_hourlyRateController.text),
        estimatedHours: int.parse(_estimatedHoursController.text),
        postedDate: DateTime.now(),
        contactPerson: _contactPersonController.text,
        contactPhone: _contactPhoneController.text,
        contactEmail: _contactEmailController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting job: $e'),
            backgroundColor: Colors.red,
          ),
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

    // Block posting if business owner and businessOwnerId is not loaded
    if (authProvider.userRole == UserRole.poster && authProvider.businessOwnerId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Post a Job'),
          backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
          foregroundColor: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Job Details Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Job Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Job Title',
                          prefixIcon: Icons.title,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Job Description',
                          prefixIcon: Icons.description,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Required Skills
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Skills *',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _showSkillsDialog(context, isDarkMode),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isDarkMode ? AppColors.white.withOpacity(0.1) : AppColors.lightBackgroundSecondary,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.build,
                                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedSkills.isEmpty 
                                        ? 'Select required skills'
                                        : '${_selectedSkills.length} skill(s) selected',
                                      style: TextStyle(
                                        color: _selectedSkills.isEmpty 
                                          ? (isDarkMode ? Colors.grey : AppColors.lightTextSecondary)
                                          : (isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedSkills.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: _selectedSkills.map((skill) => Chip(
                                  label: Text(
                                    skill,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                  deleteIcon: Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedSkills.remove(skill);
                                    });
                                  },
                                )).toList(),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Location & Compensation Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Location & Compensation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _locationController,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icons.location_city,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icons.home,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                              decoration: _buildInputDecoration(
                                labelText: 'State',
                                prefixIcon: Icons.location_city,
                                isDarkMode: isDarkMode,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter state';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                              decoration: _buildInputDecoration(
                                labelText: 'City',
                                prefixIcon: Icons.location_city,
                                isDarkMode: isDarkMode,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter city';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _pinCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Pin Code',
                          prefixIcon: Icons.pin_drop,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pin code';
                          }
                          if (value.length != 6) {
                            return 'Pin code must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hourlyRateController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                              decoration: _buildInputDecoration(
                                labelText: 'Hourly Rate (₹)',
                                prefixIcon: Icons.attach_money,
                                isDarkMode: isDarkMode,
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _estimatedHoursController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                              decoration: _buildInputDecoration(
                                labelText: 'Estimated Hours',
                                prefixIcon: Icons.schedule,
                                isDarkMode: isDarkMode,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter hours';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Contact Information Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.white.withOpacity(0.05) : AppColors.lightBackgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? AppColors.grey.withOpacity(0.3) : AppColors.lightBorderSecondary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.contact_phone,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _contactPersonController,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Contact Person',
                          prefixIcon: Icons.person,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact person';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Contact Phone',
                          prefixIcon: Icons.phone,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _contactEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                        decoration: _buildInputDecoration(
                          labelText: 'Contact Email',
                          prefixIcon: Icons.email,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedScaleButton(
                  onTap: _isLoading ? null : () {
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 