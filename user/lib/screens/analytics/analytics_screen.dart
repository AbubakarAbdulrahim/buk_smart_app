import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/incident.dart';
import '../../services/firestore_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _activeTab = 'Yearly';
  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, 12, 31, 23, 59, 59),
    );
  }

  void _onTabSelected(String label) {
    final now = DateTime.now();
    if (label == 'Daily') {
      setState(() {
        _activeTab = label;
        _selectedRange = DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      });
    } else if (label == 'Monthly') {
      setState(() {
        _activeTab = label;
        _selectedRange = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      });
    } else if (label == 'Yearly') {
      setState(() {
        _activeTab = label;
        _selectedRange = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      });
    } else if (label == 'Custom') {
      _selectDateRange();
    }
  }

  void _selectDateRange() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? Theme.of(context).copyWith(
                  scaffoldBackgroundColor: const Color(AppColors.darkBackground),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(AppColors.primaryLight),
                    onPrimary: Colors.white,
                    surface: Color(AppColors.darkCard),
                    onSurface: Color(AppColors.darkTextPrimary),
                    secondary: Color(AppColors.primaryLight),
                    onSecondary: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(backgroundColor: Color(AppColors.darkCard)),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(AppColors.darkCard),
                    foregroundColor: Color(AppColors.darkTextPrimary),
                    iconTheme: IconThemeData(color: Color(AppColors.darkTextPrimary)),
                  ),
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor: const Color(AppColors.darkCard),
                    headerBackgroundColor: const Color(AppColors.darkCard),
                    headerForegroundColor: const Color(AppColors.darkTextPrimary),
                    surfaceTintColor: Colors.transparent,
                    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      if (states.contains(WidgetState.disabled)) {
                        return const Color(AppColors.darkTextMuted);
                      }
                      return const Color(AppColors.darkTextPrimary);
                    }),
                    rangePickerBackgroundColor: const Color(AppColors.darkCard),
                    rangePickerHeaderBackgroundColor: const Color(AppColors.darkCard),
                    rangePickerHeaderForegroundColor: const Color(AppColors.darkTextPrimary),
                    rangeSelectionBackgroundColor: const Color(0xFF1E3A5F),
                    rangePickerSurfaceTintColor: Colors.transparent,
                  ),
                )
              : Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(AppColors.primaryDeeper),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(AppColors.textPrimary),
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = DateTimeRange(
          start: DateTime(picked.start.year, picked.start.month, picked.start.day),
          end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
        );
        _activeTab = 'Custom';
      });
    }
  }

  String _formatDateRange() {
    final start = _selectedRange.start;
    final end = _selectedRange.end;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[start.month - 1]} ${start.day}, ${start.year} - ${months[end.month - 1]} ${end.day}, ${end.year}';
  }

  List<int> _calculateTrendPoints(List<Incident> incidents, int numPoints) {
    if (numPoints <= 1) return [incidents.length];
    final startMs = _selectedRange.start.millisecondsSinceEpoch;
    final endMs = _selectedRange.end.millisecondsSinceEpoch;
    final span = math.max(1, endMs - startMs);
    final step = span / (numPoints - 1);
    final buckets = List<int>.filled(numPoints, 0);

    for (final inc in incidents) {
      final t = inc.createdAt.millisecondsSinceEpoch;
      if (t >= startMs && t <= endMs) {
        int idx = ((t - startMs) / step).floor();
        if (idx >= numPoints) idx = numPoints - 1;
        if (idx < 0) idx = 0;
        buckets[idx]++;
      }
    }
    return buckets;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<Incident>>(
        stream: firestore.allIncidents(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];
          final start = DateTime(_selectedRange.start.year, _selectedRange.start.month, _selectedRange.start.day);
          final end = DateTime(_selectedRange.end.year, _selectedRange.end.month, _selectedRange.end.day, 23, 59, 59, 999);
          final filtered = all.where((inc) {
            return inc.createdAt.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
                inc.createdAt.isBefore(end.add(const Duration(milliseconds: 1)));
          }).toList();

          final totalCount = filtered.length;
          final verifiedCount = filtered.where((i) => i.isVerified).length;
          final resolvedCount = filtered.where((i) => i.isResolved || i.status.toLowerCase() == 'resolved').length;
          final resolutionRate = totalCount == 0 ? '0.0%' : '${((resolvedCount / totalCount) * 100).toStringAsFixed(1)}%';

          // Incidents by category palette
          final categoryPalette = <String, Color>{
            'Insecurity': const Color(0xFFEF4444), // Red
            'Theft': const Color(0xFFF59E0B), // Amber
            'Emergency': const Color(0xFFEC4899), // Pink
            'Power Outage': const Color(0xFF6366F1), // Indigo
            'Water Outage': const Color(0xFF06B6D4), // Cyan
            'Fire Outbreak': const Color(0xFFF97316), // Orange
            'Waste Dumps': const Color(0xFF84CC16), // Lime
            'Other': const Color(0xFF8B5CF6), // Purple
          };

          final Map<String, int> catCounts = {};
          for (final inc in filtered) {
            final cat = inc.type.trim().isEmpty ? 'Other' : inc.type.trim();
            catCounts[cat] = (catCounts[cat] ?? 0) + 1;
          }

          final sortedCats = catCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Locations
          final Map<String, int> locCounts = {};
          for (final inc in filtered) {
            final loc = inc.location.trim().isEmpty ? 'Unknown' : inc.location.trim();
            locCounts[loc] = (locCounts[loc] ?? 0) + 1;
          }
          final sortedLocs = locCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final trendPoints = _calculateTrendPoints(filtered, 7);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline switcher selector
                Container(
                  color: isDark ? const Color(AppColors.darkBackground) : Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(AppColors.darkCardSubtle)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildSwitchTab('Daily'),
                        _buildSwitchTab('Monthly'),
                        _buildSwitchTab('Yearly'),
                        _buildSwitchTab('Custom'),
                      ],
                    ),
                  ),
                ),

                // Date pill banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(AppColors.darkCard)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(AppColors.darkBorder)
                            : const Color(0xFFDBEAFE),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.calendar,
                          color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDateRange(),
                            style: TextStyle(
                              color: isDark
                                  ? const Color(AppColors.darkTextPrimary)
                                  : const Color(AppColors.primaryDeeper),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _selectDateRange,
                          child: Text(
                            'Change',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(AppColors.primaryLight)
                                  : const Color(AppColors.primaryDeeper),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2x2 Metric Cards Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.22, // Halved card height ratio (horizontal layout)
                    children: [
                      _buildMetricCard(
                        title: 'Total Incidents',
                        value: '$totalCount',
                        icon: PhosphorIconsRegular.megaphone,
                        iconColor: const Color(0xFFF59E0B), // Amber (warn/pending status)
                      ),
                      _buildMetricCard(
                        title: 'Verified',
                        value: '$verifiedCount',
                        icon: PhosphorIconsRegular.sealCheck,
                        iconColor: const Color(0xFF3B82F6), // Royal Blue (trusted status)
                      ),
                      _buildMetricCard(
                        title: 'Resolved',
                        value: '$resolvedCount',
                        icon: PhosphorIconsRegular.checkCircle,
                        iconColor: const Color(0xFF10B981), // Emerald Green (completion status)
                      ),
                      _buildMetricCard(
                        title: 'Resolution Rate',
                        value: resolutionRate,
                        icon: PhosphorIconsRegular.trendUp,
                        iconColor: const Color(0xFF6366F1), // Indigo (performance stat)
                      ),
                    ],
                  ),
                ),

                // Line/Spline Trends Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(AppColors.darkBackground) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(AppColors.darkBorder)
                            : const Color(0xFFEFF1F4),
                      ),
                      boxShadow: isDark
                          ? []
                          : const [
                              BoxShadow(color: Color(0x040D1B2D), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incident Trends',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: IncidentTrendsPainter(
                              isDark: isDark,
                              counts: trendPoints,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Donut Categories Chart Section (Pie Chart Card)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(AppColors.darkBackground) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
                      ),
                      boxShadow: isDark
                          ? []
                          : const [
                              BoxShadow(color: Color(0x040D1B2D), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incidents by Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (sortedCats.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No incidents recorded for this period',
                                style: TextStyle(
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: CustomPaint(
                                    painter: DonutChartPainter(
                                      values: sortedCats.map((e) => e.value.toDouble()).toList(),
                                      colors: sortedCats.map((e) => categoryPalette[e.key] ?? const Color(0xFF8B5CF6)).toList(),
                                      backgroundColor: isDark ? const Color(AppColors.darkBackground) : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int i = 0; i < sortedCats.length; i++) ...[
                                      if (i > 0) const SizedBox(height: 8),
                                      _buildLegentItem(
                                        categoryPalette[sortedCats[i].key] ?? const Color(0xFF8B5CF6),
                                        '${sortedCats[i].key} (${sortedCats[i].value})',
                                        isDark,
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // Top Locations Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(AppColors.darkBackground) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
                      ),
                      boxShadow: isDark
                          ? []
                          : const [
                              BoxShadow(color: Color(0x040D1B2D), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Locations',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (sortedLocs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'No location data recorded for this period',
                                style: TextStyle(
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          for (int i = 0; i < math.min(sortedLocs.length, 5); i++) ...[
                            if (i > 0) const SizedBox(height: 14),
                            _buildLocationProgress(
                              name: sortedLocs[i].key,
                              count: sortedLocs[i].value,
                              percentage: totalCount > 0 ? (sortedLocs[i].value / totalCount) * 100 : 0.0,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTab(String label) {
    final isSelected = _activeTab == label;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(AppColors.primaryDeeper) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    Widget? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(AppColors.darkBackground) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(color: Color(0x021E293B), blurRadius: 10, offset: Offset(0, 4)),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(AppColors.primaryLight) : const Color(0xFF64748B),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 4),
                      Flexible(child: badge),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegentItem(Color color, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationProgress({
    required String name,
    required int count,
    required double percentage,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                ),
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IncidentTrendsPainter extends CustomPainter {
  IncidentTrendsPainter({
    required this.isDark,
    required this.counts,
  });

  final bool isDark;
  final List<int> counts;

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final paintLine = Paint()
      ..color = const Color(AppColors.primaryDeeper)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = const Color(AppColors.primaryDeeper)
      ..style = PaintingStyle.fill;

    final paintInnerDot = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : Colors.white
      ..style = PaintingStyle.fill;

    // Determine scale
    int maxVal = 2;
    for (final c in counts) {
      if (c > maxVal) maxVal = c;
    }
    final double maxY = maxVal.toDouble();

    // Draw dashed/dotted grid lines
    const int segments = 4;
    final double stepY = size.height / segments;
    final List<String> labels = List.generate(segments + 1, (i) {
      final v = maxY - (i * (maxY / segments));
      return v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    });

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= segments; i++) {
      final double y = i * stepY;

      // Draw label text
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, (y - 6).clamp(0, size.height - 12)));

      // Draw dashed horizontal line
      double startX = 26.0;
      const double dashWidth = 4.0;
      const double dashSpace = 4.0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + dashWidth, y),
          paintGrid,
        );
        startX += dashWidth + dashSpace;
      }
    }

    if (counts.isEmpty) return;

    // Coordinates
    final double startX = 30.0;
    final double endX = size.width - 10;
    final double width = endX - startX;

    final points = <Offset>[];
    for (int i = 0; i < counts.length; i++) {
      final x = startX + width * (i / (counts.length - 1));
      final val = counts[i];
      final y = size.height - (val / (maxY * 1.15)) * size.height;
      points.add(Offset(x, y.clamp(8.0, size.height)));
    }

    // Compute bezier spline path
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    // Fill under the line with light gradient
    final fillPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(endX, size.height)
      ..lineTo(startX, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(AppColors.primaryDeeper).withValues(alpha: 0.18),
          const Color(AppColors.primaryDeeper).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(startX, 0, endX, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paintLine);

    // Draw coordinate dots on the points
    for (final p in points) {
      canvas.drawCircle(p, 5.0, paintDot);
      canvas.drawCircle(p, 2.5, paintInnerDot);
    }
  }

  @override
  bool shouldRepaint(covariant IncidentTrendsPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.counts != counts;
  }
}

class DonutChartPainter extends CustomPainter {
  DonutChartPainter({
    required this.values,
    required this.colors,
    required this.backgroundColor,
  });

  final List<double> values;
  final List<Color> colors;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0, (sum, val) => sum + val);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2; // start from top center

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;

      final paintSegment = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paintSegment);
      startAngle += sweepAngle;
    }

    // Cut an inner circle matching background to make it a Donut shape
    final cutPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.38, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
