// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardTransactionAdapter extends TypeAdapter<RewardTransaction> {
  @override
  final int typeId = 7;

  @override
  RewardTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardTransaction(
      id: fields[0] as String,
      userId: fields[1] as String,
      transactionId: fields[2] as String,
      amount: fields[3] as double,
      tokenType: fields[4] as String,
      status: fields[5] as RewardTransactionStatus,
      type: fields[6] as RewardTransactionType,
      description: fields[7] as String?,
      measurementId: fields[8] as String?,
      venueId: fields[9] as String?,
      completedAt: fields[12] as DateTime?,
      errorMessage: fields[13] as String?,
      metadata: (fields[14] as Map).cast<String, dynamic>(),
    )
      ..createdAt = fields[10] as DateTime
      ..updatedAt = fields[11] as DateTime;
  }

  @override
  void write(BinaryWriter writer, RewardTransaction obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.transactionId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.tokenType)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.measurementId)
      ..writeByte(9)
      ..write(obj.venueId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.errorMessage)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTransactionStatusAdapter
    extends TypeAdapter<RewardTransactionStatus> {
  @override
  final int typeId = 8;

  @override
  RewardTransactionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardTransactionStatus.pending;
      case 1:
        return RewardTransactionStatus.processing;
      case 2:
        return RewardTransactionStatus.completed;
      case 3:
        return RewardTransactionStatus.failed;
      default:
        return RewardTransactionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RewardTransactionStatus obj) {
    switch (obj) {
      case RewardTransactionStatus.pending:
        writer.writeByte(0);
        break;
      case RewardTransactionStatus.processing:
        writer.writeByte(1);
        break;
      case RewardTransactionStatus.completed:
        writer.writeByte(2);
        break;
      case RewardTransactionStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTransactionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTransactionTypeAdapter extends TypeAdapter<RewardTransactionType> {
  @override
  final int typeId = 9;

  @override
  RewardTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardTransactionType.measurement;
      case 1:
        return RewardTransactionType.checkin;
      case 2:
        return RewardTransactionType.streak;
      case 3:
        return RewardTransactionType.achievement;
      case 4:
        return RewardTransactionType.bonus;
      default:
        return RewardTransactionType.measurement;
    }
  }

  @override
  void write(BinaryWriter writer, RewardTransactionType obj) {
    switch (obj) {
      case RewardTransactionType.measurement:
        writer.writeByte(0);
        break;
      case RewardTransactionType.checkin:
        writer.writeByte(1);
        break;
      case RewardTransactionType.streak:
        writer.writeByte(2);
        break;
      case RewardTransactionType.achievement:
        writer.writeByte(3);
        break;
      case RewardTransactionType.bonus:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
