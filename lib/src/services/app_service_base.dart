import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart' hide debugPrint;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../utils.dart';

abstract class AppServiceBase<StateT> extends StateController<StateT> {
  AppServiceBase(super.state) {
    $setLoggingStyle();
  }

  Completer<void>? _completer;

  /// Initializes the service.
  ///
  /// It can be called multiple times but it will [bootstrap] only once.
  /// Returns 'false' if [bootstrap] is already called before.
  Future<bool> initialize() async {
    if (_completer != null) {
      return _completer!.future.then((value) => false);
    }

    _completer ??= Completer<void>();
    await bootstrap();
    _completer!.complete();
    return true;
  }

  /// Bootstraps the service.
  ///
  /// It will be called only once in [initialize] method and should be implemented by the child class.
  @protected
  Future<void> bootstrap();

  @protected
  Logger get logger;

  @protected
  void $setLoggingStyle() {
    debug(() {
      final logger = this.logger.parent ?? Logger.root;

      hierarchicalLoggingEnabled = true;
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

  /// Logs the name of caller and [arguments] if any.
  ///
  /// It is used for debug purpose.
  void trace([
    List<dynamic> arguments = const [],
  ]) {
    logger.fine(
      '[${Trace.current(1).frames[0].member?.split('.').last}(${arguments.map((e) => e.toString()).join(',')})]',
    );
  }

  String? get currentFunctionName =>
      Trace.current(1).frames[0].member?.split('.').last;

  /// Prints the [object] to the console.
  ///
  /// If [object] is a json object, log the formatted string.
  void debugPrint(Object? object, {int? wrapWidth}) {
    const encoder = JsonEncoder.withIndent('  ');
    return foundation.debugPrint(
      switch (object) {
        String() => object,
        Map<String, dynamic>() => encoder.convert(object),
        _ => object?.toString(),
      },
      wrapWidth: wrapWidth,
    );
  }

  @override
  @protected
  StateT update(StateT Function(StateT state) cb) => super.update(cb);

  @override
  @protected
  set state(StateT value) => super.state = value;
}
