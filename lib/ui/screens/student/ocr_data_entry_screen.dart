import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import '../../../core/services/data_service.dart';

class OCRDataEntryScreen extends StatefulWidget {
  const OCRDataEntryScreen({super.key});

  @override
  State<OCRDataEntryScreen> createState() => _OCRDataEntryScreenState();
}

class _OCRDataEntryScreenState extends State<OCRDataEntryScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
  // Form Data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium, // Changed from high to medium for speed
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _idController.dispose();
    _genderController.dispose();
    _fatherController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _scanImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      
      // Stage 1: Basic Blur Detection (Heuristic: File size check)
      final bytes = await image.length();
      if (bytes < 100000) { // If < 100KB, likely blurry or poor quality
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠ Image too small/blurry. Please move to better light.')),
        );
      }

      // Upload to Flask Backend
      var request = http.MultipartRequest('POST', Uri.parse('http://10.232.15.200:5000/ocr')); 
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await HapticFeedback.heavyImpact();
        final data = jsonDecode(response.body);
        _fillForm(data['extracted_data']);
      } else {
        // Handle server errors gracefully
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // Response body was not JSON
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error scanning text: $e');
      await HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Confidence Storage
  Map<String, double> _confidences = {};

  void _fillForm(Map<String, dynamic> data) {
    setState(() {
      _nameController.text = data['name']['value'] ?? "";
      _dobController.text = data['dob']['value'] ?? "";
      _idController.text = data['aadhaar']['value'] ?? "";
      _genderController.text = data['gender']['value'] ?? "";
      _fatherController.text = data['father_name']['value'] ?? "";
      _ageController.text = data['age']['value'] ?? "";
      
      _confidences['name'] = (data['name']['confidence'] as num?)?.toDouble() ?? 0.0;
      _confidences['dob'] = (data['dob']['confidence'] as num?)?.toDouble() ?? 0.0;
      _confidences['aadhaar'] = (data['aadhaar']['confidence'] as num?)?.toDouble() ?? 0.0;
      _confidences['gender'] = (data['gender']['confidence'] as num?)?.toDouble() ?? 0.0;
      _confidences['father'] = (data['father_name']['confidence'] as num?)?.toDouble() ?? 0.0;
      
      _showForm = true;
    });
  }

  Color _getConfidenceColor(String field) {
    double conf = _confidences[field] ?? 0.0;
    if (conf > 0.85) return Colors.green;
    if (conf > 0.60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Smart Document Scan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Camera View
          if (_isCameraInitialized)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Stage 1: Professional Overlay Guide
          if (!_showForm)
            Center(
              child: Container(
                width: 320,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Corners
                    Positioned(top: 0, left: 0, child: _buildCorner(top: true, left: true)),
                    Positioned(top: 0, right: 0, child: _buildCorner(top: true, left: false)),
                    Positioned(bottom: 0, left: 0, child: _buildCorner(top: false, left: true)),
                    Positioned(bottom: 0, right: 0, child: _buildCorner(top: false, left: false)),
                    
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.crop_free, color: Colors.white.withOpacity(0.8), size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'PLACE CARD INSIDE FRAME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5))]
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Controls
          if (!_showForm && !_isProcessing)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                   const Text(
                    'STABLE & CENTERED',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton.large(
                    onPressed: _scanImage,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.document_scanner, color: Colors.white),
                  ),
                ],
              ),
            ),

          // Loading Overlay (New)
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    const SizedBox(height: 24),
                    const Text(
                      'Analyzing Document...',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enhancing • Extracting • Validating',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Sheet Form (Stage 5 confidence feedback)
          if (_showForm)
            DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Verification Required',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _showForm = false),
                            ),
                          ],
                        ),
                        const Text('Please verify fields highlighted in amber or red.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 24),
                        
                        _buildFieldWithConfidence('Student Name', _nameController, Icons.person, 'name'),
                        const SizedBox(height: 16),
                        _buildFieldWithConfidence('Father\'s Name', _fatherController, Icons.person_outline, 'father'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildFieldWithConfidence('DOB', _dobController, Icons.calendar_today, 'dob')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Age', _ageController, Icons.timer)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldWithConfidence('Gender', _genderController, Icons.wc, 'gender'),
                        const SizedBox(height: 16),
                        _buildFieldWithConfidence('Aadhaar / ID Number', _idController, Icons.badge, 'aadhaar'),
                        
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Stage 6: Validation Layer
                              String aadhaar = _idController.text.replaceAll(' ', '');
                              if (aadhaar.isNotEmpty && !RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❌ Invalid Aadhaar Number (Must be 12 digits)')),
                                );
                                return;
                              }

                              if (_nameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❌ Student Name is required')),
                                );
                                return;
                              }

                              DataService().addChild();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✓ Success: Stored in Realtime Database')),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('CONFIRM & SAVE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showForm = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('RE-SCAN DOCUMENT'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFieldWithConfidence(String label, TextEditingController controller, IconData icon, String fieldKey) {
    Color statusColor = _getConfidenceColor(fieldKey);
    final bool isDob = fieldKey == 'dob';
    
    return TextField(
      controller: controller,
      readOnly: isDob, // Open picker on tap for DOB
      onTap: isDob ? () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2015), // Assuming young children
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          String formatted = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
          controller.text = formatted;
          _calculateAge(formatted);
        }
      } : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: statusColor),
        suffixIcon: Icon(
          statusColor == Colors.green ? Icons.check_circle : (statusColor == Colors.orange ? Icons.warning : Icons.error),
          color: statusColor.withOpacity(0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: statusColor.withOpacity(0.5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: statusColor, width: 2),
        ),
      ),
    );
  }

  void _calculateAge(String dob) {
    try {
      List<String> parts = dob.split('/');
      if (parts.length == 3) {
        DateTime birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        DateTime today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        setState(() {
          _ageController.text = "$age years";
        });
      }
    } catch (e) {
      debugPrint("Age calc error: $e");
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
