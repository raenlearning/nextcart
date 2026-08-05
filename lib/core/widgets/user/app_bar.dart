import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/user/bumping_cart_icon.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAppBar extends StatefulWidget {
  final VoidCallback onLogoutTap;

  const HomeAppBar({super.key, required this.onLogoutTap});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String _address = 'Memuat alamat...';
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await supabase
            .from('profiles')
            .select('address')
            .eq('id', user.id)
            .single();

        setState(() {
          _address = data['address'] ?? 'Belum ada alamat (Pilih di sini)';
        });
      } catch (e) {
        setState(() {
          _address = 'Gagal memuat alamat';
        });
      }
    }
  }

  Future<void> _updateAddress(String newAddress) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        await supabase
            .from('profiles')
            .update({'address': newAddress})
            .eq('id', user.id);

        setState(() {
          _address = newAddress;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan alamat ke database')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final selectedAddress = await context.push<String>(
                '/address-selection',
              );

              if (selectedAddress != null) {
                await _updateAddress(selectedAddress);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kirim ke',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _address,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Row(
          children: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int uniqueProductsCount = 0;
                if (state is CartLoaded) {
                  uniqueProductsCount = state.cartItems.length;
                }

                return BumpingCartIcon(
                  count: uniqueProductsCount,
                  colors: colors,
                  onTap: () {
                    context.push('/cart');
                  },
                );
              },
            ),
        
          ],
        ),
      ],
    );
  }
}
