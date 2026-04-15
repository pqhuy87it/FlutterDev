import 'package:flutter/material.dart';

// Enum EventType
enum EventType {
  error('‼️'),
  info('ℹ️'),
  debug('📍'),
  verbose('🔶'),
  warning('⚠️'),
  severe('🔥');

  final String emoji;
  const EventType(this.emoji);
}

// Model log
class LogModel {
  final String timestamp;
  final String message;
  final EventType event;

  LogModel({
    required this.timestamp,
    required this.message,
    required this.event,
  });

  // Helper display full message
  String get fullDisplay => "[$timestamp] ${event.emoji} $message";
}

// Logger Singleton
class AppDebugLogger {
  AppDebugLogger._();
  static final instance = AppDebugLogger._();

  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  void log(dynamic message, {EventType event = EventType.info}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);

    final newLog = LogModel(
      timestamp: timestamp,
      message: message.toString(),
      event: event,
    );

    logsNotifier.value = [newLog, ...logsNotifier.value];

    if (logsNotifier.value.length > 200) {
      logsNotifier.value = logsNotifier.value.sublist(0, 200);
    }
  }

  void clear() {
    logsNotifier.value = [];
  }
}