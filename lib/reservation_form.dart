import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_one/app_styles.dart';

class ReservationForm extends StatefulWidget {
  // For creating a new reservation
  final double? initialHour; // Changed to double
  final int? initialTeren;
  final DateTime? date;

  // For editing an existing reservation
  final Map<String, dynamic>? initialReservation;

  const ReservationForm({
    super.key,
    this.initialHour,
    this.initialTeren,
    this.date,
    this.initialReservation,
  }) : assert(
            (initialHour != null && initialTeren != null && date != null) ||
                initialReservation != null);

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  late double _startHour; // Changed to double
  late double _endHour;   // Changed to double
  late int _teren;
  late String _personName;
  late TextEditingController _nameController;
  bool _isSubscription = false;
  DateTime? _subscriptionEndDate;

  bool get isEditing => widget.initialReservation != null;

  // Generate time slots from 8:00 to 23:30
  final List<double> availableTimes = List.generate(32, (index) => 8.0 + index * 0.5);

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final reservation = widget.initialReservation!;
      _startHour = (reservation['interval'][0] as num).toDouble();
      _endHour = (reservation['interval'][1] as num).toDouble();
      _teren = reservation['teren'];
      _personName = reservation['person'];
      _isSubscription = reservation['isSubscription'] ?? false;
      _subscriptionEndDate = reservation['subscriptionEndDate'] != null
          ? DateTime.parse(reservation['subscriptionEndDate'])
          : null;
    } else {
      _startHour = widget.initialHour!;
      _endHour = widget.initialHour! + 1.0; // Default to 1-hour reservation
      _teren = widget.initialTeren!;
      _personName = '';
      _isSubscription = false;
    }
    _nameController = TextEditingController(text: _personName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatHour(double hour) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _subscriptionEndDate ?? (widget.date ?? DateTime.now()).add(const Duration(days: 7)),
      firstDate: (widget.date ?? DateTime.now()).add(const Duration(days: 7)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _subscriptionEndDate) {
      setState(() {
        _subscriptionEndDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_startHour >= _endHour) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Ora de sfarsit trebuie sa fie dupa ora de inceput!')),
        );
        return;
      }

      if (_isSubscription && _subscriptionEndDate == null && !isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pentru abonament, va rugam selectati o data de sfarsit!')),
        );
        return;
      }

      final result = {
        'teren': _teren,
        'interval': [_startHour, _endHour],
        'person': _personName,
        'date': isEditing
            ? widget.initialReservation!['date']
            : DateFormat('dd/MM/yyyy').format(widget.date!),
        'id': isEditing ? widget.initialReservation!['id'] : null,
        'isSubscription': _isSubscription,
        'subscriptionEndDate': _isSubscription && _subscriptionEndDate != null
            ? _subscriptionEndDate!.toIso8601String()
            : null,
      };

      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editare Rezervare' : 'Creaza Rezervare'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _teren,
                decoration: const InputDecoration(labelText: 'Teren'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Teren 1')),
                  DropdownMenuItem(value: 2, child: Text('Teren 2')),
                ],
                onChanged: (value) {
                  setState(() {
                    _teren = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _startHour,
                decoration: const InputDecoration(labelText: 'Ora inceput'),
                items: availableTimes.where((time) => time < 23.5).map((hour) { // Cannot start at 23:30 for a 30-min slot
                  return DropdownMenuItem(value: hour, child: Text(_formatHour(hour)));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _startHour = value!;
                    if (_startHour >= _endHour) {
                      _endHour = _startHour + 0.5;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _endHour,
                decoration: const InputDecoration(labelText: 'Ora sfarsit'),
                items: availableTimes.where((time) => time > 8.0).map((hour) {
                  return DropdownMenuItem(
                      value: hour, child: Text(_formatHour(hour)));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _endHour = value!;
                  });
                },
                validator: (value) {
                  if (value != null && value <= _startHour) {
                    return 'Ora de sfarsit trebuie sa fie dupa ora de inceput';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nume persoana'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduceti un nume';
                  }
                  return null;
                },
                onSaved: (value) {
                  _personName = value!;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Abonament'),
                value: _isSubscription,
                onChanged: isEditing ? null : (bool? value) {
                  setState(() {
                    _isSubscription = value ?? false;
                    if (!_isSubscription) {
                      _subscriptionEndDate = null;
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (_isSubscription && !isEditing)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pana la data',
                      ),
                      child: Text(
                        _subscriptionEndDate == null
                            ? 'Selectati data'
                            : DateFormat('dd/MM/yyyy').format(_subscriptionEndDate!),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  foregroundColor: AppStyles.lightText,
                ),
                child: const Text('Salveaza'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}