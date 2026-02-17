import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Serving at http://localhost:8080');
  await for (final req in server) {
    var path = req.uri.path == '/' ? '/index.html' : req.uri.path;
    final file = File('.' + path);
    if (await file.exists()) {
      final ext = path.split('.').last;
      final types = {
        'html': 'text/html',
        'js': 'application/javascript',
        'json': 'application/json',
        'wasm': 'application/wasm',
        'otf': 'font/otf',
        'ttf': 'font/ttf',
        'png': 'image/png',
      };
      req.response.headers.contentType =
          ContentType.parse(types[ext] ?? 'application/octet-stream');
      await req.response.addStream(file.openRead());
    } else {
      req.response.statusCode = 404;
      req.response.write('Not found');
    }
    await req.response.close();
  }
}
