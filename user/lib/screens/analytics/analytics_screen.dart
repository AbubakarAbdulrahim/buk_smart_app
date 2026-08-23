import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _activeTab = 'Yearly';
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime(2026, 1, 1),
    end: DateTime(2026, 7, 2),
  );

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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
        _selectedRange = picked;
      });
    }
  }

  String _formatDateRange() {
    final start = _selectedRange.start;
    final end = _selectedRange.end;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[start.month - 1]} ${start.day}, ${start.year} - ${months[end.month - 1]} ${end.day}, ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline switcher selector
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.calendar, color: Color(AppColors.primaryDeeper), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDateRange(),
                        style: const TextStyle(
                          color: Color(AppColors.primaryDeeper),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _selectDateRange,
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: Color(AppColors.primaryDeeper),
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
                    value: '10',
                    icon: PhosphorIconsRegular.megaphone,
                    iconColor: const Color(0xFFF59E0B), // Amber (warn/pending status)
                    // badge: _buildDecreaseBadge(),
                  ),
                  _buildMetricCard(
                    title: 'Verified',
                    value: '4',
                    icon: PhosphorIconsRegular.sealCheck,
                    iconColor: const Color(0xFF3B82F6), // Royal Blue (trusted status)
                  ),
                  _buildMetricCard(
                    title: 'Resolved',
                    value: '3',
                    icon: PhosphorIconsRegular.checkCircle,
                    iconColor: const Color(0xFF10B981), // Emerald Green (completion status)
                  ),
                  _buildMetricCard(
                    title: 'Resolution Rate',
                    value: '30.0%',
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFF1F4)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x040D1B2D), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incident Trends',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: IncidentTrendsPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Donut Categories Chart Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFF1F4)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x040D1B2D), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incidents by Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: DonutChartPainter(
                                values: const [4, 2, 1, 2, 1], // Insecurity=4, Theft=2, Emergency=1, Power=2, Water=1 (Total=10)
                                colors: const [
                                  Color(0xFFEF4444), // Insecurity (Red)
                                  Color(0xFFF59E0B), // Theft (Amber)
                                  Color(0xFFEC4899), // Emergency (Pink)
                                  Color(0xFF6366F1), // Power Outage (Indigo)
                                  Color(0xFF06B6D4), // Water Outage (Cyan)
                                ],
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
                              _buildLegentItem(const Color(0xFFEF4444), 'Insecurity (4)'),
                              const SizedBox(height: 8),
                              _buildLegentItem(const Color(0xFFF59E0B), 'Theft (2)'),
                              const SizedBox(height: 8),
                              _buildLegentItem(const Color(0xFFEC4899), 'Emergency (1)'),
                              const SizedBox(height: 8),
                              _buildLegentItem(const Color(0xFF6366F1), 'Power (2)'),
                              const SizedBox(height: 8),
                              _buildLegentItem(const Color(0xFF06B6D4), 'Water (1)'),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFF1F4)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x040D1B2D), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Locations',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildLocationProgress(
                      name: 'Kano',
                      count: 2,
                      percentage: 20.0,
                    ),
                    const SizedBox(height: 14),
                    _buildLocationProgress(
                      name: 'Kofar Wambai',
                      count: 2,
                      percentage: 20.0,
                    ),
                    const SizedBox(height: 14),
                    _buildLocationProgress(
                      name: 'Kofar Ruwa - Kofar Kabuga Road',
                      count: 1,
                      percentage: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTab(String label) {
    final isSelected = _activeTab == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = label;
          });
        },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F4)),
        boxShadow: const [
          BoxShadow(color: Color(0x021E293B), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), // Slate 100 matching Lost & Found category icon background
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(AppColors.textSecondary), // Slate icon color matching Lost & Found
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
                  style: const TextStyle(
                    color: Color(AppColors.textSecondary),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Color(AppColors.textPrimary),
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

  Widget _buildDecreaseBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.trendDown, color: Color(0xFF10B981), size: 10),
          SizedBox(width: 4),
          Text(
            '33.3%',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegentItem(Color color, String text) {
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
          style: const TextStyle(
            color: Color(AppColors.textSecondary),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(AppColors.textPrimary),
                ),
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                color: Color(AppColors.textSecondary),
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
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryDeeper),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFFE2E8F0)
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
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw dashed/dotted grid lines
    const int segments = 4;
    final double stepY = size.height / segments;
    final List<String> labels = ['2.0', '1.8', '1.6', '1.4', '1.2'];

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
      textPainter.paint(canvas, Offset(0, y - 6));

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

    // Spline line data points (normalized to coordinates)
    // Points represent coordinates starting at y=1.0, dipping, peaking at y=2.0, coming down to 1.0
    final double startX = 30.0;
    final double endX = size.width - 10;
    final double width = endX - startX;
    
    final points = [
      Offset(startX, size.height), // point 0
      Offset(startX + width * 0.25, size.height), // point 1
      Offset(startX + width * 0.45, size.height + 4), // slight dip
      Offset(startX + width * 0.65, size.height - size.height * 0.9), // high peak
      Offset(startX + width * 0.75, size.height - size.height * 0.82), // slight descend
      Offset(startX + width * 0.9, size.height), // point 5
      Offset(endX, size.height), // final
    ];

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
          const Color(AppColors.primaryDeeper).withOpacity(0.18),
          const Color(AppColors.primaryDeeper).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(startX, 0, endX, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paintLine);

    // Draw coordinate dots on the peaks
    final dotIndices = [0, 1, 2, 3, 4, 5, 6];
    for (var idx in dotIndices) {
      final p = points[idx];
      canvas.drawCircle(p, 5.0, paintDot);
      canvas.drawCircle(p, 2.5, paintInnerDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  DonutChartPainter({
    required this.values,
    required this.colors,
  });

  final List<double> values;
  final List<Color> colors;

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

    // Cut a inner white circle to make it a Donut shape
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.38, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
