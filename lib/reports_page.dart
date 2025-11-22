import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/time_slot_table.dart'; // To access mockReservations

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _reservationsToday = 0;
  int _reservationsNext7Days = 0;
  int _reservationsLast30Days = 0;
  String _subscriptionRatio = '';
  
  String _todayPercentage = '';
  String _next7DaysPercentage = '';
  String _last30DaysPercentage = '';

  List<FlSpot> _lineChartSpots = [];
  List<BarChartGroupData> _barChartGroups = [];
  double _lineChartMaxY = 10;
  double _barChartMaxY = 10;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  String _formatPercentage(double change) {
    if (change.isInfinite || change.isNaN) {
      return 'N/A';
    }
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  void _calculateStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateFormat = DateFormat('dd/MM/yyyy');

    final reservationsTodayIds = <String>{};
    final reservationsYesterdayIds = <String>{};
    final reservationsNext7DaysIds = <String>{};
    final reservationsPrev7DaysIds = <String>{};
    final reservationsLast30DaysIds = <String>{};
    final reservationsPrev30DaysIds = <String>{};
    final subscriptionLast30DaysIds = <String>{};

    final dailyCounts = <int, int>{};
    final hourlyCounts = <int, int>{};

    for (final reservation in mockReservations) {
      try {
        final reservationDate = dateFormat.parse(reservation['date']);
        final reservationId = reservation['id'] as String;
        final isLast7Days = reservationDate.isAfter(today.subtract(const Duration(days: 7))) && reservationDate.isBefore(today.add(const Duration(days: 1)));
        final isLast30Days = reservationDate.isAfter(today.subtract(const Duration(days: 31))) && reservationDate.isBefore(today.add(const Duration(days: 1)));

        // Today vs Yesterday
        if (reservationDate.isAtSameMomentAs(today)) reservationsTodayIds.add(reservationId);
        if (reservationDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) reservationsYesterdayIds.add(reservationId);

        // Next 7 vs Prev 7
        if (reservationDate.isAfter(today) && reservationDate.isBefore(today.add(const Duration(days: 8)))) reservationsNext7DaysIds.add(reservationId);
        if (reservationDate.isAfter(today.subtract(const Duration(days: 8))) && reservationDate.isBefore(today)) reservationsPrev7DaysIds.add(reservationId);

        // Last 30 vs Prev 30
        if (isLast30Days) {
          reservationsLast30DaysIds.add(reservationId);
          if (reservation['isSubscription'] == true) {
            subscriptionLast30DaysIds.add(reservation['subscriptionId'] as String);
          }
        }
        if (reservationDate.isAfter(today.subtract(const Duration(days: 61))) && reservationDate.isBefore(today.subtract(const Duration(days: 30)))) reservationsPrev30DaysIds.add(reservationId);
        
        // Line Chart data (last 7 days)
        if (isLast7Days) {
          final dayOfYear = dateToDayOfYear(reservationDate);
          dailyCounts.update(dayOfYear, (value) => value + 1, ifAbsent: () => 1);
        }

        // Bar Chart data (hourly, last 7 days)
        if (isLast7Days) {
          final List<dynamic> interval = reservation['interval'];
          for (int i = interval[0]; i < interval[1]; i++) {
            hourlyCounts.update(i, (value) => value + 1, ifAbsent: () => 1);
          }
        }

      } catch (e) {
        // Ignore invalid date formats
      }
    }
    
    // --- Calculate percentages ---
    final todayCount = reservationsTodayIds.length;
    final yesterdayCount = reservationsYesterdayIds.length;
    final todayChange = yesterdayCount == 0 ? (todayCount > 0 ? 100.0 : 0.0) : ((todayCount - yesterdayCount) / yesterdayCount) * 100;

    final next7DaysCount = reservationsNext7DaysIds.length;
    final prev7DaysCount = reservationsPrev7DaysIds.length;
    final next7DaysChange = prev7DaysCount == 0 ? (next7DaysCount > 0 ? 100.0 : 0.0) : ((next7DaysCount - prev7DaysCount) / prev7DaysCount) * 100;

    final last30DaysCount = reservationsLast30DaysIds.length;
    final prev30DaysCount = reservationsPrev30DaysIds.length;
    final last30DaysChange = prev30DaysCount == 0 ? (last30DaysCount > 0 ? 100.0 : 0.0) : ((last30DaysCount - prev30DaysCount) / prev30DaysCount) * 100;

    final subscriptionRatioCalc = last30DaysCount == 0 ? 0.0 : (subscriptionLast30DaysIds.length / last30DaysCount) * 100;

    // --- Prepare Line Chart data ---
    List<FlSpot> spots = [];
    double tempLineMaxY = 5;
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayOfYear = dateToDayOfYear(date);
      final count = dailyCounts[dayOfYear]?.toDouble() ?? 0.0;
      if (count > tempLineMaxY) tempLineMaxY = count;
      spots.add(FlSpot(6.0 - i, count));
    }

    // --- Prepare Bar Chart data ---
    List<BarChartGroupData> barGroups = [];
    double tempBarMaxY = 5;
    for (int i = 8; i < 24; i++) {
      final count = hourlyCounts[i]?.toDouble() ?? 0.0;
      if (count > tempBarMaxY) tempBarMaxY = count;
      barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: count, color: AppStyles.primaryColor, width: 12, borderRadius: BorderRadius.zero)]));
    }

    setState(() {
      _reservationsToday = todayCount;
      _reservationsNext7Days = next7DaysCount;
      _reservationsLast30Days = last30DaysCount;
      _subscriptionRatio = '${subscriptionRatioCalc.toStringAsFixed(1)}%';
      
      _todayPercentage = _formatPercentage(todayChange);
      _next7DaysPercentage = _formatPercentage(next7DaysChange);
      _last30DaysPercentage = _formatPercentage(last30DaysChange);

      _lineChartSpots = spots;
      _lineChartMaxY = (tempLineMaxY / 5).ceil() * 5;

      _barChartGroups = barGroups;
      _barChartMaxY = (tempBarMaxY / 5).ceil() * 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(
        title: const Text('Rapoarte'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildResponsiveLayout(constraints.maxWidth),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveLayout(double width) {
    if (width < 800) {
      return _buildNarrowLayout();
    } else if (width < 1200) {
      return _buildMediumLayout();
    } else {
      return _buildWideLayout();
    }
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('TOTAL REZERVĂRI AZI', _reservationsToday.toString(), _todayPercentage, 'vs Yesterday')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('REZERVĂRI URM. 7 ZILE', _reservationsNext7Days.toString(), _next7DaysPercentage, 'vs Prev. 7 Days')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('REZERVĂRI ULT. 30 ZILE', _reservationsLast30Days.toString(), _last30DaysPercentage, 'vs Prev. 30 Days')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('RATĂ ABONAMENTE', _subscriptionRatio, '', 'în ult. 30 de zile')),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildChartCard(LineChart(_buildLineChartData()), 'Rezervări pe zi (ultimele 7 zile)')),
            const SizedBox(width: 16),
            Expanded(child: _buildChartCard(BarChart(_buildBarChartData()), 'Rezervări pe oră (ultimele 7 zile)')),
          ],
        ),
      ],
    );
  }

  Widget _buildMediumLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('TOTAL REZERVĂRI AZI', _reservationsToday.toString(), _todayPercentage, 'vs Yesterday')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('REZERVĂRI URM. 7 ZILE', _reservationsNext7Days.toString(), _next7DaysPercentage, 'vs Prev. 7 Days')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('REZERVĂRI ULT. 30 ZILE', _reservationsLast30Days.toString(), _last30DaysPercentage, 'vs Prev. 30 Days')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('RATĂ ABONAMENTE', _subscriptionRatio, '', 'în ult. 30 de zile')),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildChartCard(LineChart(_buildLineChartData()), 'Rezervări pe zi (ultimele 7 zile)')),
            const SizedBox(width: 16),
            Expanded(child: _buildChartCard(BarChart(_buildBarChartData()), 'Rezervări pe oră (ultimele 7 zile)')),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildStatCard('TOTAL REZERVĂRI AZI', _reservationsToday.toString(), _todayPercentage, 'vs Yesterday'),
        const SizedBox(height: 16),
        _buildStatCard('REZERVĂRI URM. 7 ZILE', _reservationsNext7Days.toString(), _next7DaysPercentage, 'vs Prev. 7 Days'),
        const SizedBox(height: 16),
        _buildStatCard('REZERVĂRI ULT. 30 ZILE', _reservationsLast30Days.toString(), _last30DaysPercentage, 'vs Prev. 30 Days'),
        const SizedBox(height: 16),
        _buildStatCard('RATĂ ABONAMENTE', _subscriptionRatio, '', 'în ult. 30 de zile'),
        const SizedBox(height: 24),
        _buildChartCard(LineChart(_buildLineChartData()), 'Rezervări pe zi (ultimele 7 zile)'),
        const SizedBox(height: 16),
        _buildChartCard(BarChart(_buildBarChartData()), 'Rezervări pe oră (ultimele 7 zile)'),
      ],
    );
  }

  Widget _buildChartCard(Widget chart, String title) {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.reportsCardCornerRadius),
          side: const BorderSide(color: AppStyles.reportsCardBorder, width: AppStyles.reportsCardBorderWidth),
        ),
        color: AppStyles.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: const TextStyle(color: AppStyles.darkText, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: chart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String percentage, String comparison) {
    final isPositive = percentage.startsWith('+');
    final color = isPositive ? Colors.green : (percentage.startsWith('-') ? Colors.red : AppStyles.secondaryText);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.reportsCardCornerRadius),
        side: const BorderSide(color: AppStyles.reportsCardBorder, width: AppStyles.reportsCardBorderWidth),
      ),
      color: AppStyles.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppStyles.secondaryText, fontSize: AppStyles.fontSizeSmall, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: AppStyles.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppStyles.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (percentage.isNotEmpty)
                  Text(percentage, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(comparison, style: const TextStyle(color: AppStyles.secondaryText, fontSize: AppStyles.fontSizeSmall)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(DateFormat('d MMM').format(day), style: const TextStyle(fontSize: 10, color: AppStyles.darkText)),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (_lineChartMaxY / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: AppStyles.darkText)),
            reservedSize: 28,
          ),
        ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: AppStyles.borderColor)),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: _lineChartMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: _lineChartSpots,
          isCurved: true,
          color: AppStyles.chartLineColor,
          barWidth: AppStyles.reportsChartLineWidth,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppStyles.chartAreaColor,
          ),
        ),
      ],
    );
  }

  BarChartData _buildBarChartData() {
    return BarChartData(
      maxY: _barChartMaxY,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: AppStyles.darkText)),
              );
            },
            reservedSize: 28,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (_barChartMaxY / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: AppStyles.darkText)),
            reservedSize: 28,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: _barChartGroups,
      gridData: const FlGridData(show: false),
    );
  }
}

int dateToDayOfYear(DateTime date) {
  return date.difference(DateTime(date.year, 1, 1)).inDays;
}