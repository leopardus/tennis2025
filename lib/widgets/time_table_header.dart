
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:provider/provider.dart';

class TimeTableHeader extends StatelessWidget {
  final int numberOfCourts;
  const TimeTableHeader({super.key, required this.numberOfCourts});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    return Container(
      color: AppStyles.uxHeaderBackground,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
              width: 70.0,
              child: Center(
                  child: Text('Ora',
                      style: TextStyle(color: theme.uxPrimaryText)))),
          ...List.generate(numberOfCourts, (index) {
            return Expanded(
                flex: 3,
                child: Center(
                    child: Text('Teren ${index + 1}',
                        style: TextStyle(color: theme.uxPrimaryText))));
          }),
        ],
      ),
    );
  }
}
