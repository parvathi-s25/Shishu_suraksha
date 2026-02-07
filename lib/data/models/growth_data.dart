import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class GrowthData extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double height; // in cm

  @HiveField(2)
  final double weight; // in kg

  @HiveField(3)
  final double? headCircumference; // in cm

  @HiveField(4)
  final String? notes;

  GrowthData({
    required this.date,
    required this.height,
    required this.weight,
    this.headCircumference,
    this.notes,
  });
}

class GrowthDataAdapter extends TypeAdapter<GrowthData> {
  @override
  final int typeId = 0;

  @override
  GrowthData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthData(
      date: fields[0] as DateTime,
      height: fields[1] as double,
      weight: fields[2] as double,
      headCircumference: fields[3] as double?,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.headCircumference)
      ..writeByte(4)
      ..write(obj.notes);
  }
}
