import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_status.dart';

final connectivityControllerProvider =
    NotifierProvider<ConnectivityController, NetworkStatus>(
      ConnectivityController.new,
    );

class ConnectivityController extends Notifier<NetworkStatus> {
  @override
  NetworkStatus build() => NetworkStatus.online;

  void setStatus(NetworkStatus status) {
    state = status;
  }
}
