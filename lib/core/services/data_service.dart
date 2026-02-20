import 'dart:async';
import 'package:flutter/foundation.dart';

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/child_model.dart';
import '../data/models/assessment_result_models.dart';
import 'offline_data_service.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final OfflineDataService _offlineService = OfflineDataService();

  // In-memory storage (Replace with SQLite/Hive for persistence in future)
  final List<ChildModel> _children = [];
  final List<AssessmentResult> _assessments = []; // Store assessments
  
  List<ChildModel> get children => List.unmodifiable(_children);
  List<AssessmentResult> get assessments => List.unmodifiable(_assessments);

  // Streams for counts
  final _childCountController = StreamController<int>.broadcast();
  final _assessmentCountController = StreamController<int>.broadcast();
  final _taskCountController = StreamController<int>.broadcast();
  final _alertCountController = StreamController<int>.broadcast();
  final _highRiskCountController = StreamController<int>.broadcast(); // Red Flag
  final _overdueCountController = StreamController<int>.broadcast();  // Last Visit

  Stream<int> get childCountStream => _childCountController.stream;
  Stream<int> get assessmentCountStream => _assessmentCountController.stream;
  Stream<int> get taskCountStream => _taskCountController.stream;
  Stream<int> get alertCountStream => _alertCountController.stream;
  Stream<int> get highRiskCountStream => _highRiskCountController.stream;
  Stream<int> get overdueCountStream => _overdueCountController.stream;

  // Mock initial data
  int _assessmentCount = 5;
  int _taskCount = 12;
  int _alertCount = 3;
  int _highRiskCount = 3; 
  int _overdueCount = 5;

  void init() {
    // Load offline data on init
    _loadOfflineData();
    _emitAll();
  }
  
  Future<void> _loadOfflineData() async {
    // Load Children
    final localChildren = _offlineService.getAllChildren();
    if (localChildren.isNotEmpty) {
      _children.clear();
      _children.addAll(localChildren.map((e) => ChildModel.fromJson(e)));
      
      // Update counts based on local data
      _childCountController.add(_children.length > 42 ? _children.length : 42);
      notifyListeners();
    }
  }

  void _emitAll() {
    _childCountController.add(_children.length > 42 ? _children.length : 42); // Keep mock baseline if empty
    _assessmentCountController.add(_assessmentCount);
    _taskCountController.add(_taskCount);
    _alertCountController.add(_alertCount);
    _highRiskCountController.add(_highRiskCount);
    _overdueCountController.add(_overdueCount);
  }

  void addChild(ChildModel child) {
    _children.add(child);
    
    // Save to Offline Storage
    _offlineService.saveChild(child.toJson());
    
    _childCountController.add(_children.length + 42); // Adding to mock baseline
    notifyListeners();
  }

  void updateChild(ChildModel updatedChild) {
    final index = _children.indexWhere((c) => c.id == updatedChild.id);
    if (index != -1) {
      _children[index] = updatedChild;
      _offlineService.saveChild(updatedChild.toJson()); // Assuming upsert behavior or relying on ID
      notifyListeners();
    }
  }

  void addAssessment() {
    _assessmentCount++;
    _assessmentCountController.add(_assessmentCount);
    notifyListeners();
  }

  void addAssessmentResult(AssessmentResult result) {
    _assessments.add(result);
    // Update assessment count
    _assessmentCount++;
    _assessmentCountController.add(_assessmentCount);
    
    // Check for high risk and update alert count
    if (result is MotorAssessmentResult && result.totalScore < 50) {
      addHighRiskChild();
      addAlert();
    } // Add other checks as needed
    
    notifyListeners();
  }

  List<AssessmentResult> getAssessmentsForChild(String childId) {
    return _assessments.where((a) => a.childId == childId).toList();
  }

  void addTask() {
    _taskCount++;
    _taskCountController.add(_taskCount);
    notifyListeners();
  }

  void addAlert() {
    _alertCount++;
    _alertCountController.add(_alertCount);
    notifyListeners();
  }

  void addHighRiskChild() {
    _highRiskCount++;
    _highRiskCountController.add(_highRiskCount);
    notifyListeners();
  }

  void resolveOverdue() {
    if (_overdueCount > 0) {
      _overdueCount--;
      _overdueCountController.add(_overdueCount);
      notifyListeners();
    }
  }
  
  // Excel Export
  Future<String> exportToExcel() async {
    // 1. Request Permissions
    if (Platform.isAndroid || Platform.isIOS) {
       var status = await Permission.storage.status;
       if (!status.isGranted) {
         status = await Permission.storage.request();
         if (!status.isGranted) {
            // Try manage external storage for Android 11+
            if (await Permission.manageExternalStorage.status.isDenied) {
               await Permission.manageExternalStorage.request();
            }
         }
       }
    }
    
    // 2. Create Excel
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Children_Data'];
    
    // 3. Add Headers
    List<String> headers = ['ID', 'Name', 'Age (Months)', 'Gender', 'Anganwadi', 'Date Added'];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
    
    // 4. Add Data
    for (var child in _children) {
      sheetObject.appendRow([
        TextCellValue(child.id),
        TextCellValue(child.name),
        IntCellValue(child.ageMonths),
        TextCellValue(child.gender ?? 'N/A'),
        TextCellValue(child.anganwadi ?? 'N/A'),
        TextCellValue(DateTime.now().toString().split(' ')[0]),
      ]);
    }
    
    // 5. Save
    String? outputFile;
    if (Platform.isAndroid) {
      // Save to Downloads folder implies simpler path usually, but safe bet is app docs or external
      // Let's try to find a public directory or standard documents
      final directory = await getExternalStorageDirectory(); // App specific
      // Ideally /storage/emulated/0/Download for user visibility but strict scoped storage blocks it usually without MANAGE_EXTERNAL_STORAGE
      // We will save to app directory and return path.
      String path = directory?.path ?? (await getApplicationDocumentsDirectory()).path;
      outputFile = "$path/Children_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    } else {
      final directory = await getApplicationDocumentsDirectory();
      outputFile = "${directory.path}/Children_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    }
    
    var fileBytes = excel.save();
    File(outputFile)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
      
    return outputFile;
  }

  @override
  void dispose() {
    _childCountController.close();
    _assessmentCountController.close();
    _taskCountController.close();
    _alertCountController.close();
    _highRiskCountController.close();
    _overdueCountController.close();
    super.dispose();
  }
}
