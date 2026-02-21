import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

enum TransportMode {
  walking('WalkTime', 'Walking', Icons.directions_walk, Colors.green),
  driving('TravelTime', 'Driving', Icons.directions_car, Colors.blue),
  cycling('WalkTime', 'Cycling', Icons.directions_bike, Colors.orange);

  const TransportMode(this.arcgisValue, this.displayName, this.icon, this.color);

  final String arcgisValue;
  final String displayName;
  final IconData icon;
  final Color color;
}

class RouteService {
  late ArcGISMapViewController _mapViewController;
  final GraphicsOverlay _routeOverlay = GraphicsOverlay();
  RouteTask? _routeTask;
  Map<String, dynamic>? _lastRouteInfo;
  bool _hasActiveRoute = false;

  void setupRouteService(ArcGISMapViewController controller) {
    _mapViewController = controller;
    _mapViewController.graphicsOverlays.add(_routeOverlay);
    _initializeRouteTask();
  }

  Future<void> _initializeRouteTask() async {
    try {
      final routeServiceUrl = Uri.parse(
        'https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World',
      );
      _routeTask = RouteTask.withUri(routeServiceUrl);
      await _routeTask!.load();
      debugPrint('Route service initialised successfully');
    } catch (e) {
      debugPrint('Failed to initialise route service: $e');
    }
  }

  Future<bool> calculateRoute({
    required ArcGISPoint destination,
    required TransportMode transportMode,
  }) async {
    if (_routeTask == null) {
      debugPrint('Route service not initialised');
      return false;
    }

    try {
      final currentLocation = _mapViewController.locationDisplay.location;
      if (currentLocation == null) {
        debugPrint('Could not retrieve current location');
        return false;
      }

      final origin = ArcGISPoint(
        x: currentLocation.position.x,
        y: currentLocation.position.y,
        spatialReference: SpatialReference.wgs84,
      );

      final routeParameters = await _routeTask!.createDefaultParameters();
      routeParameters.setStops([Stop(origin), Stop(destination)]);
      routeParameters.returnDirections = true;
      routeParameters.returnRoutes = true;
      routeParameters.returnStops = true;
      routeParameters.directionsDistanceUnits = UnitSystem.metric;

      final routeResult = await _routeTask!.solveRoute(routeParameters);

      if (routeResult.routes.isNotEmpty) {
        final route = routeResult.routes.first;
        await _displayRoute(route, transportMode);
        _storeRouteInfo(route, transportMode);
        _hasActiveRoute = true;
        return true;
      } else {
        debugPrint('No route could be calculated');
        return false;
      }
    } catch (e) {
      debugPrint('Failed to calculate route: $e');
      return false;
    }
  }

  Future<void> _displayRoute(ArcGISRoute route, TransportMode transportMode) async {
    try {
      _routeOverlay.graphics.clear();

      final routeSymbol = SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: transportMode.color,
        width: 5,
      );

      final routeGeometry = route.routeGeometry;
      if (routeGeometry != null) {
        _routeOverlay.graphics.add(
          Graphic(geometry: routeGeometry, symbol: routeSymbol),
        );
      }

      await _addRouteMarkers(route);

      if (routeGeometry != null) {
        _mapViewController.setViewpoint(Viewpoint.fromTargetExtent(routeGeometry));
      }
    } catch (e) {
      debugPrint('Failed to display route: $e');
    }
  }

  Future<void> _addRouteMarkers(ArcGISRoute route) async {
    try {
      final startSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.green,
        size: 12,
      );
      final endSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.red,
        size: 12,
      );

      final routeGeometry = route.routeGeometry;
      if (routeGeometry is Polyline) {
        final points = routeGeometry.parts.first.getPoints();
        if (points.isNotEmpty) {
          _routeOverlay.graphics
            ..add(Graphic(geometry: points.first, symbol: startSymbol))
            ..add(Graphic(geometry: points.last, symbol: endSymbol));
        }
      }
    } catch (e) {
      debugPrint('Failed to add route markers: $e');
    }
  }

  void _storeRouteInfo(ArcGISRoute route, TransportMode transportMode) {
    try {
      _lastRouteInfo = {
        'distance': route.totalLength.toStringAsFixed(2),
        'time': route.travelTime.toStringAsFixed(0),
        'mode': transportMode.displayName,
        'directions': route.directionManeuvers
            .map((m) => m.directionText)
            .toList(),
      };
      debugPrint('Route info stored: $_lastRouteInfo');
    } catch (e) {
      debugPrint('Failed to store route info: $e');
    }
  }

  void clearRoute() {
    _routeOverlay.graphics.clear();
    _lastRouteInfo = null;
    _hasActiveRoute = false;
  }

  Map<String, dynamic>? getLastRouteInfo() => _lastRouteInfo;
  bool get hasActiveRoute => _hasActiveRoute;

  List<String> getDirections() {
    final directions = _lastRouteInfo?['directions'];
    return directions != null ? List<String>.from(directions) : [];
  }
}
