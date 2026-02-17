import 'package:hive/hive.dart';

part 'child_model.g.dart';

@HiveType(typeId: 0)
class ChildModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String gender;

  @HiveField(4)
  final String district;

  @HiveField(5)
  final String village;

  @HiveField(6)
  final double weight;

  @HiveField(7)
  final double height;

  @HiveField(8)
  final String riskLevel; // high, moderate, mild, normal

  @HiveField(9)
  final DateTime lastVisitDate;

  @HiveField(10)
  final double? speechScore; // 0-100

  @HiveField(11)
  final String? hearingStatus; // Normal, Mild, Moderate, Severe

  @HiveField(12)
  final DateTime? lastAssessmentDate;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.district,
    required this.village,
    required this.weight,
    required this.height,
    required this.riskLevel,
    required this.lastVisitDate,
    this.speechScore,
    this.hearingStatus,
    this.lastAssessmentDate,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Other',
      district: map['district'] ?? '',
      village: map['village'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      riskLevel: map['riskLevel'] ?? 'normal',
      lastVisitDate: map['lastVisitDate'] != null 
          ? DateTime.parse(map['lastVisitDate']) 
          : DateTime.now(),
      speechScore: map['speechScore']?.toDouble(),
      hearingStatus: map['hearingStatus'],
      lastAssessmentDate: map['lastAssessmentDate'] != null 
          ? DateTime.parse(map['lastAssessmentDate']) 
          : null,
    );
  }
}
