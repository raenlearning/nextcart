import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/cart/bloc/cart_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentStatusPage extends StatefulWidget {
  final CheckoutStatusVerified status;

  const PaymentStatusPage({super.key, required this.status});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 4));

  bool get _isSuccess =>
      widget.status.orderStatus == OrderStatus.processing ||
      widget.status.orderStatus == OrderStatus.delivered ||
      widget.status.orderStatus == OrderStatus.completed;

  bool get _isCancelled => widget.status.orderStatus == OrderStatus.cancelled;

  @override
  void initState() {
    super.initState();
    if (_isSuccess) _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _goToOrderDetail() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      final data = await Supabase.instance.client
          .from('orders')
          .select('''
            id,
            total_amount,
            status,
            shipping_address,
            created_at,
            order_items (
              id,
              quantity,
              price_at_purchase,
              products (
                id,
                name,
                images
              )
            ),
            payments!payments_order_id_fkey (
              snap_token,
              status,
              method,
              paid_at
            )
          ''')
          .eq('id', widget.status.orderId)
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        context.pushReplacement(
          '/order-detail',
          extra: Map<String, dynamic>.from(data),
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (_isSuccess)
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 25,
                maxBlastForce: 22,
                minBlastForce: 8,
                gravity: 0.28,
                emissionFrequency: 0.05,
                colors: const [
                  Color(0xFF2563EB),
                  Color(0xFF10B981),
                  Color(0xFFEAB308),
                  Color(0xFFDC2626),
                  Color(0xFF7C3AED),
                ],
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'payment-status-artwork',
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: _isSuccess
                            ? lottie.Lottie.asset(
                                AppAssets.paymentSuccess,
                                repeat: false,
                              )
                            : Icon(
                                _isCancelled
                                    ? Icons.cancel_rounded
                                    : Icons.hourglass_top_rounded,
                                size: 110,
                                color: _isCancelled
                                    ? AppColors.error
                                    : AppColors.warning,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.status.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_isSuccess) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _goToOrderDetail,
                          icon: const Icon(Icons.local_shipping_rounded),
                          label: const Text(
                            'Lacak Pesanan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    if (_isSuccess) return 'Pembayaran Berhasil!';
    if (_isCancelled) return 'Pembayaran Gagal';
    return 'Menunggu Pembayaran';
  }
}
