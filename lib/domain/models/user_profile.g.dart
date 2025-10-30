// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 4;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String?,
      phoneNumber: fields[3] as String?,
      profilePictureUrl: fields[4] as String?,
      totalMeasurements: fields[5] as int,
      totalRewards: fields[6] as int,
      level: fields[7] as int,
      experiencePoints: fields[8] as double,
      badges: (fields[9] as List).cast<String>(),
      preferences: (fields[10] as Map).cast<String, dynamic>(),
      isPremium: fields[11] as bool,
      walletAccountId: fields[15] as String?,
      hbarBalance: fields[16] as double?,
      hushTokenBalance: fields[17] as double?,
      lastWalletSync: fields[18] as DateTime?,
      totalRewardsEarned: fields[19] as double?,
      totalRewardsClaimed: fields[20] as double?,
      currentStreak: fields[21] as int?,
      venuesVisited: fields[22] as int?,
      achievements: (fields[23] as List?)?.cast<String>(),
    )
      ..lastActive = fields[12] as DateTime
      ..createdAt = fields[13] as DateTime
      ..updatedAt = fields[14] as DateTime;
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.profilePictureUrl)
      ..writeByte(5)
      ..write(obj.totalMeasurements)
      ..writeByte(6)
      ..write(obj.totalRewards)
      ..writeByte(7)
      ..write(obj.level)
      ..writeByte(8)
      ..write(obj.experiencePoints)
      ..writeByte(9)
      ..write(obj.badges)
      ..writeByte(10)
      ..write(obj.preferences)
      ..writeByte(11)
      ..write(obj.isPremium)
      ..writeByte(12)
      ..write(obj.lastActive)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.walletAccountId)
      ..writeByte(16)
      ..write(obj.hbarBalance)
      ..writeByte(17)
      ..write(obj.hushTokenBalance)
      ..writeByte(18)
      ..write(obj.lastWalletSync)
      ..writeByte(19)
      ..write(obj.totalRewardsEarned)
      ..writeByte(20)
      ..write(obj.totalRewardsClaimed)
      ..writeByte(21)
      ..write(obj.currentStreak)
      ..writeByte(22)
      ..write(obj.venuesVisited)
      ..writeByte(23)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
