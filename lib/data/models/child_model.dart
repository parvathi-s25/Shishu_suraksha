import 'package:hive/hive.dart';
import 'growth_data.dart';

@HiveType(typeId: 1)
class ChildModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime dob;

  @HiveField(3)
  final String gender; // 'Male', 'Female', 'Other'

  @HiveField(4)
  final String parentName;

  @HiveField(5)
  final String parentPhone;

  @HiveField(6)
  final String? photoUrl;

  @HiveField(7)
  final List<GrowthData> growthHistory;

  ChildModel({
    required this.id,
    required this.name,
    required this.dob,
    required this.gender,
    required this.parentName,
    required this.parentPhone,
    this.photoUrl,
    List<GrowthData>? growthHistory,
  }) : growthHistory = growthHistory ?? [];
}

class ChildModelAdapter extends TypeAdapter<ChildModel> {
  @override
  final int typeId = 1;

  @override
  ChildModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChildModel(
      id: fields[0] as String,
      name: fields[1] as String,
      dob: fields[2] as DateTime,
      gender: fields[3] as String,
      parentName: fields[4] as String,
      parentPhone: fields[5] as String,
      photoUrl: fields[6] as String?,
      growthHistory: (fields[7] as List?)?.cast<GrowthData>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChildModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dob)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.parentName)
      ..writeByte(5)
      ..write(obj.parentPhone)
      ..writeByte(6)
      ..write(obj.photoUrl)
      ..writeByte(7)
      ..write(obj.growthHistory);
  }
}
