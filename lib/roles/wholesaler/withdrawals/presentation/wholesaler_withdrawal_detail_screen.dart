import '../../../../shared/widgets/placeholder_screen.dart';

class WholesalerWithdrawalDetailScreen extends PlaceholderScreen {
  const WholesalerWithdrawalDetailScreen({
    super.key,
    required String withdrawalId,
  }) : super(
         title: 'Withdrawal Detail',
         description: 'Wholesaler withdrawal ID: $withdrawalId.',
       );
}
