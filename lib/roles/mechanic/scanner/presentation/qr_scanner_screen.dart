import '../../../../shared/widgets/placeholder_screen.dart';

class QrScannerScreen extends PlaceholderScreen {
  const QrScannerScreen({super.key})
    : super(
        title: 'Scan QR',
        description:
            'Online-only scanner surface. Internet is required to scan a QR. Please reconnect and try again.',
      );
}
