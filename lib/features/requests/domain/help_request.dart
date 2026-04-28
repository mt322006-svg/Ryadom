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
  });

  final String id;
  final String title;
  final String description;
  final RequestCompensation compensation;
  final String areaLabel;
  final String timeLabel;
  final RequestUrgency urgency;
  final RequestStatus status;
}
