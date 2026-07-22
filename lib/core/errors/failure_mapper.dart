import 'app_failure.dart';

class FailureMapper {
  const FailureMapper._();

  static AppFailure fromObject(Object error) {
    return AppFailure(error.toString());
  }
}
