// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class CodecEnumAdapter extends TypeAdapter<CodecEnum> {
  @override
  final typeId = 0;

  @override
  CodecEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CodecEnum.h264;
      case 1:
        return CodecEnum.h265;
      case 2:
        return CodecEnum.h266;
      case 3:
        return CodecEnum.av1;
      case 4:
        return CodecEnum.mp4;
      default:
        return CodecEnum.h264;
    }
  }

  @override
  void write(BinaryWriter writer, CodecEnum obj) {
    switch (obj) {
      case CodecEnum.h264:
        writer.writeByte(0);
      case CodecEnum.h265:
        writer.writeByte(1);
      case CodecEnum.h266:
        writer.writeByte(2);
      case CodecEnum.av1:
        writer.writeByte(3);
      case CodecEnum.mp4:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodecEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
