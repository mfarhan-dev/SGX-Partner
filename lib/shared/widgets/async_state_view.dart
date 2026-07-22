import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'offline_state.dart';

enum AsyncViewState { loading, content, empty, error, offline }

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.state,
    required this.child,
    this.onRetry,
    this.emptyMessage = 'Nothing to show yet.',
    this.errorMessage = 'Something went wrong.',
    this.offlineMessage = 'You are offline. Please reconnect and try again.',
  });

  final AsyncViewState state;
  final Widget child;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final String errorMessage;
  final String offlineMessage;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AsyncViewState.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      AsyncViewState.content => child,
      AsyncViewState.empty => EmptyState(message: emptyMessage),
      AsyncViewState.error => ErrorState(
        message: errorMessage,
        onRetry: onRetry,
      ),
      AsyncViewState.offline => OfflineState(
        message: offlineMessage,
        onRetry: onRetry,
      ),
    };
  }
}
