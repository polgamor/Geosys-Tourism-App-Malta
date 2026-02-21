import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

class CustomMapWidget extends StatelessWidget {
  final ArcGISMapViewController Function() controllerProvider;
  final VoidCallback? onMapViewReady;
  final Function(Offset)? onTap; // Changed from ScreenCoordinate

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
          child: Container(
            width: 200,
            height: 30,
            color: const Color(0xFF121212),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 150,
            height: 30,
            color: const Color(0xFF121212),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 150,
          right: 200,
          child: Container(
            height: 30,
            color: const Color(0xFF121212),
          ),
        ),
      ],
    );
  }
}

class CleanMapWidget extends StatelessWidget {
  final ArcGISMapViewController Function() controllerProvider;
  final VoidCallback? onMapViewReady;
  final Function(Offset)? onTap; // Changed from ScreenCoordinate

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
            child: Container(
              height: 30,
              color: const Color(0xFF121212),
            ),
          ),
        ],
      ),
    );
  }
}

mixin MapConfigurationMixin {
  static Future<void> configureCleanMap(ArcGISMapViewController controller) async {
    try {
      print('Mapa configurado para UI limpia');
    } catch (e) {
      print('Error configurando mapa limpio: $e');
    }
  }

  static Widget createAttributionOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 25,
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}