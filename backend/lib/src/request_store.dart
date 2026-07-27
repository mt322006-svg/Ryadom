import 'models.dart';

class RequestStore {
  RequestStore() {
    final now = DateTime.now();
    _requests.addAll([
      HelpRequestRecord(
        id: 'req-1',
        title: 'Помочь донести сумки до подъезда',
        description: 'Нужно поднять покупки на 4 этаж. Лифта нет.',
        compensation: RequestCompensation.free,
        areaLabel: 'Вокруг ул. Щорса',
        timeLabel: 'Сейчас',
        urgency: RequestUrgency.normal,
        status: RequestStatus.visible,
        createdAt: now,
      ),
      HelpRequestRecord(
        id: 'req-2',
        title: 'Прикурить автомобиль',
        description: 'Сел аккумулятор, нужны провода на 10 минут.',
        compensation: RequestCompensation.paid,
        areaLabel: 'Рядом с ТЦ Гринвич',
        timeLabel: 'В ближайшие 15 минут',
        urgency: RequestUrgency.urgent,
        status: RequestStatus.visible,
        createdAt: now,
        responseCount: 1,
      ),
    ]);
  }

  final List<HelpRequestRecord> _requests = [];
  final List<RequestResponseRecord> _responses = [];

  List<HelpRequestRecord> listRequests() {
    return List.unmodifiable(_requests);
  }

  HelpRequestRecord? getRequest(String id) {
    for (final request in _requests) {
      if (request.id == id) {
        return request;
      }
    }
    return null;
  }

  HelpRequestRecord createRequest({
    required String title,
    required String description,
    required RequestCompensation compensation,
    required String areaLabel,
    required String timeLabel,
    required RequestUrgency urgency,
  }) {
    final request = HelpRequestRecord(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      compensation: compensation,
      areaLabel: areaLabel,
      timeLabel: timeLabel,
      urgency: urgency,
      status: RequestStatus.visible,
      createdAt: DateTime.now(),
    );
    _requests.insert(0, request);
    return request;
  }

  RequestResponseRecord? respondToRequest({
    required String requestId,
    required String responderId,
  }) {
    final request = getRequest(requestId);
    if (request == null) {
      return null;
    }

    final response = RequestResponseRecord(
      id: 'resp-${DateTime.now().microsecondsSinceEpoch}',
      requestId: requestId,
      responderId: responderId,
      createdAt: DateTime.now(),
    );
    _responses.add(response);
    request.responseCount += 1;
    if (request.status == RequestStatus.visible) {
      request.status = RequestStatus.accepted;
    }
    return response;
  }
}
