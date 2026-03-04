// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChildModelAdapter extends TypeAdapter<ChildModel> {
  @override
  final int typeId = 0;

  @override
  ChildModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChildModel(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      gender: fields[3] as String,
      district: fields[4] as String,
      village: fields[5] as String,
      weight: fields[6] as double,
      height: fields[7] as double,
      riskLevel: fields[8] as String,
      lastVisitDate: fields[9] as DateTime,
      speechScore: fields[10] as double?,
      hearingStatus: fields[11] as String?,
      lastAssessmentDate: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChildModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.district)
      ..writeByte(5)
      ..write(obj.village)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.height)
      ..writeByte(8)
      ..write(obj.riskLevel)
      ..writeByte(9)
      ..write(obj.lastVisitDate)
      ..writeByte(10)
      ..write(obj.speechScore)
      ..writeByte(11)
      ..write(obj.hearingStatus)
      ..writeByte(12)
      ..write(obj.lastAssessmentDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
