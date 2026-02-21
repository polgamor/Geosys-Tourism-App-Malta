import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MapLocation {
  late ArcGISMapViewController _mapViewController;
  bool _locationStarted = false;
  bool _isTracking = false;

  void setupLocation(ArcGISMapViewController controller) {
    _mapViewController = controller;
    
    // Configurar el display de ubicación
    _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.navigation;
    _mapViewController.locationDisplay.dataSource = SystemLocationDataSource();
    
    // Configurar el símbolo de ubicación
    _mapViewController.locationDisplay.defaultSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.blue,
      size: 20,
    );
    
    // Configurar el símbolo de precisión
    _mapViewController.locationDisplay.accuracySymbol = SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: Colors.blue.withOpacity(0.2),
      outline: SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.blue.withOpacity(0.6),
        width: 1,
      ),
    );
    
    // Configurar escala de zoom para seguimiento
    _mapViewController.locationDisplay.navigationPointHeightFactor = 0.5;
  }

  Future<bool> toggleLocation() async {
    if (!_locationStarted) {
      return await _startLocation();
    } else {
      await _stopLocation();
      return true;
    }
  }

  Future<bool> _startLocation() async {
    try {
      // Verificar y solicitar permisos
      final status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        print('Permisos de ubicación denegados');
        return false;
      }

      // Iniciar el servicio de ubicación
      await _mapViewController.locationDisplay.dataSource.start();
      _locationStarted = true;
      _isTracking = true;
      
      // Configurar el modo de seguimiento automático
      _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.navigation;
      
      print('Localización iniciada con seguimiento automático');
      return true;
    } catch (e) {
      print('Error al iniciar la localización: $e');
      return false;
    }
  }

  Future<void> _stopLocation() async {
    try {
      await _mapViewController.locationDisplay.dataSource.stop();
      _locationStarted = false;
      _isTracking = false;
      print('Localización detenida');
    } catch (e) {
      print('Error al detener la localización: $e');
    }
  }

  Future<void> centerOnLocation() async {
    if (!_locationStarted) {
      final success = await _startLocation();
      if (!success) return;
    }

    try {
      final location = _mapViewController.locationDisplay.location; // Se elimina 'await'
      if (location != null) {
        await _centerOnCurrentLocation(location);
      } else {
        print('No se pudo obtener la ubicación actual');
      }
    } catch (e) {
        print('Error al centrar en la ubicación: $e');
    }
  }

  Future<void> _centerOnCurrentLocation(ArcGISLocation location) async {
    try {
      final viewpoint = Viewpoint.fromCenter(
      ArcGISPoint(
        x: location.position.x,
        y: location.position.y,
        spatialReference: SpatialReference.wgs84, // Acceso directo a la propiedad
      ),
        scale: 10000,
      );
      
      _mapViewController.setViewpoint(viewpoint);
    } catch (e) {
      print('Error al centrar en la ubicación actual: $e');
    }
  }

  void enableTracking() {
    _isTracking = true;
    if (_locationStarted) {
      _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.navigation;
    }
  }

  void disableTracking() {
    _isTracking = false;
    if (_locationStarted) {
      _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.off;
    }
  }

  bool get isLocationEnabled => _locationStarted;
  bool get isTracking => _isTracking;

  ArcGISLocation? get currentLocation => _mapViewController.locationDisplay.location;

  void dispose() {
    if (_locationStarted) {
      _mapViewController.locationDisplay.dataSource.stop();
    }
  }
}