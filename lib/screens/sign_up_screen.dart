import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/user_roles.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/gradient_background.dart';
import '../core/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole? _selectedRole;

  // Common fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Business fields
  final _companyController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _businessRegNumberController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _businessDescriptionController = TextEditingController();

  // Worker fields
  final _skillsController = TextEditingController();
  final _locationController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadharController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _educationController = TextEditingController();
  final _yearsOfEducationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Remove _stateCities map and state/city dropdowns
  // Add controllers for state and city to auto-fill
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isPasswordVisible = false;
  String? _selectedGender;

  // Predefined skills list for retail/service jobs
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

  // Selected skills
  final Set<String> _selectedSkills = <String>{};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _contactPersonController.dispose();
    _confirmPasswordController.dispose();
    _businessAddressController.dispose();
    _businessTypeController.dispose();
    _gstNumberController.dispose();
    _businessRegNumberController.dispose();
    _employeeCountController.dispose();
    _businessDescriptionController.dispose();
    _skillsController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _educationController.dispose();
    _yearsOfEducationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper to fetch state/city from pincode
  Future<void> _fetchAddressFromPincode(String pincode) async {
    if (pincode.length != 6) return;
    final url = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          setState(() {
            _stateController.text = postOffice['State'] ?? '';
            _cityController.text = postOffice['District'] ?? '';
          });
        } else {
          setState(() {
            _stateController.text = '';
            _cityController.text = '';
          });
        }
      }
    } catch (e) {
      setState(() {
        _stateController.text = '';
        _cityController.text = '';
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      if (_selectedRole == UserRole.seeker && _selectedSkills.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one skill.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final apiService = ApiService(authProvider: authProvider);
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final username = email.split('@')[0];

        // --- Delayed spinner for registration ---
        bool dialogShown = false;
        late Future<void> dialogFuture;
        final registerFuture = authProvider.register(username, email, password, _selectedRole!);
        dialogFuture = Future.delayed(const Duration(milliseconds: 300), () async {
          dialogShown = true;
          await LoadingDialog.show(
            context,
            message: _selectedRole == UserRole.poster
                ? 'Registering as Business Owner...'
                : 'Registering as Worker...'
          );
        });
        final success = await registerFuture;
        if (dialogShown && mounted) LoadingDialog.hide(context);
        if (!success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User registration failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        final userId = authProvider.userId;
        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to get user ID. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        // --- Delayed spinner for profile creation ---
        dialogShown = false;
        final profileFuture = _selectedRole == UserRole.poster
            ? apiService.createBusinessOwner({
                "user_id": userId,
                "business_name": _companyController.text,
                "contact_person": _contactPersonController.text,
                "contact_phone": _phoneController.text,
                "contact_email": email,
                "address": _businessAddressController.text,
                "website": "",
                "industry": _businessTypeController.text,
                "state": _stateController.text,
                "city": _cityController.text,
                "pincode": _pinCodeController.text,
                "year_established": 2024
              })
            : apiService.createWorker({
                "user_id": userId,
                "name": _nameController.text,
                "phone": _phoneController.text,
                "email": email,
                "skills": _selectedSkills.join(","),
                "years_of_experience": 1,
                "address": _addressController.text,
                "state": _stateController.text,
                "city": _cityController.text,
                "pincode": _pinCodeController.text
              });
        dialogFuture = Future.delayed(const Duration(milliseconds: 300), () async {
          dialogShown = true;
          await LoadingDialog.show(
            context,
            message: _selectedRole == UserRole.poster
                ? 'Creating Business Owner Profile...'
                : 'Creating Worker Profile...'
          );
        });
        await profileFuture;
        if (dialogShown && mounted) LoadingDialog.hide(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful as ${_selectedRole == UserRole.poster ? 'Business' : 'Worker'}!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to create theme-aware input decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isDarkMode = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary),
      prefixIcon: Icon(prefixIcon, color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary),
      suffixIcon: isPassword ? IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ) : null,
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
      fillColor: isDarkMode ? AppColors.whiteWithAlpha(0.1) : AppColors.lightBackgroundSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: isDarkMode ? AppColors.backgroundSecondary : AppColors.lightBackgroundSecondary,
        foregroundColor: isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Register as',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.poster;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedRole == UserRole.poster
                                      ? AppColors.primary
                                      : (isDarkMode ? AppColors.whiteWithAlpha(0.1) : AppColors.lightBackgroundSecondary),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == UserRole.poster
                                        ? AppColors.primary
                                        : (isDarkMode ? Colors.grey : AppColors.lightBorderSecondary),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.business_center,
                                      color: _selectedRole == UserRole.poster
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Business',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedRole == UserRole.poster
                                            ? AppColors.primaryDark
                                            : (isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.seeker;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedRole == UserRole.seeker
                                      ? AppColors.primary
                                      : (isDarkMode ? AppColors.whiteWithAlpha(0.1) : AppColors.lightBackgroundSecondary),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == UserRole.seeker
                                        ? AppColors.primary
                                        : (isDarkMode ? Colors.grey : AppColors.lightBorderSecondary),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.work,
                                      color: _selectedRole == UserRole.seeker
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Worker',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedRole == UserRole.seeker
                                            ? AppColors.primaryDark
                                            : (isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Role-specific fields
                      if (_selectedRole == UserRole.poster) ...[
                        // Business Name
                        TextFormField(
                          controller: _companyController,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Business Name',
                            prefixIcon: Icons.business,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your business name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Contact Person Name
                        TextFormField(
                          controller: _contactPersonController,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Contact Person Name',
                            prefixIcon: Icons.person,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter contact person name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Contact Person Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Contact Person Email Address',
                            prefixIcon: Icons.email,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter contact person email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icons.phone,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icons.lock,
                            isPassword: true,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Business Address
                        TextFormField(
                          controller: _businessAddressController,
                          maxLines: 3,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Business Address',
                            prefixIcon: Icons.location_on,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Business Type/Industry
                        TextFormField(
                          controller: _businessTypeController,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Business Type/Industry',
                            prefixIcon: Icons.category,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // GST Number
                        TextFormField(
                          controller: _gstNumberController,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'GST Number',
                            prefixIcon: Icons.receipt,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter GST number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Business Registration Number
                        TextFormField(
                          controller: _businessRegNumberController,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Business Registration Number',
                            prefixIcon: Icons.assignment,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business registration number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Number of Employees
                        TextFormField(
                          controller: _employeeCountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Number of Employees',
                            prefixIcon: Icons.people,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter number of employees';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Business Description
                        TextFormField(
                          controller: _businessDescriptionController,
                          maxLines: 4,
                          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                          decoration: _buildInputDecoration(
                            labelText: 'Business Description',
                            prefixIcon: Icons.description,
                            isDarkMode: isDarkMode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ] else if (_selectedRole == UserRole.seeker) ...[
                        // Personal Information Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Worker Name
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icons.person,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Worker Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icons.email,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Worker Phone
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icons.phone,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Worker DOB
                              TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                                    });
                                  }
                                },
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: Icons.date_range,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your date of birth';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Worker Aadhar
                              TextFormField(
                                controller: _aadharController,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Aadhar Card Number',
                                  prefixIcon: Icons.credit_card,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Aadhar card number';
                                  }
                                  if (value.length != 12) {
                                    return 'Aadhar card number must be 12 digits';
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return 'Aadhar card number must contain only digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Worker Gender
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                                items: ['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: _buildInputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: Icons.person,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your gender';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Address Information Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
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
                                    'Address Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Address
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
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Pin Code
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
                                    return 'Please enter your pin code';
                                  }
                                  if (value.length != 6) {
                                    return 'Pin code must be 6 digits';
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return 'Pin code must contain only digits';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value.length == 6) {
                                    _fetchAddressFromPincode(value);
                                  } else {
                                    _stateController.text = '';
                                    _cityController.text = '';
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              // State (auto-filled)
                              TextFormField(
                                controller: _stateController,
                                readOnly: true,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'State/Union Territory',
                                  prefixIcon: Icons.location_city,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // City (auto-filled)
                              TextFormField(
                                controller: _cityController,
                                readOnly: true,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'City/District',
                                  prefixIcon: Icons.location_city,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Skills & Education Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Skills & Education',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Skills
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Skills *',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey : AppColors.lightTextSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      _showSkillsDialog(context, isDarkMode);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isDarkMode ? Colors.grey : AppColors.lightBorderSecondary,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: isDarkMode ? AppColors.whiteWithAlpha(0.1) : AppColors.lightBackgroundSecondary,
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
                                                ? 'Select your skills'
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
                                          backgroundColor: AppColors.primaryWithAlpha(0.2),
                                          deleteIcon: Icon(Icons.close, size: 16),
                                          onDeleted: () {
                                            setState(() {
                                              _selectedSkills.remove(skill);
                                            });
                                          },
                                        )).toList(),
                                      ),
                                    ),
                                  if (_selectedSkills.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Please select at least one skill',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Education
                              TextFormField(
                                controller: _educationController,
                                maxLines: 2,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Education Details',
                                  prefixIcon: Icons.school,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your education details';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Years of Experience
                              TextFormField(
                                controller: _yearsOfEducationController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Years of Experience',
                                  prefixIcon: Icons.timeline,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter years of experience';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  final years = int.parse(value);
                                  if (years < 0 || years > 50) {
                                    return 'Years must be between 0 and 50';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Description
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Previous Work Experience',
                                  prefixIcon: Icons.work_history,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your previous work experience';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Account Security Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.whiteWithAlpha(0.05) : AppColors.lightBackgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? AppColors.greyWithAlpha(0.3) : AppColors.lightBorderSecondary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Account Security',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icons.lock,
                                  isPassword: true,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.lightTextPrimary),
                                decoration: _buildInputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: true,
                                  isDarkMode: isDarkMode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      AnimatedScaleButton(
                        onTap: _submit,
                        backgroundColor: const Color(0xFFEAB308),
                        foregroundColor: const Color(0xFF10182B),
                        minimumSize: const Size(double.infinity, 50),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSkillsDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Skills',
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
}