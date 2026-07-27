import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'models.dart';
import 'request_store.dart';

Future<HttpServer> serveRyadomApi({required int port}) {
  final store = RequestStore();
  final router = Router()
    ..get('/health', (Request request) {
      return _jsonResponse({
        'status': 'ok',
        'service': 'my-ryadom-backend',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    })
    ..get('/requests', (Request request) {
      final requests = store.listRequests().map((item) => item.toJson()).toList();
      return _jsonResponse({'requests': requests});
    })
    ..post('/requests', (Request request) async {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final created = store.createRequest(
        title: payload['title'] as String? ?? '',
        description: payload['description'] as String? ?? '',
        compensation: _parseCompensation(payload['compensation'] as String?),
        areaLabel: payload['areaLabel'] as String? ?? '',
        timeLabel: payload['timeLabel'] as String? ?? '',
        urgency: _parseUrgency(payload['urgency'] as String?),
      );
      return _jsonResponse(created.toJson(), statusCode: 201);
    })
    ..post('/requests/<id>/respond', (Request request, String id) async {
      final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final responderId = payload['responderId'] as String? ?? 'local-user';
      final response = store.respondToRequest(
        requestId: id,
        responderId: responderId,
      );
      if (response == null) {
        return _jsonResponse({'error': 'request_not_found'}, statusCode: 404);
      }
      final updatedRequest = store.getRequest(id);
      return _jsonResponse({
        'response': response.toJson(),
        'request': updatedRequest?.toJson(),
      });
    });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);

  return io.serve(handler, InternetAddress.anyIPv4, port);
}

Middleware _cors() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'access-control-allow-origin': '*',
            'access-control-allow-methods': 'GET, POST, OPTIONS',
            'access-control-allow-headers': 'content-type',
          },
        );
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        ...response.headers,
        'access-control-allow-origin': '*',
      });
    };
  };
}

Response _jsonResponse(Object body, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json'},
  );
}

RequestCompensation _parseCompensation(String? value) {
  return value == 'paid' ? RequestCompensation.paid : RequestCompensation.free;
}

RequestUrgency _parseUrgency(String? value) {
  switch (value) {
    case 'urgent':
      return RequestUrgency.urgent;
    case 'low':
      return RequestUrgency.low;
    default:
      return RequestUrgency.normal;
  }
}
