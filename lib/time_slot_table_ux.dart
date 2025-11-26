import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:padel_one/reservation_form.dart';
import 'package:padel_one/widgets/court_column.dart';
import 'package:padel_one/widgets/hour_column.dart';
import 'package:padel_one/widgets/time_table_header.dart';
import 'package:padel_one/widgets/time_table_footer.dart';
import 'package:padel_one/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:padel_one/widgets/dialogs/reservation_details_dialog.dart';
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
  Map<int, List<Map<String, dynamic>>> _reservationsByCourt = {};
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
    final theme = Provider.of<AppTheme>(context, listen: false);
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
      final newReservationsByCourt = <int, List<Map<String, dynamic>>>{};
      for (int i = 1; i <= theme.numberOfCourts; i++) {
        newReservationsByCourt[i] =
            todayReservations.where((res) => res['teren'] == i).toList();
      }
      setState(() {
        _reservationsByCourt = newReservationsByCourt;
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
      builder: (ctx) => DeleteConfirmationDialog(
        reservationId: reservationId,
        onDelete: _deleteReservation,
      ),
    );
  }

  void _showReservationDetails(BuildContext context, dynamic reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReservationDetailsDialog(
          reservation: reservation,
          onEdit: () {
            _navigateToReservationForm(0, 0,
                isEditing: true, reservation: reservation);
          },
          onDelete: () {
            _showDeleteConfirmation(context, reservation['id']);
          },
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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final int hourCount = (theme.endHour - theme.startHour).ceil();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

        return Column(
          children: [
            TimeTableHeader(numberOfCourts: theme.numberOfCourts),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 70.0,
                                        child: HourColumn(
                                          hourCount: hourCount,
                                          startHour: theme.startHour,
                                          rowHeight: _rowHeight,
                                        ),
                                      ),
                                      ...List.generate(theme.numberOfCourts, (index) {
                                        final courtNum = index + 1;
                                        return Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: hourCount * _rowHeight,
                                            decoration: const BoxDecoration(
                                              border: Border(right: BorderSide(color: AppStyles.uxDividerColor)),
                                            ),
                                            child: CourtColumn(
                                              courtNum: courtNum,
                                              reservations: _reservationsByCourt[courtNum] ?? [],
                                              startHour: theme.startHour,
                                              rowHeight: _rowHeight,
                                              onEmptySlotTap: _navigateToReservationForm,
                                              onReservationTap: (res) => _showReservationDetails(context, res),
                                            ),
                                          ),
                                        );
                                      }),
                  ],
                ),
              ),
            ),
            TimeTableFooter(totalHoursReservedToday: _totalHoursReservedToday),
          ],
        );
      }
}