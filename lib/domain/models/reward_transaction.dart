import 'package:hive/hive.dart';

part 'reward_transaction.g.dart';

@HiveType(typeId: 7)
class RewardTransaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String transactionId;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String tokenType; // 'HBAR' or 'HUSH'

  @HiveField(5)
  late RewardTransactionStatus status;

  @HiveField(6)
  late RewardTransactionType type;

  @HiveField(7)
  late String? description;

  @HiveField(8)
  late String? measurementId; // Associated noise measurement

  @HiveField(9)
  late String? venueId; // Associated venue check-in

  @HiveField(10)
  late DateTime createdAt;

  @HiveField(11)
  late DateTime updatedAt;

  @HiveField(12)
  late DateTime? completedAt;

  @HiveField(13)
  late String? errorMessage;

  @HiveField(14)
  late Map<String, dynamic> metadata;

  RewardTransaction({
    required this.id,
    required this.userId,
    required this.transactionId,
    required this.amount,
    required this.tokenType,
    required this.status,
    required this.type,
    this.description,
    this.measurementId,
    this.venueId,
    DateTime? createdAtParam,
    DateTime? updatedAtParam,
    this.completedAt,
    this.errorMessage,
    this.metadata = const {},
  }) {
    createdAt = createdAtParam ?? DateTime.now();
    updatedAt = updatedAtParam ?? DateTime.now();
  }

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      tokenType: json['tokenType'] as String,
      status: RewardTransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RewardTransactionStatus.pending,
      ),
      type: RewardTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => RewardTransactionType.measurement,
      ),
      description: json['description'] as String?,
      measurementId: json['measurementId'] as String?,
      venueId: json['venueId'] as String?,
      createdAtParam: DateTime.parse(json['createdAt'] as String),
      updatedAtParam: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'transactionId': transactionId,
      'amount': amount,
      'tokenType': tokenType,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'description': description,
      'measurementId': measurementId,
      'venueId': venueId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  RewardTransaction copyWith({
    String? id,
    String? userId,
    String? transactionId,
    double? amount,
    String? tokenType,
    RewardTransactionStatus? status,
    RewardTransactionType? type,
    String? description,
    String? measurementId,
    String? venueId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return RewardTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      tokenType: tokenType ?? this.tokenType,
      status: status ?? this.status,
      type: type ?? this.type,
      description: description ?? this.description,
      measurementId: measurementId ?? this.measurementId,
      venueId: venueId ?? this.venueId,
      createdAtParam: createdAt ?? this.createdAt,
      updatedAtParam: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if transaction is in a final state
  bool get isCompleted => status == RewardTransactionStatus.completed;
  bool get isFailed => status == RewardTransactionStatus.failed;
  bool get isPending => status == RewardTransactionStatus.pending;
  bool get isProcessing => status == RewardTransactionStatus.processing;

  /// Get human-readable status text
  String get statusText {
    switch (status) {
      case RewardTransactionStatus.pending:
        return 'Pending';
      case RewardTransactionStatus.processing:
        return 'Processing';
      case RewardTransactionStatus.completed:
        return 'Completed';
      case RewardTransactionStatus.failed:
        return 'Failed';
    }
  }

  /// Get human-readable type text
  String get typeText {
    switch (type) {
      case RewardTransactionType.measurement:
        return 'Noise Measurement';
      case RewardTransactionType.checkin:
        return 'Venue Check-in';
      case RewardTransactionType.streak:
        return 'Daily Streak';
      case RewardTransactionType.achievement:
        return 'Achievement';
      case RewardTransactionType.bonus:
        return 'Bonus Reward';
    }
  }

  /// Get formatted amount with token symbol
  String get formattedAmount {
    return '${amount.toStringAsFixed(tokenType == 'HBAR' ? 8 : 2)} $tokenType';
  }

  @override
  String toString() {
    return 'RewardTransaction(id: $id, userId: $userId, transactionId: $transactionId, amount: $amount, tokenType: $tokenType, status: $status, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RewardTransaction &&
        other.id == id &&
        other.userId == userId &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ transactionId.hashCode;
  }
}

@HiveType(typeId: 8)
enum RewardTransactionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  processing,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed,
}

@HiveType(typeId: 9)
enum RewardTransactionType {
  @HiveField(0)
  measurement,
  @HiveField(1)
  checkin,
  @HiveField(2)
  streak,
  @HiveField(3)
  achievement,
  @HiveField(4)
  bonus,
}
