import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/ui/screens/dashboard/teacher_dashboard.dart';
import 'package:shishu_suraksha/data/auth_data.dart';
import 'package:shishu_suraksha/localization/all_village_translations_loader.dart';
import 'package:shishu_suraksha/localization/translations.dart';

class AnganwadiLoginScreen extends StatefulWidget {
  const AnganwadiLoginScreen({super.key});

  @override
  State<AnganwadiLoginScreen> createState() => _AnganwadiLoginScreenState();
}

class _AnganwadiLoginScreenState extends State<AnganwadiLoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Added form key
  String? _selectedDistrict;
  String? _selectedVillage;
  String? _selectedUserId;
  String _password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;

  List<String> _availableVillages = [];
  List<String> _availableUserIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
      await AllVillageTranslations.init();
      if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF), // Light purple background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F0FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6B4CE6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4CE6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF6B4CE6),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Anganwadi Worker Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B1E8A), // Dark Purple
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Please select your center details to sign in.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 40),

              // Login Form
              Form(
                key: _formKey,
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // District Selection
                    _buildLabel('District'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: 'Select District',
                      value: _selectedDistrict,
                      items: AuthData.districts,
                      displayItems: AuthData.districts.map((d) => Translations.getDistrict('English', d)).toList(),
                      icon: Icons.map_rounded,
                      onChanged: (value) {
                         setState(() {
                            _selectedDistrict = value;
                            _selectedVillage = null;
                            _selectedUserId = null;
                            _availableVillages = value != null ? AuthData.getVillagesForDistrict(value) : [];
                            _availableUserIds = value != null ? AuthData.getUserIdsForDistrict(value) : [];
                         });
                      },
                    ),

                    const SizedBox(height: 20),

                     // Village Selection
                    _buildLabel('Village'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                       hint: 'Select Village',
                       value: _selectedVillage,
                       items: _availableVillages,
                       displayItems: _availableVillages.map((v) => AllVillageTranslations.get('English', v)).toList(),
                       icon: Icons.location_on_rounded,
                       onChanged: _selectedDistrict == null ? null : (value) {
                          setState(() {
                             _selectedVillage = value;
                          });
                       },
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('User ID'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: 'Select User ID',
                      value: _selectedUserId,
                      items: _availableUserIds,
                      icon: Icons.person_outline_rounded,
                      onChanged: _selectedDistrict == null ? null : (value) {
                        setState(() {
                           _selectedUserId = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration(
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF6B4CE6),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => _password = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF6B4CE6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4CE6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF6B4CE6).withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3B1E8A),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    List<String>? displayItems,
    required IconData icon,
    required void Function(String?)? onChanged,
  }) {
    final List<String> itemsToDisplay = displayItems ?? items;
    // Ensure itemsToDisplay has same length as items
    final safeDisplayItems = itemsToDisplay.length == items.length ? itemsToDisplay : items;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: onChanged != null ? const Color(0xFF6B4CE6).withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: Colors.grey[400], size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: List.generate(items.length, (index) {
             return DropdownMenuItem(
                value: items[index],
                child: Row(
                   children: [
                      Icon(icon, color: const Color(0xFF6B4CE6), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                           safeDisplayItems[index],
                           style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                           ),
                           overflow: TextOverflow.ellipsis,
                        ),
                      )
                   ]
                )
             );
          }),
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: onChanged != null ? const Color(0xFF6B4CE6) : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6B4CE6)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFF6B4CE6).withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6B4CE6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
       if (_selectedDistrict == null || _selectedVillage == null || _selectedUserId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Please select all fields')),
          );
          return;
       }

      setState(() => _isLoading = true);
      
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    }
  }
}
