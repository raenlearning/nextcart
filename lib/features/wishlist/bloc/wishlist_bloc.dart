import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/data/repository/wishlist_repository.dart';

// --- EVENTS ---
abstract class WishlistEvent {}

class WishlistLoad extends WishlistEvent {}

class WishlistToggle extends WishlistEvent {
  final String productId;
  WishlistToggle(this.productId);
}

class WishlistRemove extends WishlistEvent {
  final String productId;
  WishlistRemove(this.productId);
}

class WishlistLoadList extends WishlistEvent {
  final String? search;
  final String? categoryId;
  final String sortBy;
  final int page;
  final bool refresh;

  WishlistLoadList({
    this.search,
    this.categoryId,
    this.sortBy = 'newest',
    this.page = 1,
    this.refresh = false,
  });
}

class WishlistClearError extends WishlistEvent {}

// --- STATES ---
abstract class WishlistState {
  const WishlistState();
}

class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistLoaded extends WishlistState {
  final Set<String> productIds;
  final bool isLoading;

  const WishlistLoaded({
    this.productIds = const {},
    this.isLoading = false,
  });

  bool contains(String productId) => productIds.contains(productId);

  WishlistLoaded copyWith({
    Set<String>? productIds,
    bool? isLoading,
  }) {
    return WishlistLoaded(
      productIds: productIds ?? this.productIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WishlistListLoaded extends WishlistState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final bool hasMore;

  const WishlistListLoaded({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
  });

  WishlistListLoaded copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    bool? hasMore,
  }) {
    return WishlistListLoaded(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class WishlistError extends WishlistState {
  final String message;
  const WishlistError(this.message);
}

// --- BLOC ---
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _repository;
  static const _pageSize = 20;

  String? _search;
  String? _categoryId;
  String _sortBy = 'newest';
  int _page = 1;

  WishlistBloc({WishlistRepository? repository})
      : _repository = repository ?? WishlistRepository(),
        super(const WishlistInitial()) {
    on<WishlistLoad>(_onLoad);
    on<WishlistToggle>(_onToggle);
    on<WishlistRemove>(_onRemove);
    on<WishlistLoadList>(_onLoadList);
    on<WishlistClearError>(_onClearError);
  }

  bool contains(String productId) {
    final current = state;
    return current is WishlistLoaded && current.contains(productId);
  }

  Future<void> _onLoad(WishlistLoad event, Emitter<WishlistState> emit) async {
    emit(const WishlistLoaded(isLoading: true));
    try {
      final ids = await _repository.fetchWishlistedProductIds();
      emit(WishlistLoaded(productIds: ids));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onToggle(
    WishlistToggle event,
    Emitter<WishlistState> emit,
  ) async {
    final current = state;
    final Set<String> base = current is WishlistLoaded
        ? current.productIds
        : const <String>{};

    final Set<String> optimistic = Set<String>.from(base);
    if (optimistic.contains(event.productId)) {
      optimistic.remove(event.productId);
    } else {
      optimistic.add(event.productId);
    }
    emit(WishlistLoaded(productIds: optimistic));

    try {
      if (optimistic.contains(event.productId)) {
        await _repository.addToWishlist(event.productId);
      } else {
        await _repository.removeFromWishlist(event.productId);
      }
    } catch (e) {
      // rollback optimistik
      emit(WishlistLoaded(productIds: base));
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onRemove(
    WishlistRemove event,
    Emitter<WishlistState> emit,
  ) async {
    final current = state;
    if (current is WishlistLoaded) {
      final ids = Set<String>.from(current.productIds)..remove(event.productId);
      emit(WishlistLoaded(productIds: ids));
    }

    try {
      await _repository.removeFromWishlist(event.productId);
      // Update daftar halaman secara lokal tanpa refetch (hemat 1 round-trip).
      final listState = state;
      if (listState is WishlistListLoaded) {
        emit(listState.copyWith(
          items: listState.items
              .where((item) =>
                  ((item['products'] as Map<String, dynamic>?)?['id']) !=
                  event.productId)
              .toList(),
        ));
      }
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onLoadList(
    WishlistLoadList event,
    Emitter<WishlistState> emit,
  ) async {
    _search = event.search;
    _categoryId = event.categoryId;
    _sortBy = event.sortBy;
    _page = event.page;

    final current = state;
    final List<Map<String, dynamic>> existing =
        (current is WishlistListLoaded && !event.refresh)
            ? current.items
            : const [];

    emit(
      event.refresh
          ? const WishlistListLoaded(isLoading: true)
          : WishlistListLoaded(
              items: existing,
              isLoading: true,
              hasMore: _page > 1,
            ),
    );

    try {
      final items = await _repository.fetchWishlist(
        search: _search,
        categoryId: _categoryId,
        sortBy: _sortBy,
        page: _page,
        pageSize: _pageSize,
      );

      final merged = event.refresh || _page == 1
          ? items
          : [...existing, ...items];
      final hasMore = items.length >= _pageSize;

      emit(WishlistListLoaded(items: merged, hasMore: hasMore));
    } catch (e) {
      if (event.refresh) {
        emit(WishlistListLoaded(
          items: existing,
          hasMore: _page > 1,
        ));
      } else {
        emit(WishlistListLoaded(items: existing, hasMore: true));
      }
      emit(WishlistError(e.toString()));
    }
  }

  void _onClearError(WishlistClearError event, Emitter<WishlistState> emit) {
    final current = state;
    if (current is WishlistError) {
      emit(const WishlistLoaded());
    }
  }
}
