import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/auth_data.dart';
import '../../../localization/translations.dart';
import '../../../localization/all_village_translations_loader.dart';
import 'package:shishu_suraksha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:shishu_suraksha/ui/screens/admin/admin_dashboard_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  final String selectedLanguage;

  const AuthenticationScreen({
    super.key,
    this.selectedLanguage = 'English',
  });

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String? selectedRole;
  String? selectedDistrict;
  String? selectedVillage;
  String? selectedUserId;
  String password = '';
  bool obscurePassword = true;
  bool _isTranslationsLoaded = false;

  List<String> availableVillages = [];
  List<String> availableUserIds = [];

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    await AllVillageTranslations.init();
    if (mounted) {
      setState(() {
        _isTranslationsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until translations are ready
    if (!_isTranslationsLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image with low opacity (25%) and blur
          Positioned.fill(
            child: Opacity(
              opacity: 0.25, // Low opacity as requested
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFF8F0),
                          Color(0xFFFFF5EB),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Glassmorphic blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.1), // Reduced overlay since bg is already low opacity
              ),
            ),
          ),

          // Top-right logo (70-90px)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 80, // Within 70-90px range
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(height: 80, width: 80);
                  },
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // LOGIN title
                    Text(
                      _getTranslation('login'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F66),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 1. Role Dropdown
                    _buildDropdown(
                      label: _getTranslation('select_role'),
                      value: selectedRole,
                      items: AuthData.roles,
                      displayItems: AuthData.roles.map((role) {
                        if (role == 'Admin') return _getTranslation('admin');
                        if (role == 'Anganwadi Teacher') return _getTranslation('anganwadi_teacher');
                        return role;
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                          selectedDistrict = null;
                          selectedVillage = null;
                          selectedUserId = null;
                          availableVillages = [];
                          availableUserIds = [];
                        });
                      },
                    ),

                    // Show District & Village only for Anganwadi Teacher
                    if (selectedRole == 'Anganwadi Teacher') ...[
                      const SizedBox(height: 20),

                      // 2. District Dropdown
                      _buildDropdown(
                        label: _getTranslation('select_district'),
                        value: selectedDistrict,
                        items: AuthData.districts,
                        displayItems: AuthData.districts.map((district) => 
                          _getDistrictTranslation(district)
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            selectedVillage = null;
                            selectedUserId = null;

                            availableVillages = value != null
                                ? AuthData.getVillagesForDistrict(value)
                                : [];

                            availableUserIds = value != null
                                ? AuthData.getUserIdsForDistrict(value)
                                : [];
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // 3. Village Dropdown (CRITICAL: Using AllVillageTranslations)
                      _buildDropdown(
                        label: _getTranslation('select_village'),
                        value: selectedVillage,
                        items: availableVillages,
                        displayItems: availableVillages.map((village) =>
                          AllVillageTranslations.get(widget.selectedLanguage, village)
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVillage = value;
                          });
                        },
                        enabled: selectedDistrict != null,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 4. User ID Dropdown
                    _buildDropdown(
                      label: _getTranslation('select_user_id'),
                      value: selectedUserId,
                      items: selectedRole == 'Admin'
                          ? List.generate(20, (i) => 'ADMIN${(i + 1).toString().padLeft(3, '0')}')
                          : availableUserIds,
                      onChanged: (value) {
                        setState(() {
                          selectedUserId = value;
                        });
                      },
                      enabled: selectedRole == 'Admin' || selectedDistrict != null,
                    ),

                    const SizedBox(height: 20),

                    // 5. Password Field
                    _buildPasswordField(),

                    const SizedBox(height: 32),

                    // 6. Sign In Button
                    _buildSignInButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    List<String>? displayItems,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    final List<String> itemsToDisplay = displayItems ?? items;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF005F66),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                items: List.generate(items.length, (index) {
                  return DropdownMenuItem(
                    value: items[index],
                    child: Text(
                      itemsToDisplay[index],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTranslation('password'),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF005F66),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: obscurePassword,
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
            decoration: InputDecoration(
              hintText: _getTranslation('password'),
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF005F66), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FB7A7),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF4FB7A7).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _getTranslation('sign_in'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _handleSignIn() {
    if (selectedRole == null) {
      _showError(_getTranslation('please_select_role'));
      return;
    }

    if (selectedRole == 'Anganwadi Teacher') {
      if (selectedDistrict == null) {
        _showError(_getTranslation('please_select_district'));
        return;
      }
      if (selectedVillage == null) {
        _showError(_getTranslation('please_select_village'));
        return;
      }
    }

    if (selectedUserId == null) {
      _showError(_getTranslation('please_select_user_id'));
      return;
    }

    if (password.isEmpty) {
      _showError(_getTranslation('please_enter_password'));
      return;
    }

    // Role-based navigation
    // String target = selectedRole == 'Admin' ? 'Admin Dashboard' : 'Teacher Dashboard';
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Navigating to $target...')),
    // );
    
    if (selectedRole == 'Anganwadi Teacher') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  String _getTranslation(String key) {
    return Translations.get(widget.selectedLanguage, key);
  }

  String _getDistrictTranslation(String district) {
    return Translations.getDistrict(widget.selectedLanguage, district);
  }
}
