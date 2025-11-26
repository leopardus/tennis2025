
import 'package:flutter/material.dart';
import 'package:padel_one/app_theme.dart';
import 'package:padel_one/widgets/reservation_widget.dart';
import 'package:provider/provider.dart';

class CourtColumn extends StatelessWidget {
  final int courtNum;
  final List<Map<String, dynamic>> reservations;
  final double startHour;
  final double rowHeight;
  final Function(double, int) onEmptySlotTap;
  final Function(Map<String, dynamic>) onReservationTap;

  const CourtColumn({
    super.key,
    required this.courtNum,
    required this.reservations,
    required this.startHour,
    required this.rowHeight,
    required this.onEmptySlotTap,
    required this.onReservationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) {
              final double y = details.localPosition.dy;
              final double hour = startHour + (y / rowHeight);
              final double slot = (hour * 2).round() / 2;
              if (slot < theme.endHour) {
                onEmptySlotTap(slot, courtNum);
              }
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        ...reservations.map((res) {
          return ReservationWidget(
            reservation: res,
            startHour: startHour,
            rowHeight: rowHeight,
            onTap: () => onReservationTap(res),
          );
        }).toList(),
      ],
    );
  }
}
