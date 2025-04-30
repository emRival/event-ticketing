// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_get_ticketing_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveGetTicketingResponseAdapter
    extends TypeAdapter<HiveGetTicketingResponse> {
  @override
  final int typeId = 3;

  @override
  HiveGetTicketingResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveGetTicketingResponse(
      id: fields[0] as String?,
      cabang: fields[1] as String?,
      nama: fields[2] as String?,
      kelas: fields[3] as String?,
      panitia: fields[4] as String?,
      status: (fields[5] as bool?) ?? false, // ✅ Perbaikan utama
      issend: fields[6] as bool?,
      jamKedatangan: fields[7] as String?,
      nokursi: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveGetTicketingResponse obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cabang)
      ..writeByte(2)
      ..write(obj.nama)
      ..writeByte(3)
      ..write(obj.kelas)
      ..writeByte(4)
      ..write(obj.panitia)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.issend)
      ..writeByte(7)
      ..write(obj.jamKedatangan)
      ..writeByte(8)
      ..write(obj.nokursi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveGetTicketingResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
