import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/service/map_tile_provider.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class CourierTrackingPage extends StatefulWidget {
  final String orderId;
  final String destinationAddress;
  final LatLng? destinationCoordinates;
  final LatLng? startCoordinates;

  const CourierTrackingPage({
    super.key,
    required this.orderId,
    required this.destinationAddress,
    this.destinationCoordinates,
    this.startCoordinates,
  });

  @override
  State<CourierTrackingPage> createState() => _CourierTrackingPageState();
}

class _CourierTrackingPageState extends State<CourierTrackingPage> {
  static const Duration _tickInterval = Duration(milliseconds: 600);
  static const int _journeySeconds = 60;
  static const int _broadcastEveryNTicks = 5;

  final MapController _mapController = MapController();
  final SupabaseClient _supabase = Supabase.instance.client;

  late final LatLng _startLocation;
  late final LatLng _destination;
  late LatLng _courierLocation;

  List<LatLng> _routePoints = [];
  List<double> _cumulativeDistances = [];
  double _totalDistance = 0;

  Timer? _simulationTimer;
  Timer? _throttleTimer;
  RealtimeChannel? _trackingChannel;

  double _progress = 0;
  int _tickCount = 0;
  bool _arrived = false;

  LatLng? _pendingLocation;
  DateTime _lastMapUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  List<LatLng> get _path =>
      _routePoints.isNotEmpty ? _routePoints : [_startLocation, _destination];

  @override
  void initState() {
    super.initState();
    _startLocation = widget.startCoordinates ?? const LatLng(3.5800, 98.6500);
    _destination = widget.destinationCoordinates ?? const LatLng(3.5952, 98.6722);
    _courierLocation = _startLocation;

    _initRealtimeChannel();
    _loadRoute();
    _startSimulation();
  }

  Future<void> _loadRoute() async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${_startLocation.longitude},${_startLocation.latitude};'
          '${_destination.longitude},${_destination.latitude}'
          '?overview=full&geometries=geojson';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 || !mounted) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return;

      final coordinates =
          (routes.first as Map<String, dynamic>)['geometry']['coordinates']
              as List;
      final points = coordinates
          .map((c) =>
              LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      if (points.length < 2 || !mounted) return;

      setState(() {
        _routePoints = points;
        _computeDistances();
      });
    } catch (_) {
      // Fallback: tetap pakai garis lurus start -> destination.
    }
  }

  void _computeDistances() {
    _cumulativeDistances = [0];
    _totalDistance = 0;
    for (var i = 1; i < _routePoints.length; i++) {
      _totalDistance += _distance(_routePoints[i - 1], _routePoints[i]);
      _cumulativeDistances.add(_totalDistance);
    }
  }

  double _distance(LatLng a, LatLng b) {
    const Distance dist = Distance();
    return dist(a, b);
  }

  LatLng _pointAtProgress(double t) {
    final path = _path;
    if (t <= 0) return path.first;
    if (t >= 1) return path.last;

    if (_routePoints.isEmpty || _totalDistance <= 0) {
      return LatLng(
        path.first.latitude +
            (path.last.latitude - path.first.latitude) * t,
        path.first.longitude +
            (path.last.longitude - path.first.longitude) * t,
      );
    }

    final target = t * _totalDistance;
    for (var i = 1; i < _routePoints.length; i++) {
      if (_cumulativeDistances[i] >= target) {
        final segStart = _cumulativeDistances[i - 1];
        final segLen = _cumulativeDistances[i] - segStart;
        if (segLen <= 0) return _routePoints[i];
        final f = (target - segStart) / segLen;
        return LatLng(
          _routePoints[i - 1].latitude +
              (_routePoints[i].latitude - _routePoints[i - 1].latitude) * f,
          _routePoints[i - 1].longitude +
              (_routePoints[i].longitude - _routePoints[i - 1].longitude) * f,
        );
      }
    }
    return path.last;
  }

  void _initRealtimeChannel() {
    _trackingChannel = _supabase.channel('tracking:${widget.orderId}');

    _trackingChannel!.onBroadcast(
      event: 'location_update',
      callback: (payload) {
        final lat = payload['lat'] as double;
        final lng = payload['lng'] as double;
        _onLocationUpdate(LatLng(lat, lng));
      },
    ).subscribe();
  }

  void _startSimulation() {
    final ticksTotal = _journeySeconds * 1000 ~/ _tickInterval.inMilliseconds;

    _simulationTimer = Timer.periodic(_tickInterval, (timer) {
      if (!mounted || _arrived) {
        timer.cancel();
        return;
      }

      _tickCount++;
      final nextProgress =
          (_progress + 1 / ticksTotal).clamp(0.0, 1.0);
      _progress = nextProgress;
      _courierLocation = _pointAtProgress(nextProgress);

      _lastMapUpdate = DateTime.now();
      _mapController.move(_courierLocation, 15.0);
      setState(() {});

      if (_tickCount % _broadcastEveryNTicks == 0) {
        _trackingChannel?.sendBroadcastMessage(
          event: 'location_update',
          payload: {
            'lat': _courierLocation.latitude,
            'lng': _courierLocation.longitude,
          },
        );
      }

      if (_progress >= 1) {
        _arrived = true;
        timer.cancel();
        _showArrivedDialog();
      }
    });
  }

  void _applyCourierLocation(LatLng location) {
    if (!mounted) return;
    setState(() => _courierLocation = location);
    _lastMapUpdate = DateTime.now();
    _mapController.move(location, 15.0);
  }

  void _onLocationUpdate(LatLng location) {
    _pendingLocation = location;
    if (DateTime.now().difference(_lastMapUpdate) >=
        const Duration(seconds: 1)) {
      _applyCourierLocation(location);
      _pendingLocation = null;
      _throttleTimer?.cancel();
      _throttleTimer = null;
    } else {
      _throttleTimer ??= Timer(const Duration(milliseconds: 400), () {
        _throttleTimer = null;
        final pending = _pendingLocation;
        if (pending != null) {
          _pendingLocation = null;
          _applyCourierLocation(pending);
        }
      });
    }
  }

  void _showArrivedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colors = dialogContext.colors;
        return Dialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                lottie.Lottie.asset(
                  AppAssets.deliveryTruck,
                  width: 150,
                  height: 150,
                  repeat: true,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pesanan Tiba!',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kurir telah sampai di lokasi pengiriman.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _throttleTimer?.cancel();
    _trackingChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lacak Kurir - #${widget.orderId.substring(0, 6)}'),
        backgroundColor: colors.card,
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _courierLocation,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nextcart.app',
                  tileProvider: buildMapTileProvider(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _path,
                      strokeWidth: 4.0,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _destination,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: _courierLocation,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.two_wheeler,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    lottie.Lottie.asset(
                      AppAssets.deliveryTruck,
                      width: 40,
                      height: 40,
                      repeat: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Gio (Kurir)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _arrived
                                ? 'Pesanan Sampai'
                                : 'Sedang Mengantar Pesanan... '
                                    '(${(_progress * 100).round()}%)',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _arrived ? 1 : _progress,
                              minHeight: 5,
                              backgroundColor: colors.inputFill,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
