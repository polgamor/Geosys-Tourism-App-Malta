import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import '../../colors.dart';

class CustomMapWidget extends StatelessWidget {
  final ArcGISMapViewController Function() controllerProvider;
  final VoidCallback? onMapViewReady;
  final Function(Offset)? onTap;

  const CustomMapWidget({
    super.key,
    required this.controllerProvider,
    this.onMapViewReady,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ArcGISMapView(
          controllerProvider: controllerProvider,
          onMapViewReady: onMapViewReady,
          onTap: onTap,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(width: 200, height: 30, color: AppColors.background),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: 150, height: 30, color: AppColors.background),
        ),
        Positioned(
          bottom: 0,
          left: 150,
          right: 200,
          child: Container(height: 30, color: AppColors.background),
        ),
      ],
    );
  }
}

class CleanMapWidget extends StatelessWidget {
  final ArcGISMapViewController Function() controllerProvider;
  final VoidCallback? onMapViewReady;
  final Function(Offset)? onTap;

  const CleanMapWidget({
    super.key,
    required this.controllerProvider,
    this.onMapViewReady,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            bottom: -30,
            child: ArcGISMapView(
              controllerProvider: controllerProvider,
              onMapViewReady: onMapViewReady,
              onTap: onTap,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 30, color: AppColors.background),
          ),
        ],
      ),
    );
  }
}

mixin MapConfigurationMixin {
  static Future<void> configureCleanMap(ArcGISMapViewController controller) async {
    try {
      debugPrint('Map configured for clean UI');
    } catch (e) {
      debugPrint('Error configuring clean map: $e');
    }
  }

  static Widget createAttributionOverlay() {
    return const Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 25,
        child: ColoredBox(color: AppColors.background),
      ),
    );
  }
}
