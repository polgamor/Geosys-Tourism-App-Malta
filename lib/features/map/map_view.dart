import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'map_interactions.dart';
import 'map_location.dart';
import 'route_service.dart';
import '../../colors.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin {
  late final ArcGISMapViewController _mapViewController;
  final MapInteractions _interactions = MapInteractions();
  final MapLocation _location = MapLocation();
  final RouteService _routeService = RouteService();
  
  bool _isLocationEnabled = false;
  bool _showRouteButtons = false;
  ArcGISPoint? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _mapViewController = ArcGISMapView.createController();
    _loadWebMap();
  }

  Future<void> _loadWebMap() async {
    try {
      final portal = Portal.arcGISOnline();
      final portalItem = PortalItem.withPortalAndItemId(
        portal: portal,
        itemId: '8543defad02b4dc6a7270d4c2add7045',
      );
      final map = ArcGISMap.withItem(portalItem);
      await map.load();
      _mapViewController.arcGISMap = map;
      _mapViewController.setViewpoint(
        Viewpoint.withLatLongScale(
          latitude: 35.9375,
          longitude: 14.3755,
          scale: 500000,
        ),
      );
      if (mounted) {
        _interactions.setupMapInteractions(_mapViewController, context, _onDestinationSelected);
        _location.setupLocation(_mapViewController);
        _routeService.setupRouteService(_mapViewController);
      }
    } catch (e) {
      print('Error al cargar el WebMap: $e');
    }
  }

  void _onDestinationSelected(ArcGISPoint destination) {
    setState(() {
      _selectedDestination = destination;
      _showRouteButtons = true;
    });
  }

  Future<void> _toggleLocation() async {
    final success = await _location.toggleLocation();
    if (success) {
      setState(() {
        _isLocationEnabled = !_isLocationEnabled;
      });
    }
  }

  Future<void> _centerOnLocation() async {
    await _location.centerOnLocation();
  }

  Future<void> _zoomIn() async {
    await _mapViewController.setViewpointScale(_mapViewController.getCurrentViewpoint(ViewpointType.centerAndScale)!.targetScale * 0.5);
  }

  Future<void> _zoomOut() async {
    await _mapViewController.setViewpointScale(_mapViewController.getCurrentViewpoint(ViewpointType.centerAndScale)!.targetScale * 2.0);
  }

  Future<void> _calculateRoute(TransportMode mode) async {
    if (_selectedDestination == null) return;
    
    final success = await _routeService.calculateRoute(
      destination: _selectedDestination!,
      transportMode: mode,
    );
    
    if (success) {
      setState(() {
        _showRouteButtons = false;
      });
      
      // Mostrar diálogo con información de la ruta
      final routeInfo = _routeService.getLastRouteInfo();
      if (routeInfo != null && mounted) {
        _showRouteDialog(routeInfo);
      }
    }
  }

  void _showRouteDialog(Map<String, dynamic> routeInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Ruta Calculada',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distancia: ${routeInfo['distance']} km',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              'Tiempo estimado: ${routeInfo['time']} min',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              'Modo: ${routeInfo['mode']}',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearRoute();
            },
            child: Text('Limpiar Ruta', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _clearRoute() {
    _routeService.clearRoute();
    setState(() {
      _selectedDestination = null;
      _showRouteButtons = false;
    });
  }

  @override
  void dispose() {
    _mapViewController.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: () {
              print('Mapa público listo');
              if (_mapViewController.arcGISMap == null) {
                print('Error: Mapa no cargado, verifica la ID del WebMap');
              }
            },
            onTap: (screenPoint) => _interactions.handleMapTap(screenPoint),
          ),
          
          // Botones de zoom
          Positioned(
            top: 100,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: AppColors.primary,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: AppColors.primary,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Botones de ubicación
          Positioned(
            bottom: 200,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "location_toggle",
                  backgroundColor: _isLocationEnabled ? AppColors.primary : AppColors.grey,
                  onPressed: _toggleLocation,
                  child: Icon(
                    _isLocationEnabled ? Icons.location_on : Icons.location_off,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "center_location",
                  mini: true,
                  backgroundColor: AppColors.primary,
                  onPressed: _centerOnLocation,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Botones de ruta (solo se muestran cuando hay destino seleccionado)
          if (_showRouteButtons)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Calcular ruta al destino',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRouteButton(
                          icon: Icons.directions_walk,
                          label: 'Caminar',
                          onPressed: () => _calculateRoute(TransportMode.walking),
                        ),
                        _buildRouteButton(
                          icon: Icons.directions_car,
                          label: 'Coche',
                          onPressed: () => _calculateRoute(TransportMode.driving),
                        ),
                        _buildRouteButton(
                          icon: Icons.directions_bike,
                          label: 'Bici',
                          onPressed: () => _calculateRoute(TransportMode.cycling),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showRouteButtons = false;
                          _selectedDestination = null;
                        });
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Botón de limpiar ruta
          if (_routeService.hasActiveRoute)
            Positioned(
              bottom: 140,
              left: 16,
              child: FloatingActionButton(
                heroTag: "clear_route",
                mini: true,
                backgroundColor: Colors.red,
                onPressed: _clearRoute,
                child: const Icon(Icons.clear, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}