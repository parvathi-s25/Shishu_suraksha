
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExportService {
  
  /// Generates an Excel report for child health data
  Future<String?> generateHealthReport(String schoolName, List<Map<String, dynamic>> childrenData) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Health Report'];
      
      // Header Style
      CellStyle headerStyle = CellStyle(
        bold: true,
        italic: false,
        textWrapping: TextWrapping.WrapText,
        fontFamily: getFontFamily(FontFamily.Arial),
        rotation: 0,
      );

      // Add Headers
      var headers = ["Child Name", "Age", "Heart Rate (BPM)", "SpO2 (%)", "Temp (°C)", "Risk Score", "Status"];
      for (var i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Add Data
      for (var i = 0; i < childrenData.length; i++) {
        var data = childrenData[i];
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(data['name'] ?? "");
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = IntCellValue(data['age'] ?? 0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = DoubleCellValue(data['heart_rate']?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = DoubleCellValue(data['spo2']?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DoubleCellValue(data['temp']?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = IntCellValue(data['score'] ?? 0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = TextCellValue(data['status'] ?? "Normal");
      }

      // Save File
      List<int>? fileBytes = excel.save();
      if (fileBytes == null) return null;

      String fileName = "${schoolName.replaceAll(' ', '_')}_Health_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      if (kIsWeb) {
        // Handle web export (this would normally trigger a download in JS)
        return "Web export handled via browser";
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(fileBytes);
        
        // Share/Open File
        await Share.shareXFiles([XFile(file.path)], text: 'ShishuSuraksha Health Report');
        
        return file.path;
      }
    } catch (e) {
      debugPrint("Excel Export Error: $e");
      return null;
    }
  }

  /// Generates an Excel report for growth monitoring
  Future<String?> generateGrowthReport(String schoolName, List<Map<String, dynamic>> growthData) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Growth Tracking'];
      
      var headers = ["Child Name", "Height (cm)", "Weight (kg)", "BMI", "Malnutrition Status", "Date"];
      for (var i = 0; i < headers.length; i++) {
         sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
      }

      for (var i = 0; i < growthData.length; i++) {
        var data = growthData[i];
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(data['name'] ?? "");
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = DoubleCellValue(data['height']?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = DoubleCellValue(data['weight']?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = DoubleCellValue(data['bmi']?.toDouble() ?? 0.0);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = TextCellValue(data['status'] ?? "");
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = TextCellValue(data['date'] ?? "");
      }

      List<int>? fileBytes = excel.save();
      if (fileBytes == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Growth_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      await file.writeAsBytes(fileBytes);
      
      await Share.shareXFiles([XFile(file.path)], text: 'ShishuSuraksha Growth Report');
      return file.path;
    } catch (e) {
      debugPrint("Growth Export Error: $e");
      return null;
    }
  }
}
