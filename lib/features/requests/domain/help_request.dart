enum RequestCompensation { free, paid }

enum RequestUrgency { low, normal, urgent }

enum RequestStatus {
  created,
  visible,
  accepted,
  inProgress,
  completed,
  rated,
  cancelled,
}

class HelpRequest {
  const HelpRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.compensation,
    required this.areaLabel,
    required this.timeLabel,
    required this.urgency,
    required this.status,
    this.responseCount = 0,
    this.hasCurrentUserResponded = false,
    this.isOwnRequest = false,
    this.latitude,
    this.longitude,
    this.distanceHintMeters,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final RequestCompensation compensation;
  final String areaLabel;
  final String timeLabel;
  final RequestUrgency urgency;
  final RequestStatus status;
  final int responseCount;
  final bool hasCurrentUserResponded;
  final bool isOwnRequest;
  final double? latitude;
  final double? longitude;
  final int? distanceHintMeters;
  final DateTime? createdAt;

  HelpRequest copyWith({
    String? id,
    String? title,
    String? description,
    RequestCompensation? compensation,
    String? areaLabel,
    String? timeLabel,
    RequestUrgency? urgency,
    RequestStatus? status,
    int? responseCount,
    bool? hasCurrentUserResponded,
    bool? isOwnRequest,
    double? latitude,
    double? longitude,
    int? distanceHintMeters,
    DateTime? createdAt,
  }) {
    return HelpRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      compensation: compensation ?? this.compensation,
      areaLabel: areaLabel ?? this.areaLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      responseCount: responseCount ?? this.responseCount,
      hasCurrentUserResponded:
          hasCurrentUserResponded ?? this.hasCurrentUserResponded,
      isOwnRequest: isOwnRequest ?? this.isOwnRequest,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceHintMeters: distanceHintMeters ?? this.distanceHintMeters,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
