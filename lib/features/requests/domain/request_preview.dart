import 'help_request.dart';

const sampleRequests = [
  HelpRequest(
    id: '1',
    title: 'Помочь донести сумки до подъезда',
    description: 'Нужно поднять покупки на 4 этаж. Лифта нет.',
    compensation: RequestCompensation.free,
    areaLabel: 'Вокруг ул. Щорса',
    timeLabel: 'Сейчас',
    urgency: RequestUrgency.normal,
    status: RequestStatus.visible,
  ),
  HelpRequest(
    id: '2',
    title: 'Прикурить автомобиль',
    description: 'Сел аккумулятор, нужны провода на 10 минут.',
    compensation: RequestCompensation.paid,
    areaLabel: 'Рядом с ТЦ Гринвич',
    timeLabel: 'В ближайшие 15 минут',
    urgency: RequestUrgency.urgent,
    status: RequestStatus.visible,
  ),
  HelpRequest(
    id: '3',
    title: 'Погулять с собакой вечером',
    description: 'Небольшая прогулка на 20-30 минут, пока я на встрече.',
    compensation: RequestCompensation.paid,
    areaLabel: 'Район Южный',
    timeLabel: 'Сегодня в 19:00',
    urgency: RequestUrgency.low,
    status: RequestStatus.accepted,
  ),
];
