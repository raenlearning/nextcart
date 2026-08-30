import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/service/address_store.dart';
import 'package:nextcart/data/repository/shipping_repository.dart';
import 'package:nextcart/features/cart/bloc/cart_event.dart';
import 'package:nextcart/features/cart/bloc/cart_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

export 'package:nextcart/features/cart/bloc/cart_event.dart';
export 'package:nextcart/features/cart/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final SupabaseClient _supabase;
  final ShippingRepository _shippingRepository;
  Timer? _orderPollTimer;
  String? _cachedCartId;
  String? _cachedCartUserId;

  CartBloc({SupabaseClient? client, ShippingRepository? shippingRepository})
      : _supabase = client ?? Supabase.instance.client,
        _shippingRepository = shippingRepository ?? ShippingRepository(),
        super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<TriggerCheckout>(_onTriggerCheckout);
    on<ApplyVoucher>(_onApplyVoucher);
    on<ClearVoucher>(_onClearVoucher);
    on<SelectShippingAddress>(_onSelectShippingAddress);
    on<SelectCourier>(_onSelectCourier);
  }

  @override
  Future<void> close() async {
    _cancelOrderPoll();
    return super.close();
  }

  void _cancelOrderPoll() {
    _orderPollTimer?.cancel();
    _orderPollTimer = null;
  }

  Future<String> _waitForOrderStatus(String orderId) {
    final completer = Completer<String>();
    final statuses = {
      OrderStatus.processing,
      OrderStatus.delivered,
      OrderStatus.completed,
      OrderStatus.cancelled,
    };

    const totalBudget = Duration(seconds: 90);
    final start = DateTime.now();
    var delay = const Duration(milliseconds: 1500);

    Future<void> poll() async {
      if (completer.isCompleted) return;
      if (DateTime.now().difference(start) >= totalBudget) {
        if (!completer.isCompleted) {
          completer.complete(OrderStatus.waitingPayment);
        }
        return;
      }

      try {
        final res = await _supabase
            .from('orders')
            .select('status')
            .eq('id', orderId)
            .maybeSingle();
        final status = res?['status'] as String?;
        if (status != null && statuses.contains(status)) {
          if (!completer.isCompleted) completer.complete(status);
          return;
        }
      } catch (_) {
        // Abaikan error sementara, lanjut polling berikutnya.
      }

      if (completer.isCompleted) return;
      _orderPollTimer = Timer(delay, poll);
      delay = Duration(
        milliseconds: (delay.inMilliseconds * 1.6).round().clamp(1500, 6000),
      );
    }

    poll();

    return completer.future;
  }

  Future<String?> _getCartId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    if (_cachedCartUserId == userId && _cachedCartId != null) {
      return _cachedCartId;
    }

    final cart = await _supabase
        .from('carts')
        .select('id')
        .eq('profile_id', userId)
        .maybeSingle();

    if (cart != null) {
      _cachedCartId = cart['id'];
      _cachedCartUserId = userId;
      return cart['id'];
    }

    final newCart = await _supabase
        .from('carts')
        .insert({'profile_id': userId})
        .select('id')
        .maybeSingle();

    if (newCart != null) {
      _cachedCartId = newCart['id'];
      _cachedCartUserId = userId;
    }
    return newCart?['id'];
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    final prev = state;
    emit(CartLoading());
    try {
      final userId = _supabase.auth.currentUser?.id;
      final cartId = await _getCartId();
      if (userId == null || cartId == null) throw Exception('User belum login');

      final data = await _supabase
          .from('cart_items')
          .select('''
      id,
      quantity,
      product_id,
      products(
        id,
        name,
        price,
        stock,
        weight_grams,
        images
      )
    ''')
          .eq('cart_id', cartId)
          .order('created_at', ascending: false);

      final cartItems = List<Map<String, dynamic>>.from(data);

      double total = 0;
      int totalWeight = 0;
      for (var item in cartItems) {
        final product = item['products'] as Map<String, dynamic>?;
        if (product != null) {
          total += (product['price'] as num) * (item['quantity'] as int);
          totalWeight +=
              ((product['weight_grams'] as num?)?.toInt() ?? 0) *
                  (item['quantity'] as int);
        }
      }

      Map<String, dynamic>? keepAddress =
          prev is CartLoaded ? prev.selectedAddress : null;
      if (keepAddress == null) {
        if (!AddressStore.instance.isLoaded) {
          await AddressStore.instance.load();
        }
        final selected = AddressStore.instance.value;
        if (selected != null) {
          keepAddress = {
            'id': selected.id,
            'full_address': selected.fullAddress,
            'province': selected.province,
            'city': selected.city,
            'district': selected.district,
            'postal_code': selected.postalCode,
          };
        }
      }
      emit(CartLoaded(cartItems, total,
          totalWeightGrams: totalWeight, selectedAddress: keepAddress));

      if (keepAddress != null) await _loadRates(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  CartLoaded _copyLoaded(CartLoaded c, {Map<String, dynamic>? voucher}) {
    return CartLoaded(
      c.cartItems,
      c.totalPrice,
      voucher: voucher ?? c.voucher,
      totalWeightGrams: c.totalWeightGrams,
      selectedAddress: c.selectedAddress,
      selectedCourier: c.selectedCourier,
      shippingRates: c.shippingRates,
      shippingFee: c.shippingFee,
    );
  }

  Future<void> _onSelectShippingAddress(
    SelectShippingAddress event,
    Emitter<CartState> emit,
  ) async {
    final current = state;
    if (current is! CartLoaded) return;
    emit(CartLoaded(
      current.cartItems,
      current.totalPrice,
      voucher: current.voucher,
      totalWeightGrams: current.totalWeightGrams,
      selectedAddress: event.address,
    ));
    await _loadRates(emit);
  }

  Future<void> _loadRates(Emitter<CartState> emit) async {
    final current = state;
    if (current is! CartLoaded) return;
    final address = current.selectedAddress;
    if (address == null) return;

    try {
      final rates = await _shippingRepository.fetchRates(
        destPostal: address['postal_code'] as String?,
        destCity: address['city'] as String?,
        weightGrams: current.totalWeightGrams,
      );

      final Map<String, dynamic>? cheapest =
          rates.isNotEmpty ? rates.first : null;
      emit(CartLoaded(
        current.cartItems,
        current.totalPrice,
        voucher: current.voucher,
        totalWeightGrams: current.totalWeightGrams,
        selectedAddress: address,
        shippingRates: rates,
        selectedCourier: cheapest,
        shippingFee: (cheapest?['price'] as num?)?.toDouble() ?? 0,
      ));
    } catch (e) {
      emit(CartLoaded(
        current.cartItems,
        current.totalPrice,
        voucher: current.voucher,
        totalWeightGrams: current.totalWeightGrams,
        selectedAddress: address,
        shippingFee: 0,
      ));
    }
  }

  void _onSelectCourier(SelectCourier event, Emitter<CartState> emit) {
    final current = state;
    if (current is! CartLoaded) return;
    emit(CartLoaded(
      current.cartItems,
      current.totalPrice,
      voucher: current.voucher,
      totalWeightGrams: current.totalWeightGrams,
      selectedAddress: current.selectedAddress,
      shippingRates: current.shippingRates,
      selectedCourier: event.courier,
      shippingFee: (event.courier['price'] as num?)?.toDouble() ?? 0,
    ));
  }

  double calculateDiscount(double subtotal, Map<String, dynamic>? voucher) {
    if (voucher == null || voucher.isEmpty) return 0;
    final type = voucher['discount_type'] as String?;
    final value = (voucher['discount_value'] as num?)?.toDouble() ?? 0;
    if (type == 'percent') {
      double d = subtotal * value / 100;
      final maxDiscount = (voucher['max_discount'] as num?)?.toDouble();
      if (maxDiscount != null && d > maxDiscount) d = maxDiscount;
      return d;
    }
    return value;
  }

  double checkoutTotal(
    double subtotal,
    Map<String, dynamic>? voucher,
    double shippingFee,
  ) {
    final discount = calculateDiscount(subtotal, voucher);
    final discounted = subtotal - discount;
    return discounted + shippingFee;
  }

  Future<void> _onApplyVoucher(ApplyVoucher event, Emitter<CartState> emit) async {
    try {
      final current = state;
      if (current is! CartLoaded) return;

      final data = await _supabase
          .from('vouchers')
          .select()
          .eq('code', event.code.trim())
          .eq('is_active', true)
          .maybeSingle();

      if (data == null) {
        emit(CartError('Kode voucher tidak valid.'));
        return;
      }

      final now = DateTime.now();
      final validFrom = DateTime.tryParse(data['valid_from'] as String? ?? '');
      final validUntil = DateTime.tryParse(data['valid_until'] as String? ?? '');
      if (validFrom != null && now.isBefore(validFrom)) {
        emit(CartError('Voucher belum aktif.'));
        return;
      }
      if (validUntil != null && now.isAfter(validUntil)) {
        emit(CartError('Voucher sudah kedaluwarsa.'));
        return;
      }

      final minPurchase = (data['min_purchase'] as num?)?.toDouble() ?? 0;
      if (current.totalPrice < minPurchase) {
        emit(CartError(
            'Minimal belanja Rp ${minPurchase.round()} untuk voucher ini.'));
        return;
      }

      final usageLimit = (data['usage_limit'] as num?)?.toInt() ?? 0;
      final usedCount = (data['used_count'] as num?)?.toInt() ?? 0;
      if (usageLimit > 0 && usedCount >= usageLimit) {
        emit(CartError('Voucher sudah habis digunakan.'));
        return;
      }

      emit(_copyLoaded(current, voucher: data));
    } catch (e) {
      emit(CartError('Gagal memakai voucher: ${e.toString()}'));
    }
  }

  Future<void> _onClearVoucher(ClearVoucher event, Emitter<CartState> emit) async {
    final current = state;
    if (current is CartLoaded) {
      emit(_copyLoaded(current, voucher: null));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final cartId = await _getCartId();
      if (userId == null || cartId == null) return;

      final existingItem = await _supabase
          .from('cart_items')
          .select('id, quantity')
          .eq('cart_id', cartId)
          .eq('product_id', event.productId)
          .maybeSingle();

      if (existingItem != null) {
        await _supabase
            .from('cart_items')
            .update({
              'quantity': (existingItem['quantity'] as int) + event.quantity,
            })
            .eq('id', existingItem['id']);
      } else {
        await _supabase.from('cart_items').insert({
          'cart_id': cartId,
          'product_id': event.productId,
          'quantity': event.quantity,
        });
      }

      add(LoadCart());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _supabase
          .from('cart_items')
          .update({'quantity': event.newQuantity})
          .eq('id', event.cartItemId);

      add(LoadCart());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', event.cartItemId);

      add(LoadCart());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onTriggerCheckout(
    TriggerCheckout event,
    Emitter<CartState> emit,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      emit(CartError('Silakan login terlebih dahulu.'));
      return;
    }
    if (event.cartItems.isEmpty) {
      emit(CartError('Keranjang Anda kosong.'));
      return;
    }

    final Map<String, dynamic>? appliedVoucher =
        (state is CartLoaded) ? (state as CartLoaded).voucher : null;

    final Map<String, dynamic>? shippingAddressData =
        (state is CartLoaded) ? (state as CartLoaded).selectedAddress : null;
    final Map<String, dynamic>? shippingCourier =
        (state is CartLoaded) ? (state as CartLoaded).selectedCourier : null;
    final int totalWeightGrams =
        (state is CartLoaded) ? (state as CartLoaded).totalWeightGrams : 0;
    final double shippingFee =
        (state is CartLoaded) ? (state as CartLoaded).shippingFee : 0;

    if (shippingAddressData == null) {
      emit(CartError('Silakan pilih alamat pengiriman terlebih dahulu.'));
      return;
    }
    if (shippingCourier == null) {
      emit(CartError('Silakan pilih kurir pengiriman terlebih dahulu.'));
      return;
    }

    emit(CheckoutLoading());

    try {
      final List<Map<String, dynamic>> validatedItems = [];
      double recalculatedTotal = 0;

      // 1. Validasi Stok Produk langsung ke server (1 query paralel)
      final productIds = event.cartItems
          .map((i) => i['product_id'] as String)
          .toSet()
          .toList();
      final products = await _supabase
          .from('products')
          .select('id, name, price, stock')
          .inFilter('id', productIds);
      final productMap = {
        for (final p in (products as List))
          (p as Map<String, dynamic>)['id'] as String: p,
      };

      for (var item in event.cartItems) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        final currentProduct = productMap[productId];
        if (currentProduct == null) throw Exception('Produk tidak tersedia.');
        final int currentStock = (currentProduct['stock'] as num).toInt();
        if (currentStock < quantity) {
          throw Exception(
            'Stok tidak mencukupi untuk ${currentProduct['name'] ?? productId}.',
          );
        }
        final double currentPrice = (currentProduct['price'] as num).toDouble();
        validatedItems.add({
          'product_id': productId,
          'quantity': quantity,
          'price': currentPrice,
        });
        recalculatedTotal += currentPrice * quantity;
      }

      // 1b. Redeem voucher di server (validasi + klaim atomik)
      double discountAmount = 0;
      String? voucherId;
      String? voucherCode;
      if (appliedVoucher != null && appliedVoucher['code'] != null) {
        final redeem = await _supabase.rpc('redeem_voucher', params: {
          'p_code': appliedVoucher['code'],
          'p_order_total': recalculatedTotal,
        });
        final Map<String, dynamic> redeemResult =
            Map<String, dynamic>.from(redeem as Map);
        if (redeemResult['valid'] != true) {
          emit(CartError(redeemResult['error']?.toString() ??
              'Voucher tidak dapat dipakai.'));
          return;
        }
        discountAmount = (redeemResult['discount_amount'] as num).toDouble();
        voucherId = redeemResult['voucher_id']?.toString();
        voucherCode = redeemResult['code']?.toString();
      }

      // Hitung ongkir
      final double discounted = recalculatedTotal - discountAmount;
      final double deliveryFee = shippingFee;
      final double payableTotal = discounted + deliveryFee;
      final int grossAmount = payableTotal.round();

      // 2. Ambil alamat pengiriman terpilih (fallback ke alamat profil)
      String shippingAddress = shippingAddressData['full_address'] as String? ??
          'Alamat tidak diketahui';
      if (shippingAddress.trim().isEmpty) {
        final profileData = await _supabase
            .from('profiles')
            .select('address')
            .eq('id', user.id)
            .maybeSingle();
        if (profileData != null && profileData['address'] != null) {
          shippingAddress = profileData['address'];
        }
      }

      // 3. Insert ke tabel Orders (ACID State)
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': payableTotal,
            'status': OrderStatus.waitingPayment,
            'shipping_address': shippingAddress,
            'shipping_address_id': shippingAddressData['id'],
            'courier_code': shippingCourier['code'],
            'courier_service':
                '${shippingCourier['name']} ${shippingCourier['service'] ?? ''}'
                    .trim(),
            'weight_grams': totalWeightGrams,
            'voucher_id': ?voucherId,
            'voucher_code': ?voucherCode,
            'discount_amount': discountAmount,
            'delivery_fee': deliveryFee,
          })
          .select()
          .single();
      final String orderId = orderResponse['id'];

      // 4. Insert batch ke order_items (1 round-trip)
      await _supabase.from('order_items').insert([
        for (var item in validatedItems)
          {
            'order_id': orderId,
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'price_at_purchase': item['price'],
          },
      ]);

      // 5. Inisialisasi payment record untuk Midtrans
      final String midtransOrderId = 'NEXT-${const Uuid().v4()}';
      await _supabase.from('payments').insert({
        'order_id': orderId,
        'midtrans_id': midtransOrderId,
        'status': 'pending',
        'amount': payableTotal,
      });

      // 6. Invoke Supabase Edge Function untuk mengambil Snap Token
      final String email = user.email ?? '';
      final String customerName = email.contains('@')
          ? email.split('@').first
          : user.id;

      final response = await _supabase.functions.invoke(
        'request-payment',
        body: {
          'order_id': midtransOrderId,
          'gross_amount': grossAmount,
          'customer_name': customerName,
          'customer_email': email.isNotEmpty ? email : null,
        },
      );

      final String? redirectUrl = response.data['redirect_url'];
      final String? snapToken = response.data['token'];

      if (snapToken != null) {
        await _supabase
            .from('payments')
            .update({'snap_token': snapToken})
            .eq('order_id', orderId);
      }

      if (redirectUrl == null) {
        throw Exception('Gagal mendapatkan link pembayaran.');
      }

      emit(CheckoutRedirectReady(redirectUrl));

      // 7. Clear tabel cart_items lokal setelah checkout sukses
      final cart = await _supabase
          .from('carts')
          .select('id')
          .eq('profile_id', user.id)
          .maybeSingle();

      if (cart != null) {
        await _supabase.from('cart_items').delete().eq('cart_id', cart['id']);
      }

      // 8. Tunggu status pesanan terbaru via Realtime (webhook Midtrans memperbarui orders)
      final String status = await _waitForOrderStatus(orderId);

      String userMessage = 'Status pesanan: ${OrderStatus.label(status)}';
      if (status == OrderStatus.processing) {
        userMessage = 'Pembayaran berhasil! Pesanan Anda sedang diproses.';
      } else if (status == OrderStatus.cancelled) {
        userMessage = 'Pembayaran gagal atau dibatalkan.';
      }

      emit(CheckoutStatusVerified(
        orderStatus: status,
        message: userMessage,
        orderId: orderId,
      ));
      add(LoadCart()); // Muat ulang isi keranjang yang sekarang sudah kosong
    } catch (e) {
      emit(CartError('Gagal memproses checkout: ${e.toString()}'));
    }
  }
}
