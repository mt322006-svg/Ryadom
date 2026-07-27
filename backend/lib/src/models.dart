enum RequestCompensation { free, paid }

enum RequestUrgency { low, normal, urgent }

enum RequestStatus { created, visible, accepted, inProgress, completed, rated, cancelled }

class HelpRequestRecord {
  HelpRequestRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.compensation,
    required this.areaLabel,
    required this.timeLabel,
    required this.urgency,
    required this.status,
    required this.createdAt,
    this.responseCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final RequestCompensation compensation;
  final String areaLabel;
  final String timeLabel;
  final RequestUrgency urgency;
  RequestStatus status;
  final DateTime createdAt;
  int responseCount;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'compensation': compensation.name,
      'areaLabel': areaLabel,
      'timeLabel': timeLabel,
      'urgency': urgency.name,
      'status': status.name,
      'responseCount': responseCount,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class RequestResponseRecord {
  RequestResponseRecord({
    required this.id,
    required this.requestId,
    required this.responderId,
    required this.createdAt,
  });

  final String id;
  final String requestId;
  final String responderId;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'responderId': responderId,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
