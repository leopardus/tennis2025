import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:padel_one/reservation_form.dart';
import 'package:provider/provider.dart';

// This list will be populated from the JSON file.
// It remains a global variable to be accessible from the reports page.
List<Map<String, dynamic>> mockReservations = [];

class TimeSlotTableUx extends StatefulWidget {
  final DateTime date;

  const TimeSlotTableUx({super.key, required this.date});

  @override
  State<TimeSlotTableUx> createState() => _TimeSlotTableUxState();
}

class _TimeSlotTableUxState extends State<TimeSlotTableUx> {
  List<Map<String, dynamic>> _reservationsForDayTeren1 = [];
  List<Map<String, dynamic>> _reservationsForDayTeren2 = [];
  double _totalHoursReservedToday = 0;
  bool _isLoading = true;
  static bool _isDataLoaded = false;

  static const double _rowHeight = 40.0; // Represents 1 hour

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TimeSlotTableUx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _processReservationsForDate();
    }
  }

  Future<void> _loadData() async {
    if (_isDataLoaded) {
      _processReservationsForDate();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final String response = await rootBundle.loadString('assets/reservations.json');
      final data = await json.decode(response);
      mockReservations = List<Map<String, dynamic>>.from(data);
      _isDataLoaded = true;
      _processReservationsForDate();
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processReservationsForDate() {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(widget.date);
    final List<Map<String, dynamic>> todayReservations = mockReservations
        .where((res) => res['date'] == formattedDate)
        .toList();

    double totalHours = 0;
    final countedIds = <String>{};

    for (var res in todayReservations) {
      if (!countedIds.contains(res['id'])) {
        final start = (res['interval'][0] as num).toDouble();
        final end = (res['interval'][1] as num).toDouble();
        totalHours += (end - start);
        countedIds.add(res['id']);
      }
    }

    if (mounted) {
      setState(() {
        _reservationsForDayTeren1 = todayReservations.where((res) => res['teren'] == 1).toList();
        _reservationsForDayTeren2 = todayReservations.where((res) => res['teren'] == 2).toList();
        _totalHoursReservedToday = totalHours;
        _isLoading = false;
      });
    }
  }

  void _deleteReservation(String id) {
    mockReservations.removeWhere((res) => res['id'] == id);
    _processReservationsForDate();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Rezervare stearsa!'), backgroundColor: Colors.green),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String reservationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmare Stergere', style: AppStyles.dialogTitle),
        content:
            const Text('Sunteti sigur ca doriti sa stergeti aceasta rezervare?'),
        actions: [
          TextButton(
            child: const Text('Anuleaza'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child:
                const Text('Sterge', style: TextStyle(color: AppStyles.destructiveAction)),
            onPressed: () {
              _deleteReservation(reservationId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  String _formatHour(double hour) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
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

  void _showReservationDetails(BuildContext context, dynamic reservation) {
    final theme = Provider.of<AppTheme>(context, listen: false);
    final start = (reservation['interval'][0] as num).toDouble();
    final end = (reservation['interval'][1] as num).toDouble();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                child: Text('Detalii rezervare', style: TextStyle(color: theme.uxPrimaryText, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: -10,
                right: -12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppStyles.destructiveAction),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close details dialog
                    _showDeleteConfirmation(context, reservation['id']);
                  },
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Persoana: ${reservation['person']}', style: TextStyle(color: theme.uxPrimaryText)),
              Text('Teren: ${reservation['teren']}', style: TextStyle(color: theme.uxPrimaryText)),
              Text(
                  'Interval: ${_formatHour(start)} - ${_formatHour(end)}', style: TextStyle(color: theme.uxPrimaryText)),
              if (reservation['isSubscription'] == true)
                Text('Tipul: Abonament', style: TextStyle(color: theme.uxPrimaryText)),
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
                _navigateToReservationForm(0, 0,
                    isEditing: true, reservation: reservation);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToReservationForm(double hour, int teren, {bool isEditing = false, Map<String, dynamic>? reservation}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationForm(
          initialHour: isEditing ? null : hour,
          initialTeren: isEditing ? null : teren,
          date: isEditing ? null : widget.date,
          initialReservation: isEditing ? reservation : null,
        ),
      ),
    );

    if (result == null) return;

    if (isEditing) {
      final index = mockReservations.indexWhere((res) => res['id'] == result['id']);
      if (index != -1) {
        setState(() {
          mockReservations[index] = result;
          _processReservationsForDate();
        });
      }
    } else {
      final isSubscription = result['isSubscription'] ?? false;
      List<Map<String, dynamic>> reservationsToAdd = [];
      bool conflictFound = false;
      String? conflictDate;

      if (isSubscription && result['subscriptionEndDate'] != null) {
        final subscriptionId = DateTime.now().millisecondsSinceEpoch.toString();
        DateTime currentDate = DateFormat('dd/MM/yyyy').parse(result['date']);
        final DateTime endDate = DateTime.parse(result['subscriptionEndDate']);

        while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
          final newSubReservation = Map<String, dynamic>.from(result);
          newSubReservation['id'] = '${subscriptionId}_${DateFormat('yyyyMMdd').format(currentDate)}';
          newSubReservation['subscriptionId'] = subscriptionId;
          newSubReservation['date'] = DateFormat('dd/MM/yyyy').format(currentDate);
          reservationsToAdd.add(newSubReservation);
          currentDate = currentDate.add(const Duration(days: 7));
        }
      } else {
        result['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        reservationsToAdd.add(result);
      }

      for (final newRes in reservationsToAdd) {
        final double start = (newRes['interval'][0] as num).toDouble();
        final double end = (newRes['interval'][1] as num).toDouble();
        final int court = newRes['teren'];
        final String date = newRes['date'];

        for (final existingRes in mockReservations) {
          if (existingRes['date'] == date && existingRes['teren'] == court) {
            final double existingStart = (existingRes['interval'][0] as num).toDouble();
            final double existingEnd = (existingRes['interval'][1] as num).toDouble();
            if (start < existingEnd && end > existingStart) {
              conflictFound = true;
              conflictDate = date;
              break;
            }
          }
        }
        if (conflictFound) break;
      }

      if (mounted) {
        if (conflictFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Conflict de rezervare gasit pe data de $conflictDate! Nicio rezervare nu a fost adaugata.'),
                backgroundColor: AppStyles.destructiveAction),
          );
        } else {
          mockReservations.addAll(reservationsToAdd);
          _processReservationsForDate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${reservationsToAdd.length} rezervare(i) salvata(e)!'),
                backgroundColor: Colors.green),
          );
        }
      }
    }
  }

  String _getReservationDisplayText(dynamic reservation) {
    if (reservation == null) return '';
    String displayName = reservation['person'];
    if (reservation['isSubscription'] == true) {
      displayName += ' [A]';
    }
    return displayName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final int hourCount = (theme.endHour - theme.startHour).ceil();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

        return Column(
          children: [
            Container(
              color: AppStyles.uxHeaderBackground,
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Row(
                children: [
                                    SizedBox(width: 70.0, child: Center(child: Text('Ora', style: TextStyle(color: theme.uxPrimaryText)))),
                                    Expanded(
                                        flex: 3,
                                        child: Center(
                                            child: Text('Teren 1', style: TextStyle(color: theme.uxPrimaryText)))),
                                    Expanded(
                                        flex: 3,
                                        child: Center(
                                            child: Text('Teren 2', style: TextStyle(color: theme.uxPrimaryText)))),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 70.0, child: _buildHourColumn(hourCount, theme.startHour)),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: hourCount * _rowHeight,
                                            decoration: const BoxDecoration(
                                              border: Border(right: BorderSide(color: AppStyles.uxDividerColor)),
                                            ),
                                            child: _buildCourtColumn(1, _reservationsForDayTeren1, theme.startHour),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: hourCount * _rowHeight,
                                            child: _buildCourtColumn(2, _reservationsForDayTeren2, theme.startHour),
                                          ),
                                        ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppStyles.uxHeaderBackground,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Total Ore Rezervate Azi: ${_totalHoursReservedToday.toStringAsFixed(1)}',
                  style: TextStyle(color: theme.uxPrimaryText, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      }

    
      Widget _buildHourColumn(int hourCount, double startHour) {
        return Stack(
          children: [
            CustomPaint(
              size: Size(70.0, hourCount * _rowHeight),
              painter: _HourLinePainter(
                hourCount: hourCount,
                rowHeight: _rowHeight,
                lineColor: AppStyles.uxDividerColor,
              ),
            ),
            Column(
              children: List.generate(hourCount + 1, (index) { // +1 to include the last hour label
                final hour = startHour + index;
                return Container(
                  height: _rowHeight,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppStyles.uxDividerColor),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 24.0, top: 4.0, right: 4.0, bottom: 4.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    _formatHour(hour),
                    style: const TextStyle(color: AppStyles.uxSecondaryText, fontSize: AppStyles.fontSizeSmall, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ],
        );
      }

    
      Widget _buildCourtColumn(int courtNum, List<Map<String, dynamic>> reservations, double startHour) {
        final theme = Provider.of<AppTheme>(context);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  final double y = details.localPosition.dy;
                  final double hour = startHour + (y / _rowHeight);
                  final double slot = (hour * 2).round() / 2;
                  if (slot < theme.endHour) {
                    _navigateToReservationForm(slot, courtNum);
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            ...reservations.map((res) {
              final double start = (res['interval'][0] as num).toDouble();
              final double end = (res['interval'][1] as num).toDouble();
              final double duration = end - start;

              return Positioned(
                top: (start - startHour) * _rowHeight + 5.0,
                left: 0,
                right: 0,
                height: (end - start) * _rowHeight,
                child: InkWell(
                  onTap: () => _showReservationDetails(context, res),
                  child: Container(
                    decoration: BoxDecoration(
                      color: res['isSubscription'] == true
                          ? theme.uxSubscriptionColor
                          : theme.uxReservationColor,
                      borderRadius: BorderRadius.circular(AppStyles.uxReservationCardCornerRadius),
                      border: Border.all(
                        color: AppStyles.uxReservationCardBorder,
                        width: AppStyles.uxReservationCardBorderWidth,
                      ),
                    ),
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(0.0),
                    child: Align( // Use Align for left alignment
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                        mainAxisAlignment: MainAxisAlignment.center, // Center vertically if space allows
                        children: [
                          Text(
                            'Ora start: ${_formatHour(start)}, Durata: ${_formatDuration(duration)}',
                            style: TextStyle(color: theme.uxPrimaryText, fontSize: AppStyles.fontSizeSmall),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'Nume: ${_getReservationDisplayText(res)}',
                            style: TextStyle(color: theme.uxPrimaryText, fontSize: AppStyles.fontSizeSmall),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }
}

class _HourLinePainter extends CustomPainter {
  final int hourCount;
  final double rowHeight;
  final Color lineColor;

  _HourLinePainter({
    required this.hourCount,
    required this.rowHeight,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5;

    final circlePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double lineX = 12.0;

    for (int i = 0; i < hourCount + 1; i++) { // +1 to include the last hour circle
      final currentY = i * rowHeight + 12.0; 
      canvas.drawCircle(Offset(lineX, currentY), 2.5, circlePaint);

      if (i < hourCount) { // Draw line only between the slots
        final nextY = (i + 1) * rowHeight + 12.0;
        canvas.drawLine(Offset(lineX, currentY + 2.5 + 2.0), Offset(lineX, nextY - 2.5 - 2.0), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HourLinePainter oldDelegate) {
    return oldDelegate.hourCount != hourCount ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.lineColor != lineColor;
  }
}