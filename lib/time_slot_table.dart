import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/reservation_form.dart';

// This list will be populated from the JSON file.
// It remains a global variable to be accessible from the reports page.
List<Map<String, dynamic>> mockReservations = [];

class TimeSlotTable extends StatefulWidget {
  final DateTime date;

  const TimeSlotTable({super.key, required this.date});

  @override
  State<TimeSlotTable> createState() => _TimeSlotTableState();
}

class _TimeSlotTableState extends State<TimeSlotTable> {
  Map<double, dynamic> _reservationsTeren1 = {}; // Changed to Map<double, dynamic>
  Map<double, dynamic> _reservationsTeren2 = {}; // Changed to Map<double, dynamic>
  double _totalHoursReservedToday = 0; // Changed to double
  bool _isLoading = true;
  static bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TimeSlotTable oldWidget) {
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
    final Map<double, dynamic> teren1Reservations = {};
    final Map<double, dynamic> teren2Reservations = {};
    final String formattedDate = DateFormat('dd/MM/yyyy').format(widget.date);
    double totalHours = 0;
    final countedIds = <String>{};

    for (var reservation in mockReservations) {
      if (reservation['date'] == formattedDate) {
        final int teren = reservation['teren'];
        final double startHour = (reservation['interval'][0] as num).toDouble();
        final double endHour = (reservation['interval'][1] as num).toDouble();

        // Calculate total hours
        if (!countedIds.contains(reservation['id'])) {
          totalHours += (endHour - startHour);
          countedIds.add(reservation['id']);
        }

        for (double i = startHour; i < endHour; i += 0.5) {
          if (teren == 1) {
            teren1Reservations[i] = reservation;
          } else if (teren == 2) {
            teren2Reservations[i] = reservation;
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _reservationsTeren1 = teren1Reservations;
        _reservationsTeren2 = teren2Reservations;
        _totalHoursReservedToday = totalHours;
        _isLoading = false;
      });
    }
  }

  void _deleteReservation(String id) {
    // TODO: Add logic to delete subscription series
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

  void _showReservationDetails(BuildContext context, dynamic reservation) {
    final double start = (reservation['interval'][0] as num).toDouble();
    final double end = (reservation['interval'][1] as num).toDouble();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: AppStyles.cardBackground,
          titlePadding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
          title: Stack(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14.0),
                child: Text('Detalii rezervare', style: AppStyles.dialogTitle),
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
              Text('Persoana: ${reservation['person']}'),
              Text('Teren: ${reservation['teren']}'),
              Text('Interval: ${_formatHour(start)} - ${_formatHour(end)}'),
              if (reservation['isSubscription'] == true)
                const Text('Tipul: Abonament'),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppStyles.buttonText),
              child: const Text('Inchide'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppStyles.buttonText),
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
      // Find and update the reservation
      final index = mockReservations.indexWhere((res) => res['id'] == result['id']);
      if (index != -1) {
        setState(() {
          mockReservations[index] = result;
          _processReservationsForDate();
        });
      }
    } else {
      // --- Handle new reservation (single or subscription) ---
      final isSubscription = result['isSubscription'] ?? false;
      List<Map<String, dynamic>> reservationsToAdd = [];
      bool conflictFound = false;
      String? conflictDate;

      if (isSubscription && result['subscriptionEndDate'] != null) {
        // --- Subscription Logic ---
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
        // --- Single Reservation Logic ---
        result['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        reservationsToAdd.add(result);
      }

      // --- Conflict Check for all reservations to be added ---
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

      // --- Final Action ---
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: AppStyles.carouselHeaderBackground,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: const Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Center(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Ora', style: AppStyles.tableHeaderDarkText)))),
              Expanded(
                  flex: 3,
                  child: Center(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Teren 1', style: AppStyles.tableHeaderDarkText)))),
              Expanded(
                  flex: 3,
                  child: Center(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Teren 2', style: AppStyles.tableHeaderDarkText)))),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // This container will fill the background of the Expanded area
              Container(color: AppStyles.darkText),
              ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 32, // 16 hours * 2 slots/hour
                itemBuilder: (context, index) {
                  final double hour = 8.0 + index * 0.5;

                  final dynamic reservationTeren1 = _reservationsTeren1[hour];
                  final bool isOccupiedTeren1 = reservationTeren1 != null;
                  final bool isFirstOccupiedTeren1 = isOccupiedTeren1 &&
                      (_reservationsTeren1[hour - 0.5]?['id'] !=
                          reservationTeren1['id']);
                  
                  final dynamic reservationTeren2 = _reservationsTeren2[hour];
                  final bool isOccupiedTeren2 = reservationTeren2 != null;
                  final bool isFirstOccupiedTeren2 = isOccupiedTeren2 &&
                      (_reservationsTeren2[hour - 0.5]?['id'] !=
                          reservationTeren2['id']);

                  return Container(
                    height: 20, // Half the original row height
                    color: AppStyles.cardBackground, // Each row has its own background
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: AppStyles.dividerColor),
                                bottom: BorderSide(color: AppStyles.dividerColor),
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatHour(hour))),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () => isOccupiedTeren1
                                ? _showReservationDetails(context, reservationTeren1)
                                : _navigateToReservationForm(hour, 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isOccupiedTeren1
                                  ? (reservationTeren1['isSubscription'] == true
                                      ? AppStyles.subscriptionColor
                                      : AppStyles.reservationColor)
                                  : null,
                                border: const Border(
                                    right: BorderSide(color: AppStyles.dividerColor),
                                    bottom: BorderSide(color: AppStyles.dividerColor),
                                ),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isOccupiedTeren1
                                        ? (isFirstOccupiedTeren1 ? _getReservationDisplayText(reservationTeren1) : '')
                                        : 'Disponibil',
                                    style: TextStyle(
                                      color: isOccupiedTeren1
                                          ? AppStyles.lightText
                                          : AppStyles.darkText,
                                      fontWeight: isOccupiedTeren1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () => isOccupiedTeren2
                                ? _showReservationDetails(context, reservationTeren2)
                                : _navigateToReservationForm(hour, 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isOccupiedTeren2
                                  ? (reservationTeren2['isSubscription'] == true
                                      ? AppStyles.subscriptionColor
                                      : AppStyles.reservationColor)
                                  : null,
                                border: const Border(
                                    bottom: BorderSide(color: AppStyles.dividerColor),
                                ),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isOccupiedTeren2
                                        ? (isFirstOccupiedTeren2 ? _getReservationDisplayText(reservationTeren2) : '')
                                        : 'Disponibil',
                                    style: TextStyle(
                                      color: isOccupiedTeren2
                                          ? AppStyles.lightText
                                          : AppStyles.darkText,
                                      fontWeight: isOccupiedTeren2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          color: AppStyles.darkText,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'Total Ore Rezervate Azi: ${_totalHoursReservedToday.toStringAsFixed(1)}',
              style: const TextStyle(color: AppStyles.lightText, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}