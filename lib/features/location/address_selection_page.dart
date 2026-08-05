import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nextcart/core/theme/app_colors.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LatLng? _selectedLocation;
  String _currentAddress = "Mencari lokasi...";
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose(); 
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchAddress(query);
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _currentAddress = "Layanan lokasi tidak aktif";
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _currentAddress = "Izin lokasi ditolak";
        });
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    final userLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      _selectedLocation = userLocation;
    });
    _mapController.move(userLocation, 15.0);
    _getAddressFromLatLng(userLocation);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
      final response = await http.get(url, headers: {
        'User-Agent': 'NextcartApp/1.0',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentAddress = data['display_name'] ?? 'Alamat tidak ditemukan';
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentAddress = "Gagal mengambil alamat";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Gagal mengambil alamat";
        _isLoading = false;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=6&addressdetails=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'NextcartApp/1.0',
      });
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _searchResults = data.cast<Map<String, dynamic>>();
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _onSearchResultSelected(Map<String, dynamic> result) {
    final lat = double.tryParse(result['lat'].toString());
    final lon = double.tryParse(result['lon'].toString());
    if (lat == null || lon == null) return;
    final location = LatLng(lat, lon);
    setState(() {
      _selectedLocation = location;
      _currentAddress = result['display_name'] ?? _currentAddress;
      _searchResults = [];
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
    _mapController.move(location, 16.0);
  }

  // --- FUNGSI PROSES ZOOM HANDLER ---
  void _zoom(double amount) {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + amount);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(3.5952, 98.6722),
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Blokir rotasi jari agar performa UI stabil
              ),
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                  _searchResults = [];
                });
                _searchFocusNode.unfocus();
                _getAddressFromLatLng(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nextcart.app',
                // --- OPTIMASI KINERJA RENDER MEMORI PETA ---
                keepBuffer: 2, // Menyimpan tile layer ekstra agar tidak kedip/blank putih saat digeser
                panBuffer: 1,  
                tileDisplay: const TileDisplay.fadeIn(duration: Duration(milliseconds: 150)), // Animasi fading singkat agar smooth
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Pencarian Lokasi Atas
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Column(
              children: [
                _buildTopBar(colors),
                if (_searchResults.isNotEmpty || _isSearching)
                  _buildSearchResults(colors),
              ],
            ),
          ),

          Positioned(
            bottom: 170,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoomInBtn',
                  backgroundColor: colors.card,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  onPressed: () => _zoom(1.0),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOutBtn',
                  backgroundColor: colors.card,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  onPressed: () => _zoom(-1.0),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'myLocationBtn',
                  backgroundColor: colors.card,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _determinePosition();
                  },
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          
          // Panel Info Konfirmasi Alamat Bawah
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildAddressPanel(colors),
          ),
        ],
      ),
    );
  }

  // ... (_buildTopBar, _buildSearchResults, _buildAddressPanel tetap sama seperti bawaan anda) ...
  Widget _buildTopBar(AppColorScheme colors) {
    return Row(
      children: [
        Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_back, color: colors.textPrimary, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari alamat, jalan, atau tempat...',
                hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: colors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(AppColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.08),
             blurRadius: 8,
             offset: const Offset(0, 2),
           ),
        ],
      ),
      child: _isSearching
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _searchResults.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: colors.divider),
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.location_on_outlined, color: colors.textSecondary, size: 20),
                  title: Text(
                    result['display_name'] ?? '',
                    style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _onSearchResultSelected(result),
                );
              },
            ),
    );
  }

  Widget _buildAddressPanel(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Terpilih',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _isLoading
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: LinearProgressIndicator(
                              backgroundColor: colors.inputFill,
                              color: AppColors.primary,
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : Text(
                            _currentAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: colors.inputFill,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: (_isLoading || _selectedLocation == null)
                  ? null
                  : () => Navigator.pop(context, _currentAddress),
              child: Text(
                'Gunakan Alamat Ini',
                style: TextStyle(
                  color: (_isLoading || _selectedLocation == null)
                      ? colors.textHint
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}