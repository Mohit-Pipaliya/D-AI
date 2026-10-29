import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../utils/logger.dart';

/// Single parsed Server-Sent Event (SSE) message.
class ServerSentEvent {
  const ServerSentEvent({
    this.event = 'message',
    this.data = '',
    this.id,
    this.retry,
  });

  final String event;
  final String data;
  final String? id;
  final int? retry;

  @override
  String toString() => 'ServerSentEvent(event: $event, data: $data, id: $id)';
}

/// Client for consuming Server-Sent Events (SSE) over HTTP streaming.
class SseClient {
  const SseClient(this._dio);

  final Dio _dio;

  /// Connects to an SSE endpoint and yields parsed [ServerSentEvent] instances.
  Stream<ServerSentEvent> connect({
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async* {
    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        path,
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            ...?headers,
          },
        ),
      );
    } on DioException catch (e) {
      AppLogger.e('SSE connection failed: $path', error: e);
      throw NetworkException(
        e.message ?? 'Failed to connect to SSE stream',
        statusCode: e.response?.statusCode,
      );
    }

    final stream = response.data?.stream;
    if (stream == null) {
      throw const NetworkException('SSE response stream was null');
    }

    String buffer = '';
    String currentEvent = 'message';
    String currentData = '';
    String? currentId;

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);

      while (buffer.contains('\n')) {
        final lineEnd = buffer.indexOf('\n');
        final rawLine = buffer.substring(0, lineEnd);
        buffer = buffer.substring(lineEnd + 1);

        final line = rawLine.endsWith('\r')
            ? rawLine.substring(0, rawLine.length - 1)
            : rawLine;

        if (line.isEmpty) {
          // Empty line indicates end of an event block
          if (currentData.isNotEmpty) {
            yield ServerSentEvent(
              event: currentEvent,
              data: currentData.endsWith('\n')
                  ? currentData.substring(0, currentData.length - 1)
                  : currentData,
              id: currentId,
            );
            currentEvent = 'message';
            currentData = '';
            currentId = null;
          }
          continue;
        }

        if (line.startsWith(':')) {
          // Comment line — ignore
          continue;
        }

        final colonIndex = line.indexOf(':');
        if (colonIndex == -1) {
          // Field name with empty value
          continue;
        }

        final field = line.substring(0, colonIndex).trim();
        var value = line.substring(colonIndex + 1);
        if (value.startsWith(' ')) {
          value = value.substring(1);
        }

        switch (field) {
          case 'event':
            currentEvent = value;
          case 'data':
            currentData += '$value\n';
          case 'id':
            currentId = value;
        }
      }
    }

    // Flush any remaining trailing event
    if (currentData.isNotEmpty) {
      yield ServerSentEvent(
        event: currentEvent,
        data: currentData.endsWith('\n')
            ? currentData.substring(0, currentData.length - 1)
            : currentData,
        id: currentId,
      );
    }
  }
}
