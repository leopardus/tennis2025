
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:padel_one/widgets/hour_column.dart';
import 'package:provider/provider.dart';

class ReservationWidget extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final double startHour;
  final double rowHeight;
  final VoidCallback onTap;

  const ReservationWidget({
    super.key,
    required this.reservation,
    required this.startHour,
    required this.rowHeight,
    required this.onTap,
  });

  String _getReservationDisplayText(dynamic reservation) {
    if (reservation == null) return '';
    String displayName = reservation['person'];
    if (reservation['isSubscription'] == true) {
      displayName += ' [A]';
    }
    return displayName;
  }

  String _formatDuration(double duration) {
    final int hours = duration.floor();
    final int minutes = ((duration - hours) * 60).round();
    String result = '';
    if (hours > 0) {
      result += '${hours}h';
    }
    if (minutes > 0) {
      result += '${minutes}m';
    }
    if (result.isEmpty) {
      return '0m';
    }
    return result;
  }

  String _formatHour(double hour) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final double start = (reservation['interval'][0] as num).toDouble();
    final double end = (reservation['interval'][1] as num).toDouble();
    final double duration = end - start;

    return Positioned(
      top: (start - startHour) * rowHeight + 5.0,
      left: 0,
      right: 0,
      height: (end - start) * rowHeight,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: reservation['isSubscription'] == true
                ? theme.uxSubscriptionColor
                : theme.uxReservationColor,
            borderRadius:
                BorderRadius.circular(AppStyles.uxReservationCardCornerRadius),
            border: Border.all(
              color: AppStyles.uxReservationCardBorder,
              width: AppStyles.uxReservationCardBorderWidth,
            ),
          ),
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(0.0),
          child: Align(
            // Use Align for left alignment
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align children to the start
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center vertically if space allows
              children: [
                Text(
                  'Ora start: ${_formatHour(start)}, Durata: ${_formatDuration(duration)}',
                  style: TextStyle(
                      color: theme.uxPrimaryText,
                      fontSize: AppStyles.fontSizeSmall),
                  textAlign: TextAlign.left,
                ),
                Text(
                  'Nume: ${_getReservationDisplayText(reservation)}',
                  style: TextStyle(
                      color: theme.uxPrimaryText,
                      fontSize: AppStyles.fontSizeSmall),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
