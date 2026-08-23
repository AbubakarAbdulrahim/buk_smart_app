import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  
  // Coordinates
  static const LatLng _newSiteCoords = LatLng(11.9796, 8.4116);
  static const LatLng _oldSiteCoords = LatLng(11.9932, 8.4859);

  bool _isNewSite = true;

  LatLng get _currentCenter => _isNewSite ? _newSiteCoords : _oldSiteCoords;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destCenter, double destZoom) {
    if (!mounted) return;
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destCenter.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destCenter.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _toggleCampus(bool toNewSite) {
    if (_isNewSite == toNewSite) return;
    setState(() {
      _isNewSite = toNewSite;
    });
    _animatedMapMove(_currentCenter, 15.5);
  }

  void _zoom(double val) {
    final camera = _mapController.camera;
    _animatedMapMove(camera.center, camera.zoom + val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BUK Campus Map'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showBack
            ? IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Stack(
        children: [
          // FlutterMap Widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.5,
              minZoom: 13.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smartbuk.app',
              ),
            ],
          ),

          // Floating Campus Toggle Pill
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F0B1A2B), blurRadius: 18, offset: Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toggleTab(label: 'New Site', isSelected: _isNewSite, onTap: () => _toggleCampus(true)),
                    _toggleTab(label: 'Old Site', isSelected: !_isNewSite, onTap: () => _toggleCampus(false)),
                  ],
                ),
              ),
            ),
          ),

          // Zoom & Recenter Controls
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              children: [
                _circularControl(icon: PhosphorIconsRegular.plus, onTap: () => _zoom(1.0)),
                const SizedBox(height: 10),
                _circularControl(icon: PhosphorIconsRegular.minus, onTap: () => _zoom(-1.0)),
                const SizedBox(height: 10),
                _circularControl(
                  icon: PhosphorIconsRegular.gps,
                  onTap: () => _animatedMapMove(_currentCenter, 15.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(AppColors.primaryDeeper) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(AppColors.textSecondary),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _circularControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x1F0B1A2B), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, size: 18, color: const Color(AppColors.textPrimary)),
          onPressed: onTap,
        ),
      ),
    );
  }
}
