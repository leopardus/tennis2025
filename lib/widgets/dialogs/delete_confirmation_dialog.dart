
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String reservationId;
  final Function(String) onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.reservationId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmare Stergere', style: AppStyles.dialogTitle),
      content:
          const Text('Sunteti sigur ca doriti sa stergeti aceasta rezervare?'),
      actions: [
        TextButton(
          child: const Text('Anuleaza'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Sterge',
              style: TextStyle(color: AppStyles.destructiveAction)),
          onPressed: () {
            onDelete(reservationId);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
