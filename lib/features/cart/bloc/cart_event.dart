abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final String productId;
  final int quantity;
  AddToCart(this.productId, {this.quantity = 1});
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

class ClearVoucherError extends CartEvent {}

class SelectShippingAddress extends CartEvent {
  final Map<String, dynamic> address;
  SelectShippingAddress(this.address);
}

class SelectCourier extends CartEvent {
  final Map<String, dynamic> courier;
  SelectCourier(this.courier);
}
