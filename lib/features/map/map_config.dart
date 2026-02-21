import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

class MapConfig {
  static const String webMapId = '8543defad02b4dc6a7270d4c2add7045';
  static const double maltaLatitude = 35.9375;
  static const double maltaLongitude = 14.3755;
  static const double initialScale = 500000;

  static const double minScale = 1000;
  static const double maxScale = 10000000;

  static const double locationZoomScale = 10000;
  static const double navigationZoomScale = 5000;
  static const double routeZoomScale = 25000;

  static const String routeServiceUrl =
      'https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World';

  static const Map<String, double> zoomLevels = {
    'world': 50000000,
    'country': 10000000,
    'region': 5000000,
    'city': 500000,
    'district': 100000,
    'neighborhood': 25000,
    'street': 10000,
    'building': 5000,
    'detail': 1000,
  };

  static Future<ArcGISMap> createConfiguredMap() async {
    try {
      final portal = Portal.arcGISOnline();
      final portalItem = PortalItem.withPortalAndItemId(
        portal: portal,
        itemId: webMapId,
      );
      final map = ArcGISMap.withItem(portalItem);
      await map.load();
      await _configureMapSettings(map);
      return map;
    } catch (e) {
      debugPrint('Failed to create configured map: $e');
      return _createFallbackMap();
    }
  }

  static Future<void> _configureMapSettings(ArcGISMap map) async {
    try {
      map.referenceScale = 0;
      debugPrint('Map settings applied');
    } catch (e) {
      debugPrint('Error applying map settings: $e');
    }
  }

  static ArcGISMap _createFallbackMap() {
    final basemap = Basemap.withStyle(BasemapStyle.arcGISStreets);
    return ArcGISMap.withBasemap(basemap);
  }

  static Viewpoint createInitialViewpoint() {
    return Viewpoint.withLatLongScale(
      latitude: maltaLatitude,
      longitude: maltaLongitude,
      scale: initialScale,
    );
  }

  static Viewpoint createLocationViewpoint(double latitude, double longitude) {
    return Viewpoint.withLatLongScale(
      latitude: latitude,
      longitude: longitude,
      scale: locationZoomScale,
    );
  }

  static Viewpoint createNavigationViewpoint(double latitude, double longitude) {
    return Viewpoint.withLatLongScale(
      latitude: latitude,
      longitude: longitude,
      scale: navigationZoomScale,
    );
  }

  static Map<String, SimpleLineSymbol> getRouteSymbols() {
    return {
      'walking': SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.green,
        width: 5,
      ),
      'driving': SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.blue,
        width: 5,
      ),
      'cycling': SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.orange,
        width: 5,
      ),
    };
  }

  static Map<String, SimpleMarkerSymbol> getMarkerSymbols() {
    return {
      'destination': SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.diamond,
        color: Colors.red,
        size: 16,
      ),
      'origin': SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.green,
        size: 12,
      ),
      'poi': SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.square,
        color: Colors.purple,
        size: 10,
      ),
      'waypoint': SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.orange,
        size: 8,
      ),
    };
  }

  static SimpleMarkerSymbol getLocationSymbol() {
    return SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.circle,
      color: const Color(0xFF007AFF),
      size: 20,
    );
  }

  static SimpleMarkerSymbol getNavigationSymbol() {
    return SimpleMarkerSymbol(
      style: SimpleMarkerSymbolStyle.triangle,
      color: const Color(0xFF007AFF),
      size: 20,
    );
  }

  static SimpleFillSymbol getAccuracySymbol() {
    return SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: const Color(0x330080FF),
      outline: SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: const Color(0x990080FF),
        width: 1,
      ),
    );
  }

  static Map<String, Map<String, dynamic>> getTransportConfigurations() {
    return {
      'walking': {
        'displayName': 'Walking',
        'icon': Icons.directions_walk,
        'color': Colors.green,
        'speedKmh': 5.0,
        'impedanceAttribute': 'WalkTime',
      },
      'driving': {
        'displayName': 'Driving',
        'icon': Icons.directions_car,
        'color': Colors.blue,
        'speedKmh': 50.0,
        'impedanceAttribute': 'TravelTime',
      },
      'cycling': {
        'displayName': 'Cycling',
        'icon': Icons.directions_bike,
        'color': Colors.orange,
        'speedKmh': 15.0,
        'impedanceAttribute': 'WalkTime',
      },
    };
  }

  static LocationDisplayAutoPanMode getAutoPanMode(String mode) {
    return switch (mode.toLowerCase()) {
      'navigation' => LocationDisplayAutoPanMode.navigation,
      'recenter' => LocationDisplayAutoPanMode.recenter,
      'compassnavigation' => LocationDisplayAutoPanMode.compassNavigation,
      _ => LocationDisplayAutoPanMode.off,
    };
  }

  static double getZoomLevel(String level) =>
      zoomLevels[level.toLowerCase()] ?? initialScale;

  static Map<String, dynamic> getLayerConfigurations() {
    return {
      'traffic': {'visible': true, 'opacity': 0.8},
      'transit': {'visible': false, 'opacity': 0.7},
      'poi': {'visible': true, 'opacity': 1.0},
      'terrain': {'visible': false, 'opacity': 0.6},
    };
  }

  static Map<String, bool> getGestureConfigurations() {
    return {
      'pan': true,
      'zoom': true,
      'rotate': true,
      'tilt': false,
      'doubleTapZoom': true,
      'pinchZoom': true,
      'longPress': true,
    };
  }
}
