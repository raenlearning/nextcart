abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final Map<String, dynamic>? voucher;
  final String? voucherError;
  final int totalWeightGrams;
  final Map<String, dynamic>? selectedAddress;
  final Map<String, dynamic>? selectedCourier;
  final List<Map<String, dynamic>> shippingRates;
  final double shippingFee;

  CartLoaded(
    this.cartItems,
    this.totalPrice, {
    this.voucher,
    this.voucherError,
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
  final String orderId;
  CheckoutStatusVerified({
    required this.orderStatus,
    required this.message,
    required this.orderId,
  });
}
