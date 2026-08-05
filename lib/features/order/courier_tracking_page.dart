import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/constants/app_assets.dart';
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
  final MapController _mapController = MapController();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Koordinat Tujuan (Lokasi Pembeli)
  late final LatLng _destination;

  // Titik Awal Kurir (Toko / Gudang)
  late final LatLng _startLocation;

  // Lokasi Kurir Sekarang
  late LatLng _courierLocation;
  
  Timer? _simulationTimer;
  RealtimeChannel? _trackingChannel;
  int _step = 0;
  final int _totalSteps = 20; 

  @override
  void initState() {
    super.initState();
    _startLocation = widget.startCoordinates ?? const LatLng(3.5800, 98.6500);
    _destination = widget.destinationCoordinates ?? const LatLng(3.5952, 98.6722);
    _courierLocation = _startLocation;

    _initRealtimeChannel();

    _startDummyCourierMovement();
  }

  void _initRealtimeChannel() {
    _trackingChannel = _supabase.channel('tracking:${widget.orderId}');

    _trackingChannel!.onBroadcast(
      event: 'location_update',
      callback: (payload) {
        final lat = payload['lat'] as double;
        final lng = payload['lng'] as double;

        if (mounted) {
          setState(() {
            _courierLocation = LatLng(lat, lng);
          });
          // Geser kamera peta mengikuti kurir
          _mapController.move(_courierLocation, 15.0);
        }
      },
    ).subscribe();
  }

  void _startDummyCourierMovement() {
    // Simulasi kurir bergerak setiap 3 detik
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_step >= _totalSteps) {
        timer.cancel();
        _showArrivedDialog();
        return;
      }

      _step++;

      // Interpolasi Linier (Menghitung koordinat dari Titik A ke Titik B)
      double lat = _startLocation.latitude +
          (_destination.latitude - _startLocation.latitude) * (_step / _totalSteps);
      double lng = _startLocation.longitude +
          (_destination.longitude - _startLocation.longitude) * (_step / _totalSteps);

      // Kirim koordinat baru via Supabase Broadcast (Sangat Cepat & Gratis)
      _trackingChannel?.sendBroadcastMessage(
        event: 'location_update',
        payload: {'lat': lat, 'lng': lng},
      );
    });
  }

  void _showArrivedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesanan Tiba!'),
        content: const Text('Kurir telah sampai di lokasi pengiriman.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _trackingChannel?.unsubscribe();
    _mapController.dispose();
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _courierLocation,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nextcart.app',
              ),
              // Garis Rute Pengiriman
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_startLocation, _destination],
                    strokeWidth: 4.0,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ],
              ),
              // Marker Lokasi
              MarkerLayer(
                markers: [
                  // Marker Tujuan (Pembeli)
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
                  // Marker Kurir (Motor)
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
          
          // Card Info Pengiriman
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
                            'Budi (Kurir Nextcart)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _step >= _totalSteps
                                ? 'Pesanan Sampai'
                                : 'Sedang Mengantar Pesanan...',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
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