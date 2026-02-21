import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

enum TransportMode {
  walking('WalkTime', 'Caminando', Icons.directions_walk, Colors.green),
  driving('TravelTime', 'Conduciendo', Icons.directions_car, Colors.blue),
  cycling('WalkTime', 'Ciclismo', Icons.directions_bike, Colors.orange);

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
      print('Servicio de rutas inicializado correctamente');
    } catch (e) {
      print('Error al inicializar el servicio de rutas: $e');
    }
  }

  Future<bool> calculateRoute({
    required ArcGISPoint destination,
    required TransportMode transportMode,
  }) async {
    if (_routeTask == null) {
      print('Servicio de rutas no inicializado');
      return false;
    }

    try {
      // Obtener ubicación actual
      final currentLocation = _mapViewController.locationDisplay.location;
      if (currentLocation == null) {
        print('No se pudo obtener la ubicación actual');
        return false;
      }

      // Crear punto de origen
      final origin = ArcGISPoint(
        x: currentLocation.position.x,
        y: currentLocation.position.y,
        spatialReference: SpatialReference.wgs84,
      );

      // Crear parámetros de ruta
      final routeParameters = await _routeTask!.createDefaultParameters();
      
      // Configurar paradas
      final stops = [
        Stop(origin),
        Stop(destination),
      ];
      routeParameters.setStops(stops);

      // Configurar parámetros
      routeParameters.returnDirections = true;
      routeParameters.returnRoutes = true;
      routeParameters.returnStops = true;
      routeParameters.directionsDistanceUnits = UnitSystem.metric;

      // Resolver la ruta
      final routeResult = await _routeTask!.solveRoute(routeParameters);
      
      if (routeResult.routes.isNotEmpty) {
        final route = routeResult.routes.first;
        await _displayRoute(route, transportMode);
        _storeRouteInfo(route, transportMode);
        _hasActiveRoute = true;
        return true;
      } else {
        print('No se pudo calcular la ruta');
        return false;
      }
    } catch (e) {
      print('Error al calcular la ruta: $e');
      return false;
    }
  }

  Future<void> _displayRoute(ArcGISRoute route, TransportMode transportMode) async {
    try {
      // Limpiar rutas anteriores
      _routeOverlay.graphics.clear();

      // Crear símbolo para la ruta
      final routeSymbol = SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: transportMode.color,
        width: 5,
      );

      // Crear gráfico de la ruta
      final routeGeometry = route.routeGeometry;
      if (routeGeometry != null) {
        final routeGraphic = Graphic(
          geometry: routeGeometry,
          symbol: routeSymbol,
        );
        _routeOverlay.graphics.add(routeGraphic);
      }

      // Añadir marcadores de inicio y fin
      await _addRouteMarkers(route);

      // Ajustar vista para mostrar toda la ruta - CORREGIDO
      if (routeGeometry != null) {
        // Crear el viewpoint usando el método correcto 'fromTargetExtent'
        final viewpoint = Viewpoint.fromTargetExtent(routeGeometry);

        // Usar setViewpoint (retorna void) - CORREGIDO
        _mapViewController.setViewpoint(viewpoint);
      }
    } catch (e) {
      print('Error al mostrar la ruta: $e');
    }
  }

  Future<void> _addRouteMarkers(ArcGISRoute route) async {
    try {
      // Marcador de inicio (verde)
      final startSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.green,
        size: 12,
      );

      // Marcador de fin (rojo)
      final endSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: Colors.red,
        size: 12,
      );

      // Obtener puntos de inicio y fin de la geometría de la ruta
      final routeGeometry = route.routeGeometry;
      if (routeGeometry is Polyline) {
        final polyline = routeGeometry;
        final part = polyline.parts.first;
        final points = part.getPoints();
        
        if (points.isNotEmpty) {
          final startPoint = points.first;
          final endPoint = points.last;

          // Añadir marcadores
          _routeOverlay.graphics.add(
            Graphic(geometry: startPoint, symbol: startSymbol),
          );
          _routeOverlay.graphics.add(
            Graphic(geometry: endPoint, symbol: endSymbol),
          );
        }
      }
    } catch (e) {
      print('Error al añadir marcadores de ruta: $e');
    }
  }

  void _storeRouteInfo(ArcGISRoute route, TransportMode transportMode) {
    try {
      // Obtener distancia en kilómetros
      double distanceKm = route.totalLength; // totalLength ya está en kilómetros (UnitSystem.metric)

      // Obtener tiempo en minutos
      double timeMinutes = route.travelTime; // travelTime ya está en minutos

      _lastRouteInfo = {
        'distance': distanceKm.toStringAsFixed(2),
        'time': timeMinutes.toStringAsFixed(0),
        'mode': transportMode.displayName,
        'directions': route.directionManeuvers.map((maneuver) => maneuver.directionText).toList(),
      };

      print('Información de ruta almacenada: $_lastRouteInfo');
    } catch (e) {
      print('Error al almacenar información de ruta: $e');
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
    if (_lastRouteInfo != null && _lastRouteInfo!['directions'] != null) {
      return List<String>.from(_lastRouteInfo!['directions']);
    }
    return [];
  }
}