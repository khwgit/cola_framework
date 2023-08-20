import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../utils.dart';
import 'app_state_base.dart';

class JsonLog {
  const JsonLog(
    this.json, [
    this.title = '',
  ]);

  final Map<String, dynamic>? json;
  final String title;
}

abstract class AppServiceBase<State extends AppStateBase>
    extends StateController<State> {
  AppServiceBase(super.state) {
    setLoggingStyle();
  }

  @protected
  Logger get logger;

  @protected
  void setLoggingStyle() {
    debug(() {
      hierarchicalLoggingEnabled = true;

      const encoder = JsonEncoder.withIndent('  ');
      final logger = this.logger.parent ?? Logger.root;
      if (kDebugMode) {
        recordStackTraceAtLevel = Level.SEVERE;
        logger.level = Level.ALL;
      }

      logger.onRecord.listen((record) {
        // Refernce: https://en.wikipedia.org/wiki/ANSI_escape_code
        const end = '\x1b[0m';
        final start = switch (record.level.name) {
          'INFO' => '\x1b[34m',
          'WARNING' => '\x1b[33m',
          'SEVERE' => '\x1b[103m\x1b[31m',
          'SHOUT' => '\x1b[41m\x1b[93m',
          _ => '\x1b[90m',
        };

        final object = record.object;
        if (kIsWeb && object is JsonLog) {
          log(
            '$start${object.title}$end',
            time: record.time,
            sequenceNumber: record.sequenceNumber,
            level: record.level.value,
            name: record.loggerName,
            zone: record.zone,
            error: record.error,
            stackTrace: record.stackTrace,
          );
          final message = encoder
              .convert(object.json)
              .split('\n')
              .map((p) => '$start$p$end')
              .join('\n');
          debugPrint(message);
        } else {
          log(
            '$start${record.message}$end',
            time: record.time,
            sequenceNumber: record.sequenceNumber,
            level: record.level.value,
            name: record.loggerName,
            zone: record.zone,
            error: record.error,
            stackTrace: record.stackTrace,
          );
        }

        if (record.level >= Level.SEVERE) {
          final error = record.error;
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(
              exception: error is Exception ? error : Exception(error),
              stack: record.stackTrace,
              library: record.loggerName,
              context: ErrorDescription(record.message),
            ),
          );
        }
      });
    });
  }

  /// Logs the name of [function] and [arguments] if any.
  ///
  /// It is used for debug purpose.
  @protected
  void trace([
    List<dynamic> arguments = const [],
  ]) {
    logger.fine(
      '[${Trace.current(1).frames[0].member?.split('.').last}(${arguments.map((e) => e.toString()).join(',')})]',
    );
  }

  @override
  @protected
  State update(State Function(State state) cb) => super.update(cb);

  @override
  @protected
  set state(State value) => super.state = value;
}
