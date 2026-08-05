import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repository/admin_repository.dart';
import 'admin_product_event.dart';
import 'admin_product_state.dart';

class AdminProductBloc extends Bloc<AdminProductEvent, AdminProductState> {
  final AdminRepository _adminRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminProductBloc({required this._adminRepository})
      : super(AdminProductInitial()) {

    on<FetchAdminProducts>((event, emit) async {
      emit(AdminProductLoading());
      try {
        final currentUserId = _supabase.auth.currentUser?.id ?? '';
        final products = await _adminRepository.getAdminProducts(currentUserId);
        emit(AdminProductLoaded(products));
      } catch (e) {
        emit(AdminProductError(e.toString()));
      }
    });

    on<AddAdminProduct>((event, emit) async {
      emit(AdminProductLoading());
      try {
        if (event.name.trim().isEmpty) {
          emit(AdminProductError('Nama produk tidak boleh kosong'));
          return;
        }
        if (event.price <= 0) {
          emit(AdminProductError('Harga harus lebih dari 0'));
          return;
        }
        if (event.stock < 0) {
          emit(AdminProductError('Stok tidak boleh negatif'));
          return;
        }
        if (event.categoryId.isEmpty) {
          emit(AdminProductError('Kategori harus dipilih'));
          return;
        }
        if (event.images.isEmpty) {
          emit(AdminProductError('Minimal 1 foto produk wajib diisi'));
          return;
        }

        final currentUserId = _supabase.auth.currentUser?.id ?? '';
        final newProduct = Product(
          id: '',
          name: event.name,
          description: event.description,
          price: event.price,
          stock: event.stock,
          categoryId: event.categoryId,
          images: event.images,
          sellerId: currentUserId,
          isActive: event.isActive,
        );
        await _adminRepository.createProduct(newProduct);
        emit(AdminProductActionSuccess('Produk berhasil diupload!'));
      } catch (e) {
        emit(AdminProductError(e.toString()));
      }
    });

    on<EditAdminProduct>((event, emit) async {
      emit(AdminProductLoading());
      try {
        await _adminRepository.updateProduct(event.product);
        emit(AdminProductActionSuccess('Perubahan produk berhasil disimpan!'));
      } catch (e) {
        emit(AdminProductError(e.toString()));
      }
    });

    on<DeleteAdminProduct>((event, emit) async {
      emit(AdminProductLoading());
      try {
        await _adminRepository.deleteProduct(event.id);
        emit(AdminProductActionSuccess('Produk berhasil dihapus!'));
      } catch (e) {
        emit(AdminProductError(e.toString()));
      }
    });

    on<ResetAdminProductState>((event, emit) async {
      if (state is AdminProductActionSuccess) {
        emit(AdminProductInitial());
      }
    });
  }
}