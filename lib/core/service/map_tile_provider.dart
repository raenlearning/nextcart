import 'package:flutter_map/flutter_map.dart';

TileProvider buildMapTileProvider() => NetworkTileProvider(
      cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
        maxCacheSize: 512 * 1024 * 1024,
        overrideFreshAge: const Duration(days: 14),
      ),
    );