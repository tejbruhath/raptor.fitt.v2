import 'package:hive/hive.dart';

part 'crew_model.g.dart';

@HiveType(typeId: 6)
class CrewModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  List<String> memberIds;
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  String? inviteCode;
  
  @HiveField(5)
  String creatorId;

  CrewModel({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    this.inviteCode,
    required this.creatorId,
  });

  CrewModel copyWith({
    String? id,
    String? name,
    List<String>? memberIds,
    DateTime? createdAt,
    String? inviteCode,
    String? creatorId,
  }) {
    return CrewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      inviteCode: inviteCode ?? this.inviteCode,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}

@HiveType(typeId: 7)
class CrewChallengeModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String crewId;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String type; // 'volume', 'consistency', 'pr'
  
  @HiveField(4)
  DateTime startDate;
  
  @HiveField(5)
  DateTime endDate;
  
  @HiveField(6)
  Map<String, double> scores; // userId -> score
  
  @HiveField(7)
  bool isActive;

  CrewChallengeModel({
    required this.id,
    required this.crewId,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.scores,
    this.isActive = true,
  });

  String get winner {
    if (scores.isEmpty) return '';
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  CrewChallengeModel copyWith({
    String? id,
    String? crewId,
    String? name,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, double>? scores,
    bool? isActive,
  }) {
    return CrewChallengeModel(
      id: id ?? this.id,
      crewId: crewId ?? this.crewId,
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      scores: scores ?? this.scores,
      isActive: isActive ?? this.isActive,
    );
  }
}
