import 'package:arcgis_maps/arcgis_maps.dart';
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
    
    // Añadir overlay para mostrar destinos seleccionados
    _mapViewController.graphicsOverlays.add(_destinationOverlay);
  }

  Future<void> handleMapTap(Offset screenPoint) async {
    try {
      // Primero intentar identificar elementos existentes en el mapa
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
            if (attributes.isNotEmpty) {
              _showFeaturePopup(attributes);
            }
            
            // Si el feature tiene geometría, usarla como destino
            if (feature.geometry is ArcGISPoint) {
              _setDestination(feature.geometry as ArcGISPoint);
            }
          }
        }
      } else {
        // Si no hay elementos identificados, usar el punto tocado como destino
        final mapPoint = _mapViewController.screenToLocation(screen: screenPoint);
        if (mapPoint != null) {
          _setDestination(mapPoint);
        }
      }
    } catch (e) {
      print('Error al identificar elementos: $e');
    }
  }

  void _setDestination(ArcGISPoint destination) {
    _selectedDestination = destination;
    
    // Limpiar destinos anteriores
    _destinationOverlay.graphics.clear();
    
    // Crear un marcador para el destino
    final destinationSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.diamond,
      color: Colors.red,
      size: 16,
    );
    
    final destinationGraphic = Graphic(
      geometry: destination,
      symbol: destinationSymbol,
    );
    
    _destinationOverlay.graphics.add(destinationGraphic);
    
    // Notificar al widget padre que se ha seleccionado un destino
    _onDestinationSelected?.call(destination);
    
    // Mostrar popup de confirmación
    _showDestinationPopup(destination);
  }

  void _showFeaturePopup(Map<String, dynamic> attributes) {
    // Filtrar atributos relevantes
    final relevantAttributes = <String, dynamic>{};
    
    for (final entry in attributes.entries) {
      if (entry.value != null && 
          entry.value.toString().isNotEmpty && 
          entry.value.toString() != 'null') {
        
        // Formatear nombres de campos comunes
        String fieldName = entry.key;
        switch (entry.key.toLowerCase()) {
          case 'name':
          case 'nombre':
            fieldName = 'Nombre';
            break;
          case 'description':
          case 'descripcion':
            fieldName = 'Descripción';
            break;
          case 'type':
          case 'tipo':
            fieldName = 'Tipo';
            break;
          case 'address':
          case 'direccion':
            fieldName = 'Dirección';
            break;
          case 'phone':
          case 'telefono':
            fieldName = 'Teléfono';
            break;
          case 'website':
          case 'web':
            fieldName = 'Sitio web';
            break;
        }
        
        relevantAttributes[fieldName] = entry.value;
      }
    }

    if (relevantAttributes.isNotEmpty) {
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            'Información del Lugar',
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
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: entry.value.toString(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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
              child: Text('Cerrar', style: TextStyle(color: AppColors.primary)),
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
        title: Text(
          'Destino Seleccionado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coordenadas:',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Latitud: ${destination.y.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Longitud: ${destination.x.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              '¿Deseas calcular una ruta a este destino?',
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
            child: Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sí', style: TextStyle(color: AppColors.primary)),
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