import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/data/repository/shipping_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// --- EVENTS ---
abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final String productId;
  AddToCart(this.productId);
}

class UpdateCartQuantity extends CartEvent {
  final String cartItemId;
  final int newQuantity;
  UpdateCartQuantity(this.cartItemId, this.newQuantity);
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;
  RemoveFromCart(this.cartItemId);
}

class TriggerCheckout extends CartEvent {
  final List<Map<String, dynamic>> cartItems;
  TriggerCheckout({required this.cartItems});
}

class ApplyVoucher extends CartEvent {
  final String code;
  ApplyVoucher(this.code);
}

class ClearVoucher extends CartEvent {}

class SelectShippingAddress extends CartEvent {
  final Map<String, dynamic> address;
  SelectShippingAddress(this.address);
}

class SelectCourier extends CartEvent {
  final Map<String, dynamic> courier;
  SelectCourier(this.courier);
}

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final Map<String, dynamic>? voucher;
  final int totalWeightGrams;
  final Map<String, dynamic>? selectedAddress;
  final Map<String, dynamic>? selectedCourier;
  final List<Map<String, dynamic>> shippingRates;
  final double shippingFee;

  CartLoaded(
    this.cartItems,
    this.totalPrice, {
    this.voucher,
    this.totalWeightGrams = 0,
    this.selectedAddress,
    this.selectedCourier,
    this.shippingRates = const [],
    this.shippingFee = 0,
  });
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

class CheckoutLoading extends CartState {}

class CheckoutRedirectReady extends CartState {
  final String redirectUrl;
  CheckoutRedirectReady(this.redirectUrl);
}

class CheckoutStatusVerified extends CartState {
  final String orderStatus;
  final String message;
  CheckoutStatusVerified({required this.orderStatus, required this.message});
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ShippingRepository _shippingRepository = ShippingRepository();

  CartBloc() : super(CartInitial()) {
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

  Future<String?> _getCartId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final cart = await _supabase
        .from('carts')
        .select('id')
        .eq('profile_id', userId)
        .maybeSingle();

    if (cart != null) {
      return cart['id'];
    }

    final newCart = await _supabase
        .from('carts')
        .insert({'profile_id': userId})
        .select('id')
        .maybeSingle();

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

      final keepAddress =
          prev is CartLoaded ? prev.selectedAddress : null;
      emit(CartLoaded(cartItems, total,
          totalWeightGrams: totalWeight, selectedAddress: keepAddress));

      if (keepAddress != null) await _loadRates(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  double get _vatRate => 0.11;

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
    return discounted + shippingFee + discounted * _vatRate;
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
            .update({'quantity': existingItem['quantity'] + 1})
            .eq('id', existingItem['id']);
      } else {
        await _supabase.from('cart_items').insert({
          'cart_id': cartId,
          'product_id': event.productId,
          'quantity': 1,
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

      // 1. Validasi Stok Produk langsung ke server
      for (var item in event.cartItems) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        final currentProduct = await _supabase
            .from('products')
            .select('name, price, stock')
            .eq('id', productId)
            .maybeSingle();
        if (currentProduct == null) throw Exception('Produk tidak tersedia.');
        final int currentStock = currentProduct['stock'] as int;
        if (currentStock < quantity) throw Exception('Stok tidak mencukupi.');
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

      // Hitung ongkir & pajak (PPN atas nilai setelah diskon)
      final double discounted = recalculatedTotal - discountAmount;
      final double deliveryFee = shippingFee;
      final double tax = discounted * _vatRate;
      final double payableTotal = discounted + deliveryFee + tax;
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
            'tax_amount': tax,
          })
          .select()
          .single();
      final String orderId = orderResponse['id'];

      // 4. Insert batch ke order_items
      for (var item in validatedItems) {
        await _supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price_at_purchase': item['price'],
        });
      }

      // 5. Inisialisasi payment record untuk Midtrans
      final String midtransOrderId = 'NEXT-${const Uuid().v4()}';
      final paymentInsert = await _supabase.from('payments').insert({
        'order_id': orderId,
        'midtrans_id': midtransOrderId,
        'status': 'pending',
        'amount': payableTotal,
      });
      if (paymentInsert.error != null) {
        throw Exception(
            'Gagal menyimpan data pembayaran: ${paymentInsert.error.message}');
      }

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
        final snapTokenUpdate = await _supabase
            .from('payments')
            .update({'snap_token': snapToken})
            .eq('order_id', orderId);
        if (snapTokenUpdate.error != null) {
          throw Exception(
              'Gagal menyimpan token pembayaran: ${snapTokenUpdate.error.message}');
        }
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

      // 8. Polling status pesanan terbaru dari Webhook Midtrans yang masuk ke Supabase
      String status = OrderStatus.waitingPayment;
      for (int attempt = 0; attempt < 10; attempt++) {
        final latestOrder = await _supabase
            .from('orders')
            .select('status')
            .eq('id', orderId)
            .single();
        status = latestOrder['status'] as String;
        if (status != OrderStatus.waitingPayment) break;
        await Future.delayed(const Duration(seconds: 3));
      }

      String userMessage = 'Status pesanan: ${OrderStatus.label(status)}';
      if (status == OrderStatus.processing) {
        userMessage = 'Pembayaran berhasil! Pesanan Anda sedang diproses.';
      } else if (status == OrderStatus.cancelled) {
        userMessage = 'Pembayaran gagal atau dibatalkan.';
      }

      emit(CheckoutStatusVerified(orderStatus: status, message: userMessage));
      add(LoadCart()); // Muat ulang isi keranjang yang sekarang sudah kosong
    } catch (e) {
      emit(CartError('Gagal memproses checkout: ${e.toString()}'));
    }
  }
}
