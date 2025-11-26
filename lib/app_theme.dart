import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';

class AppTheme extends ChangeNotifier {
  Color _uxPageBackground = AppStyles.uxPageBackground;
  Color _uxPrimaryText = AppStyles.uxPrimaryText;
  Color _uxSubscriptionColor = AppStyles.uxSubscriptionColor;
  Color _uxReservationColor = AppStyles.uxReservationColor;

  Color get uxPageBackground => _uxPageBackground;
  Color get uxPrimaryText => _uxPrimaryText;
  Color get uxSubscriptionColor => _uxSubscriptionColor;
  Color get uxReservationColor => _uxReservationColor;

  double _startHour = 8.0;
  double _endHour = 24.0;

  double get startHour => _startHour;
  double get endHour => _endHour;

  int _numberOfCourts = 2;
  int get numberOfCourts => _numberOfCourts;

  void updateUxPageBackground(Color color) {
    _uxPageBackground = color;
    notifyListeners();
  }
  
  void updateNumberOfCourts(int count) {
    _numberOfCourts = count;
    notifyListeners();
  }

  void updateUxPrimaryText(Color color) {
    _uxPrimaryText = color;
    notifyListeners();
  }

  void updateUxSubscriptionColor(Color color) {
    _uxSubscriptionColor = color;
    notifyListeners();
  }

  void updateUxReservationColor(Color color) {
    _uxReservationColor = color;
    notifyListeners();
  }

  void updateStartHour(double hour) {
    _startHour = hour;
    notifyListeners();
  }

  void updateEndHour(double hour) {
    _endHour = hour;
    notifyListeners();
  }
}
