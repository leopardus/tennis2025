import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart' as carousel_slider_controller;
import 'package:intl/intl.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/app_theme.dart';
import 'package:padel_one/auth_service.dart';
import 'package:padel_one/login_page.dart';
import 'package:padel_one/padel_time_page.dart';
import 'package:padel_one/reports_page.dart';
import 'package:padel_one/settings_page.dart';
import 'package:padel_one/time_slot_table_ux.dart'; // Use the new UX table
import 'package:padel_one/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class PadelTimeUxPage extends StatefulWidget {
  const PadelTimeUxPage({super.key});

  @override
  State<PadelTimeUxPage> createState() => _PadelTimeUxPageState();
}

class _PadelTimeUxPageState extends State<PadelTimeUxPage> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentPageIndex = 3; // Start with the current day selected

  // Generate a list of 30 days, starting 3 days ago
  final List<DateTime> days = List.generate(30, (index) {
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    return DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day)
        .add(Duration(days: index));
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: theme.uxPageBackground, // Use UX background from theme
          appBar: _ResponsiveAppBar(
            width: constraints.maxWidth,
            date: days[_currentPageIndex],
            carouselController: _carouselController,
          ),
          drawer: const AppDrawer(),
          body: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: double.infinity, // Take full height of the parent
                    autoPlay: false,
                    viewportFraction: 1,
                    initialPage: _currentPageIndex,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                  ),
                  items: days.map((date) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          color: AppStyles.uxCardBackground, // Use UX background
                          child: TimeSlotTableUx(date: date), // Use the new UX table
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double width;
  final DateTime date;
  final CarouselSliderController carouselController;

  const _ResponsiveAppBar({
    required this.width,
    required this.date,
    required this.carouselController,
  });

  @override
  Widget build(BuildContext context) {
    bool isNarrow = width < 1200;

    Widget titleWidget;
    if (isNarrow) {
      titleWidget = Center( // Center the title vertically
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10), // Increased spacing
            const Text(
              'Padel Time',
              style: TextStyle(
                fontSize: AppStyles.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 0), // Increased spacing
            Text(
              DateFormat('EEEE, MMMM d', 'ro_RO').format(date),
              style: const TextStyle(fontSize: AppStyles.fontSizeNormal), // Increased font size
            ),
          ],
        ),
      );
    } else {
      titleWidget = Text(
        'Padel Time - ${DateFormat('EEEE, MMMM d, yyyy', 'ro_RO').format(date)}',
        style: const TextStyle(fontSize: AppStyles.fontSizeMedium, fontWeight: FontWeight.bold),
      );
    }

    return AppBar(
      leading: isNarrow ? Builder(
        builder: (context) => Center( // Center the leading icon vertically
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ) : null, // Use default leading for wide screen
      centerTitle: true,
      title: titleWidget,
      actions: [
        TextButton(
          onPressed: () {
            carouselController.jumpToPage(3); // Navigate to the current day
          },
          child: const Text(
            'Azi',
            style: TextStyle(color: AppStyles.lightText),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    if (width < 1200) {
      return Size.fromHeight(kToolbarHeight * 1.3); // 30% larger
    } else {
      return Size.fromHeight(kToolbarHeight);
    }
  }
}