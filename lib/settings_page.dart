import 'package:flutter/material.dart';
import 'package:padel_one/app_theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Color> _predefinedColors = [
    Colors.blue.shade50, Colors.blue.shade100, Colors.blue.shade200, Colors.blue.shade900,
    Colors.grey.shade200, Colors.grey.shade300, Colors.grey.shade800, Colors.grey.shade900,
    Colors.orange.shade100, Colors.teal.shade100, Colors.purple.shade100, Colors.red.shade100,
    Colors.white, Colors.black,
  ];

  final List<double> _possibleHours = List.generate(49, (index) => index * 0.5);

  String _formatHour(double hour) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void _showHourPicker(BuildContext context, String title, double currentHour, Function(double) onHourSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _possibleHours.length,
              itemBuilder: (context, index) {
                final hour = _possibleHours[index];
                return ListTile(
                  title: Text(_formatHour(hour)),
                  onTap: () {
                    onHourSelected(hour);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Anuleaza'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selectati o culoare'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _predefinedColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: currentColor == color ? Colors.black : Colors.grey,
                        width: currentColor == color ? 3.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Anuleaza'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder: (context, theme, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Setari'),
          ),
          body: ListView(
            children: [
              _buildColorSettingTile(
                label: 'Programari culoare fundal',
                color: theme.uxPageBackground,
                onTap: () {
                  _showColorPicker(context, theme.uxPageBackground, (color) {
                    theme.updateUxPageBackground(color);
                  });
                },
              ),
              _buildColorSettingTile(
                label: 'Programari culoare text',
                color: theme.uxPrimaryText,
                onTap: () {
                  _showColorPicker(context, theme.uxPrimaryText, (color) {
                    theme.updateUxPrimaryText(color);
                  });
                },
              ),
              _buildColorSettingTile(
                label: 'Programari culoare card abonament',
                color: theme.uxSubscriptionColor,
                onTap: () {
                  _showColorPicker(context, theme.uxSubscriptionColor, (color) {
                    theme.updateUxSubscriptionColor(color);
                  });
                },
              ),
              _buildColorSettingTile(
                label: 'Programari culoare card unica',
                color: theme.uxReservationColor,
                onTap: () {
                  _showColorPicker(context, theme.uxReservationColor, (color) {
                    theme.updateUxReservationColor(color);
                  });
                },
              ),
              const Divider(),
              _buildTimeSettingTile(
                label: 'Ora de inceput',
                hour: theme.startHour,
                onTap: () {
                  _showHourPicker(context, 'Selectati ora de inceput', theme.startHour, (hour) {
                    theme.updateStartHour(hour);
                  });
                },
              ),
              _buildTimeSettingTile(
                label: 'Ora de sfarsit',
                hour: theme.endHour,
                onTap: () {
                  _showHourPicker(context, 'Selectati ora de sfarsit', theme.endHour, (hour) {
                    theme.updateEndHour(hour);
                  });
                },
              ),
              const Divider(),
              _buildCourtNumberSettingTile(
                label: 'Numar terenuri',
                currentValue: theme.numberOfCourts,
                onChanged: (newValue) {
                  if (newValue != null) {
                    theme.updateNumberOfCourts(newValue);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourtNumberSettingTile({
    required String label,
    required int currentValue,
    required ValueChanged<int?> onChanged,
  }) {
    return ListTile(
      title: Text(label),
      trailing: DropdownButton<int>(
        value: currentValue,
        items: [2, 3, 4, 5].map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimeSettingTile({
    required String label,
    required double hour,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        _formatHour(hour),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  Widget _buildColorSettingTile({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTap: onTap,
    );
  }
}
