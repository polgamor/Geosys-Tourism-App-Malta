import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../colors.dart';

class MapInteractions {
  late ArcGISMapViewController _mapViewController;
  late BuildContext _context;
  final GraphicsOverlay _destinationOverlay = GraphicsOverlay();
  Function(ArcGISPoint)? _onDestinationSelected;
  ArcGISPoint? _selectedDestination;

  void setupMapInteractions(
    ArcGISMapViewController controller,
    BuildContext context,
    Function(ArcGISPoint)? onDestinationSelected,
  ) {
    _mapViewController = controller;
    _context = context;
    _onDestinationSelected = onDestinationSelected;
    _mapViewController.graphicsOverlays.add(_destinationOverlay);
  }

  Future<void> handleMapTap(Offset screenPoint) async {
    try {
      final identifyResults = await _mapViewController.identifyLayers(
        screenPoint: screenPoint,
        tolerance: 10.0,
      );

      if (identifyResults.isNotEmpty) {
        final result = identifyResults.first;
        final geoElements = result.geoElements;

        if (geoElements.isNotEmpty) {
          final feature = geoElements.first;
          if (feature is ArcGISFeature) {
            final attributes = feature.attributes;
            if (attributes.isNotEmpty) _showFeaturePopup(attributes);

            if (feature.geometry is ArcGISPoint) {
              _setDestination(feature.geometry as ArcGISPoint);
            }
          }
        }
      } else {
        final mapPoint = _mapViewController.screenToLocation(screen: screenPoint);
        if (mapPoint != null) _setDestination(mapPoint);
      }
    } catch (e) {
      debugPrint('Error identifying map features: $e');
    }
  }

  void _setDestination(ArcGISPoint destination) {
    _selectedDestination = destination;
    _destinationOverlay.graphics.clear();

    final destinationSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.diamond,
      color: Colors.red,
      size: 16,
    );

    _destinationOverlay.graphics.add(
      Graphic(geometry: destination, symbol: destinationSymbol),
    );

    _onDestinationSelected?.call(destination);
    _showDestinationPopup(destination);
  }

  void _showFeaturePopup(Map<String, dynamic> attributes) {
    final relevantAttributes = <String, dynamic>{};

    for (final entry in attributes.entries) {
      if (entry.value != null &&
          entry.value.toString().isNotEmpty &&
          entry.value.toString() != 'null') {
        String fieldLabel = entry.key;
        switch (entry.key.toLowerCase()) {
          case 'name':
          case 'nombre':
            fieldLabel = 'Name';
          case 'description':
          case 'descripcion':
            fieldLabel = 'Description';
          case 'type':
          case 'tipo':
            fieldLabel = 'Type';
          case 'address':
          case 'direccion':
            fieldLabel = 'Address';
          case 'phone':
          case 'telefono':
            fieldLabel = 'Phone';
          case 'website':
          case 'web':
            fieldLabel = 'Website';
        }
        relevantAttributes[fieldLabel] = entry.value;
      }
    }

    if (relevantAttributes.isNotEmpty) {
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Place Information',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: relevantAttributes.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: entry.value.toString(),
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }

  void _showDestinationPopup(ArcGISPoint destination) {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Destination Selected',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coordinates:',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Latitude: ${destination.y.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Longitude: ${destination.x.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Text(
              'Would you like to calculate a route to this destination?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              clearDestination();
            },
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yes', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void clearDestination() {
    _destinationOverlay.graphics.clear();
    _selectedDestination = null;
  }

  ArcGISPoint? get selectedDestination => _selectedDestination;
  bool get hasDestination => _selectedDestination != null;
}
