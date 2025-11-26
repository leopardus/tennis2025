
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:padel_one/widgets/hour_column.dart';
import 'package:provider/provider.dart';

class ReservationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReservationDetailsDialog({
    super.key,
    required this.reservation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context, listen: false);
    final start = (reservation['interval'][0] as num).toDouble();
    final end = (reservation['interval'][1] as num).toDouble();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: AppStyles.uxCardBackground,
      titlePadding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
      title: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0),
            child: Text('Detalii rezervare',
                style: TextStyle(
                    color: theme.uxPrimaryText, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: -10,
            right: -12,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppStyles.destructiveAction),
              onPressed: () {
                Navigator.of(context).pop(); // Close details dialog
                onDelete();
              },
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Persoana: ${reservation['person']}',
              style: TextStyle(color: theme.uxPrimaryText)),
          Text('Teren: ${reservation['teren']}',
              style: TextStyle(color: theme.uxPrimaryText)),
          Text(
              'Interval: ${HourColumn.formatHour(start)} - ${HourColumn.formatHour(end)}',
              style: TextStyle(color: theme.uxPrimaryText)),
          if (reservation['isSubscription'] == true)
            Text('Tipul: Abonament',
                style: TextStyle(color: theme.uxPrimaryText)),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.uxPrimaryText),
          child: const Text('Inchide'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.uxPrimaryText),
          child: const Text('Editare'),
          onPressed: () {
            Navigator.of(context).pop(); // Close details dialog
            onEdit();
          },
        ),
      ],
    );
  }
}
