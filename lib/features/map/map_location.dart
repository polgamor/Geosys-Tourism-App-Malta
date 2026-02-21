import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MapLocation {
  late ArcGISMapViewController _mapViewController;
  bool _locationStarted = false;
  bool _isTracking = false;

  void setupLocation(ArcGISMapViewController controller) {
    _mapViewController = controller;

    _mapViewController.locationDisplay.autoPanMode =
        LocationDisplayAutoPanMode.navigation;
    _mapViewController.locationDisplay.dataSource = SystemLocationDataSource();

    _mapViewController.locationDisplay.defaultSymbol = SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: Colors.blue,
      size: 20,
    );

    _mapViewController.locationDisplay.accuracySymbol = SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: Colors.blue.withOpacity(0.2),
      outline: SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.blue.withOpacity(0.6),
        width: 1,
      ),
    );

    _mapViewController.locationDisplay.navigationPointHeightFactor = 0.5;
  }

  Future<bool> toggleLocation() async {
    return _locationStarted ? await _stopLocation() : await _startLocation();
  }

  Future<bool> _startLocation() async {
    try {
      final status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Location permission denied');
        return false;
      }

      await _mapViewController.locationDisplay.dataSource.start();
      _locationStarted = true;
      _isTracking = true;
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.navigation;

      debugPrint('Location started with automatic tracking');
      return true;
    } catch (e) {
      debugPrint('Failed to start location: $e');
      return false;
    }
  }

  Future<bool> _stopLocation() async {
    try {
      await _mapViewController.locationDisplay.dataSource.stop();
      _locationStarted = false;
      _isTracking = false;
      debugPrint('Location stopped');
      return true;
    } catch (e) {
      debugPrint('Failed to stop location: $e');
      return false;
    }
  }

  Future<void> centerOnLocation() async {
    if (!_locationStarted) {
      final success = await _startLocation();
      if (!success) return;
    }

    try {
      final location = _mapViewController.locationDisplay.location;
      if (location != null) {
        await _centerOnCurrentLocation(location);
      } else {
        debugPrint('Could not retrieve current location');
      }
    } catch (e) {
      debugPrint('Failed to centre on location: $e');
    }
  }

  Future<void> _centerOnCurrentLocation(ArcGISLocation location) async {
    try {
      final viewpoint = Viewpoint.fromCenter(
        ArcGISPoint(
          x: location.position.x,
          y: location.position.y,
          spatialReference: SpatialReference.wgs84,
        ),
        scale: 10000,
      );
      _mapViewController.setViewpoint(viewpoint);
    } catch (e) {
      debugPrint('Failed to set viewpoint to current location: $e');
    }
  }

  void enableTracking() {
    _isTracking = true;
    if (_locationStarted) {
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.navigation;
    }
  }

  void disableTracking() {
    _isTracking = false;
    if (_locationStarted) {
      _mapViewController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.off;
    }
  }

  bool get isLocationEnabled => _locationStarted;
  bool get isTracking => _isTracking;

  ArcGISLocation? get currentLocation =>
      _mapViewController.locationDisplay.location;

  void dispose() {
    if (_locationStarted) {
      _mapViewController.locationDisplay.dataSource.stop();
    }
  }
}
