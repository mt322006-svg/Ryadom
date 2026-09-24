import '../domain/nostr_event.dart';

class RyadomNostrValidator {
  const RyadomNostrValidator._();

  static const int requestKind = 31101;
  static const int responseKind = 31102;
  static const int requestStateKind = 31103;

  static final RegExp _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');
  static const Set<String> _requestStatuses = {
    'created',
    'visible',
    'accepted',
    'in_progress',
    'completed',
    'rated',
    'cancelled',
  };
  static const Set<String> _urgencies = {'low', 'normal', 'urgent'};
  static const Set<String> _compensations = {'free', 'paid'};

  static bool isValidRemoteAppEvent(NostrEvent event) {
    if (event.kind != requestKind &&
        event.kind != responseKind &&
        event.kind != requestStateKind) {
      return false;
    }
    if (!_validPubkey(event.pubkey) ||
        event.signature == null ||
        event.signature!.isEmpty ||
        !_hasTag(event, 't', 'we-ryadom') ||
        !_validTags(event.tags) ||
        !_validTimestamp(event.createdAt)) {
      return false;
    }

    return switch (event.kind) {
      requestKind => _validRequest(event),
      responseKind => _validResponse(event),
      requestStateKind => _validState(event),
      _ => false,
    };
  }

  static bool _validRequest(NostrEvent event) {
    final title = event.content['title'];
    final description = event.content['description'];
    final area = event.content['area_label'];
    final time = event.content['time_label'];
    if (!_validText(title, min: 1, max: 120) ||
        !_validText(description, max: 2000) ||
        !_validText(area, max: 180) ||
        !_validText(time, max: 120) ||
        event.content.containsKey('latitude') ||
        event.content.containsKey('longitude')) {
      return false;
    }

    final id = _firstTag(event, 'd');
    final status = _firstTag(event, 'status');
    final urgency = _firstTag(event, 'urgent');
    final compensation = _firstTag(event, 'comp');
    final bucket = _firstTag(event, 'g');

    return _validIdentifier(id) &&
        status != null &&
        _requestStatuses.contains(status) &&
        urgency != null &&
        _urgencies.contains(urgency) &&
        compensation != null &&
        _compensations.contains(compensation) &&
        bucket != null &&
        bucket.isNotEmpty &&
        bucket.length <= 128;
  }

  static bool _validResponse(NostrEvent event) {
    final requestId = event.content['request_id'];
    final message = event.content['message'];
    final eventRef = _firstTag(event, 'e');
    final stableId = _firstTag(event, 'd');
    final status = _firstTag(event, 'status');

    return _validText(requestId, min: 1, max: 128) &&
        _validText(message, max: 500) &&
        _validIdentifier(stableId) &&
        _validHexId(eventRef) &&
        (status == 'sent' || status == 'accepted' || status == 'declined');
  }

  static bool _validState(NostrEvent event) {
    final requestId = event.content['request_id'];
    final contentStatus = event.content['status'];
    final tagStatus = _firstTag(event, 'status');
    final eventRef = _firstTag(event, 'e');
    final stableId = _firstTag(event, 'd');
    final note = event.content['note'];
    final helper = event.content['helper_pubkey'];
    final rating = event.content['rating'];

    if (!_validText(requestId, min: 1, max: 128) ||
        !_validIdentifier(stableId) ||
        !_validHexId(eventRef) ||
        contentStatus is! String ||
        tagStatus != contentStatus ||
        !_requestStatuses.contains(contentStatus) ||
        !_validText(note, max: 500, allowNull: true)) {
      return false;
    }

    if (helper != null && (helper is! String || !_validPubkey(helper))) {
      return false;
    }
    if (rating != null && (rating is! int || rating < 1 || rating > 5)) {
      return false;
    }
    return true;
  }

  static bool _validTags(List<List<String>> tags) {
    if (tags.length > 32) {
      return false;
    }
    for (final tag in tags) {
      if (tag.isEmpty || tag.length > 8) {
        return false;
      }
      for (final part in tag) {
        if (part.length > 512) {
          return false;
        }
      }
    }
    return true;
  }

  static bool _validTimestamp(DateTime? value) {
    if (value == null) {
      return false;
    }
    return !value.isAfter(DateTime.now().add(const Duration(minutes: 10)));
  }

  static bool _validText(
    Object? value, {
    int min = 0,
    required int max,
    bool allowNull = false,
  }) {
    if (value == null) {
      return allowNull;
    }
    return value is String && value.length >= min && value.length <= max;
  }

  static bool _validIdentifier(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value.length <= 128 &&
        !value.contains(RegExp(r'[\r\n\t]'));
  }

  static bool _validHexId(String? value) {
    return value != null && _hex64.hasMatch(value);
  }

  static bool _validPubkey(String? value) {
    return value != null && _hex64.hasMatch(value);
  }

  static bool _hasTag(NostrEvent event, String key, String value) {
    return event.tags.any(
      (tag) => tag.length >= 2 && tag[0] == key && tag[1] == value,
    );
  }

  static String? _firstTag(NostrEvent event, String key) {
    for (final tag in event.tags) {
      if (tag.length >= 2 && tag[0] == key) {
        return tag[1];
      }
    }
    return null;
  }
}
