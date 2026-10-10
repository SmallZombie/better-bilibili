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

class SkipOptionsEnumAdapter extends TypeAdapter<SkipOptionsEnum> {
  @override
  final typeId = 1;

  @override
  SkipOptionsEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkipOptionsEnum.disable;
      case 1:
        return SkipOptionsEnum.showOnly;
      case 2:
        return SkipOptionsEnum.askOnlyStart;
      case 3:
        return SkipOptionsEnum.askOnlyEnd;
      case 4:
        return SkipOptionsEnum.skipToEnd;
      case 5:
        return SkipOptionsEnum.skipToStart;
      default:
        return SkipOptionsEnum.disable;
    }
  }

  @override
  void write(BinaryWriter writer, SkipOptionsEnum obj) {
    switch (obj) {
      case SkipOptionsEnum.disable:
        writer.writeByte(0);
      case SkipOptionsEnum.showOnly:
        writer.writeByte(1);
      case SkipOptionsEnum.askOnlyStart:
        writer.writeByte(2);
      case SkipOptionsEnum.askOnlyEnd:
        writer.writeByte(3);
      case SkipOptionsEnum.skipToEnd:
        writer.writeByte(4);
      case SkipOptionsEnum.skipToStart:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkipOptionsEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ViewOriginalImageEnumAdapter extends TypeAdapter<ViewOriginalImageEnum> {
  @override
  final typeId = 2;

  @override
  ViewOriginalImageEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ViewOriginalImageEnum.auto;
      case 1:
        return ViewOriginalImageEnum.always;
      case 2:
        return ViewOriginalImageEnum.wifiOnly;
      case 3:
        return ViewOriginalImageEnum.never;
      default:
        return ViewOriginalImageEnum.auto;
    }
  }

  @override
  void write(BinaryWriter writer, ViewOriginalImageEnum obj) {
    switch (obj) {
      case ViewOriginalImageEnum.auto:
        writer.writeByte(0);
      case ViewOriginalImageEnum.always:
        writer.writeByte(1);
      case ViewOriginalImageEnum.wifiOnly:
        writer.writeByte(2);
      case ViewOriginalImageEnum.never:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewOriginalImageEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoudnessNormalizationEnumAdapter
    extends TypeAdapter<LoudnessNormalizationEnum> {
  @override
  final typeId = 3;

  @override
  LoudnessNormalizationEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoudnessNormalizationEnum.off;
      case 1:
        return LoudnessNormalizationEnum.normal;
      case 2:
        return LoudnessNormalizationEnum.highDynamic;
      default:
        return LoudnessNormalizationEnum.off;
    }
  }

  @override
  void write(BinaryWriter writer, LoudnessNormalizationEnum obj) {
    switch (obj) {
      case LoudnessNormalizationEnum.off:
        writer.writeByte(0);
      case LoudnessNormalizationEnum.normal:
        writer.writeByte(1);
      case LoudnessNormalizationEnum.highDynamic:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoudnessNormalizationEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
