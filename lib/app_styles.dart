import 'package:flutter/material.dart';

class AppStyles {
  // --- Colors ---

  // Primary & Theme Colors
  static const Color primaryColor = Colors.deepOrange;
  static const Color accentColor = Colors.purple;

  // Background Colors
  static const Color pageBackground = Color.fromARGB(255, 240, 240, 240); // Light Grey
  static const Color cardBackground = Color.fromARGB(255, 243, 243, 243);
  
  // Reservation Colors
  static const Color reservationColor = Color.fromARGB(255, 65, 65, 65);
  static const Color subscriptionColor = Color.fromARGB(255, 63, 63, 63);

  // Text & Icon Colors
  static const Color lightText = Colors.white;
  static const Color darkText = Color.fromARGB(255, 36, 36, 36);
  static const Color secondaryText = Color(0xFF757575); // Colors.grey[600]
  static const Color buttonText = Color(0xFF424242); // Colors.grey[800]
  static const Color destructiveAction = Colors.red;
  static const Color todayButtonText = Color.fromARGB(255, 7, 78, 83);
  static const Color carouselHeaderBackground = Color(0xFFDDDDDD);

  // Border & Divider Colors
  static const Color borderColor = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color dividerColor = Colors.grey;
  static const Color reportsCardBorder = Colors.grey; // Standard Grey
  static const double reportsCardBorderWidth = 2.0;
  static const double reportsCardCornerRadius = 4.0;

  // Chart Colors
  static const Color chartLineColor = Colors.grey;
  static const Color chartAreaColor = Color(0xFFE0E0E0); // Light grey for area
  static const double reportsChartLineWidth = 2.0;

  // --- Drawer Theme ---
  static const Color drawerHeaderBackground = Color(0xFF424242); // Colors.grey[800]
  static const Color drawerTextColor = Colors.white;
  static const Color drawerIconColor = Color(0xFF757575); // Colors.grey[600]

  // --- UX Blue Theme ---
  static const Color uxPageBackground = Color(0xFFE3F2FD); // Colors.blue[50]
  static const Color uxCardBackground = Colors.white;
  static const Color uxHeaderBackground = Color(0xFF90CAF9); // Colors.blue[200]
  static const Color uxPrimaryText = Color(0xFF0D47A1); // Colors.blue[900]
  static const Color uxSecondaryText = Color(0xFF1565C0); // Colors.blue[800]
  static const Color uxDividerColor = Color(0xFFBBDEFB); // Colors.blue[100]
  static const Color uxReservationColor = Color(0xFFE3F2FD); // Very light blue (Colors.blue[50])
  static const Color uxSubscriptionColor = Color(0xFFBBDEFB); // Light blue (Colors.blue[100])
  static const Color uxReservationCardBorder = Color(0xFFBBDEFB); // Paler blue (Colors.blue[100])
  static const double uxReservationCardBorderWidth = 1.0;
  static const double uxReservationCardCornerRadius = 2.0;
  static const Color uxAvailableTextColor = Color(0xFFE0F2F7); // Very light blue, almost invisible

  // --- Text Styles ---

  // Font Sizes
  static const double fontSizeLarge = 24.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeNormal = 14.0;
  static const double fontSizeSmall = 12.0;

  // Specific TextStyles
  static const TextStyle pageTitle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.bold,
    color: darkText,
  );

  static const TextStyle tableHeader = TextStyle(
    fontWeight: FontWeight.bold,
    color: lightText,
  );
  
  static const TextStyle tableHeaderNormal = TextStyle(
    color: lightText,
  );
  
  static const TextStyle tableHeaderDarkText = TextStyle(
    color: darkText,
  );
  
  static const TextStyle dialogTitle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.bold,
    color: darkText,
  );
}
