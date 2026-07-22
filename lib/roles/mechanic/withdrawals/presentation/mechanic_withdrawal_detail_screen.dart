import '../../../../shared/widgets/placeholder_screen.dart';

class MechanicWithdrawalDetailScreen extends PlaceholderScreen {
  const MechanicWithdrawalDetailScreen({
    super.key,
    required String withdrawalId,
  }) : super(
         title: 'Withdrawal Detail',
         description: 'Mechanic withdrawal ID: $withdrawalId.',
       );
}
