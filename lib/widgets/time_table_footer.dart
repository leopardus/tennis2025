
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:provider/provider.dart';

class TimeTableFooter extends StatelessWidget {
  final double totalHoursReservedToday;

  const TimeTableFooter({
    super.key,
    required this.totalHoursReservedToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    return Container(
      color: AppStyles.uxHeaderBackground,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          'Total Ore Rezervate Azi: ${totalHoursReservedToday.toStringAsFixed(1)}',
          style: TextStyle(
              color: theme.uxPrimaryText, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
