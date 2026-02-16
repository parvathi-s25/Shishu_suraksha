import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../../localization/legacy_app_localizations.dart'; // For DataLocalizations
import '../../../../main.dart'; // For language switching
import 'dart:ui';
import 'package:shishu_suraksha/data/auth_data.dart';
import '../../widgets/cropped_logo.dart';
import '../../screens/dashboard/teacher_dashboard.dart';


class AuthenticationScreen extends StatefulWidget {
  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String? selectedRole;
  late String selectedLang;
  String? selectedDistrict;
  String? selectedVillage;
  String? selectedUserId; // Added for User ID Dropdown
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    selectedLang = args != null ? args as String : 'en';
    
    // We don't need to force set locale here if it's already managed by MyApp, 
    // but preserving selectedLang logic for now.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   MyApp.setLocale(context, Locale(selectedLang));
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Use generated AppLocalizations for UI text
    final t = AppLocalizations.of(context)!;
    // Use legacy DataLocalizations for data (districts, villages)
    // We need to try/catch or safe access since DataLocalizations might not be ready or context might be null?
    // DataLocalizations is in localizationsDelegates, so it should be available.
    final dataLoc = DataLocalizations.of(context);

    // Safe access for districts/villages using DataLocalizations
    List<String> districts = [];
    try {
      // DataLocalizations still has the logic to load from JSON and has .list() method
      districts = dataLoc.list("districts"); 
      // Wait, legacy code used t.districts which returned Map<String, String> in my view of file legacy_app_localizations.dart
      // Let's check legacy_app_localizations.dart content again if needed, but I recall it had 'districts' getter returning Map.
      // Actually the view file showed: Map<String, String> get districts ...
      // But the authentication_screen.dart used `t.districts.entries`
    } catch (e) {
      districts = [];
    }

    Map<String, List<String>> villagesMap = {};
    try {
       // legacy has map(String key) method
      villagesMap = dataLoc.map("villages");
    } catch (e) {
      villagesMap = {};
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background: logo.png (blurred, 25% opacity)
          Positioned.fill(
            child: Opacity(
              opacity: 0.25, 
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Soft Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          ),

          // 2. Top-Right Logo (Fixed Position)
          Positioned(
            top: 50,
            right: 25,
            child: CroppedLogo(width: 60),
          ),

          // 3. Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60), 
                  
                  // LOGIN Title
                  Text(
                    t.login, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      letterSpacing: 1.2,
                    )
                  ),
                  const SizedBox(height: 40),

                  // Role Selection: RADIO BUTTONS
                  Text(t.role, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(t.admin),
                        value: "Admin", // Internal value mismatching label is fine, or use t.admin as value? No, keep logic value constant.
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                        activeColor: Colors.teal,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      RadioListTile<String>(
                        title: Text(t.anganwadiTeacher),
                        value: "Anganwadi Teacher",
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                        activeColor: Colors.teal,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // District Dropdown
                  Text(t.district, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDistrict,
                        hint: Text(t.district),
                        // Use dataLoc.districts entries
                        items: dataLoc.districts.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key, // English Key
                            child: Text(entry.value), // Localized Name
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            selectedVillage = null;
                            selectedUserId = null; 
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Village Dropdown
                  if (selectedDistrict != null) ...[
                    Text(t.village, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedVillage,
                          hint: Text(t.village),
                          // Look up villages using English District Key from dataLoc
                          items: (dataLoc.map("villages")[selectedDistrict] ?? [])
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVillage = value as String;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // User ID Dropdown (Dynamic & Localized Label)
                  if (selectedDistrict != null) ...[
                     Text(t.userId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                     const SizedBox(height: 8),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12),
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey.shade400),
                         borderRadius: BorderRadius.circular(8),
                         color: Colors.white.withOpacity(0.9),
                       ),
                       child: DropdownButtonHideUnderline(
                         child: DropdownButton<String>(
                           isExpanded: true,
                           value: selectedUserId,
                           hint: Text(t.userId),
                           // Look up User IDs using English District Key and Role
                           items: AuthData.getUserIdsForDistrict(selectedDistrict!)
                               .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                               .toList(),
                           onChanged: (value) {
                             setState(() {
                               selectedUserId = value;
                             });
                           },
                         ),
                       ),
                     ),
                     const SizedBox(height: 20),
                     
                     // Password Field (Localized)
                     TextFormField(
                       focusNode: _passwordFocusNode,
                       obscureText: true,
                       decoration: InputDecoration(
                         labelText: t.password,
                         hintText: t.password,
                         border: const OutlineInputBorder(),
                         filled: true,
                         fillColor: Colors.white70,
                       ),
                     ),
                  ],

                  const SizedBox(height: 40),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: () {
                      if (selectedRole != null && selectedDistrict != null && selectedVillage != null) {
                         if (selectedRole == "Admin") { 
                           Navigator.pushReplacement(
                             context,
                             MaterialPageRoute(builder: (context) => const DashboardScreen(role: 'Admin')),
                           );
                         } else {
                           Navigator.pushReplacementNamed(context, "/dashboard");
                         }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all fields"))
                        );
                      }
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      t.signIn.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),

                  // Version Text
                  const SizedBox(height: 15),
                  const Text(
                    "v2.0.1",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500
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
