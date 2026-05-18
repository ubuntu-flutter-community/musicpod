import 'package:flutter_it/flutter_it.dart';

class NoErrorFilter extends ErrorFilter {
  @override
  ErrorReaction filter(Object error, StackTrace stackTrace) =>
      ErrorReaction.throwException;
}
