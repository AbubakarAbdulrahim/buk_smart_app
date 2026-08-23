import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/routes/app_routes.dart';

class SmartAiFab extends StatefulWidget {
  const SmartAiFab({super.key});

  // Gated session flag for pulse animation
  static bool hasPulsed = false;

  @override
  State<SmartAiFab> createState() => _SmartAiFabState();
}

class _SmartAiFabState extends State<SmartAiFab> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale & Fade-in entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _entranceController.forward();

    // Setup pulsing glow animation only if not pulsed in this session
    if (!SmartAiFab.hasPulsed) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );

      _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );

      // Pulse 3 times, then stop to avoid irritation
      var pulseCount = 0;
      _pulseController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          pulseCount++;
          if (pulseCount < 3) {
            _pulseController!.forward();
          } else {
            SmartAiFab.hasPulsed = true;
            if (mounted) {
              setState(() {});
            }
          }
        }
      });

      _pulseController!.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Standard floating button with glowing pulse shadow decoration
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseController ?? _entranceController,
          builder: (context, child) {
            final pulseOffset = _pulseAnimation?.value ?? 0.0;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.primaryDeeper).withOpacity(0.3),
                    blurRadius: 8 + pulseOffset,
                    spreadRadius: pulseOffset / 3,
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'smart_ai_fab',
                backgroundColor: const Color(AppColors.primaryDeeper),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.smartAi);
                },
                child: const Icon(PhosphorIconsFill.sparkle, size: 24),
              ),
            );
          },
        ),
      ),
    );
  }
}
