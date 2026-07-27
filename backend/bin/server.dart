import 'dart:io';

import 'package:my_ryadom_backend/src/server.dart';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await serveRyadomApi(port: port);
  stdout.writeln('Мы Рядом backend running on http://${server.address.host}:$port');
}
