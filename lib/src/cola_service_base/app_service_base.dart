import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

abstract class AppServiceBase<State> extends StateController<State> {
  AppServiceBase(super.state);

  @protected
  Logger get logger;

  /// Logs the name of [function] and [arguments] if any.
  ///
  /// It is used for debug purpose.
  @protected
  void trace(
    Function function, [
    List<dynamic> arguments = const [],
  ]) {
    logger.fine(
      '[${function.toString().split('\'')[1].trim()}(${arguments.map((e) => e.toString()).join(',')})]',
    );
  }

  @override
  @protected
  State update(State Function(State state) cb) => super.update(cb);

  @override
  @protected
  set state(State value) => super.state = value;
}
