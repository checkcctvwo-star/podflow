import 'package:dio/dio.dart';

import '../../domain/services/download_service.dart';

class DioDownloadService implements DownloadService {
  final Dio _dio;

  DioDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<void> download({
    required String url,
    required String destinationPath,
    required void Function(double progress) onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        destinationPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );
    } on DioException catch (e) {
      throw DownloadException(e.message ?? 'Download failed: ${e.type}');
    }
  }
}

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);

  @override
  String toString() => 'DownloadException: $message';
}
