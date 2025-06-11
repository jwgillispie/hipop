import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/favorites_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _favoritesRepository;

  FavoritesBloc({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository,
       super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<TogglePostFavorite>(_onTogglePostFavorite);
    on<ToggleVendorFavorite>(_onToggleVendorFavorite);
    on<ClearAllFavorites>(_onClearAllFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    
    try {
      final favoritePostIds = await _favoritesRepository.getFavoritePostIds();
      final favoriteVendorIds = await _favoritesRepository.getFavoriteVendorIds();
      
      emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favoritePostIds: favoritePostIds,
        favoriteVendorIds: favoriteVendorIds,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onTogglePostFavorite(
    TogglePostFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final updatedFavoritePostIds = List<String>.from(state.favoritePostIds);
      
      if (updatedFavoritePostIds.contains(event.postId)) {
        await _favoritesRepository.removeFavoritePost(event.postId);
        updatedFavoritePostIds.remove(event.postId);
      } else {
        await _favoritesRepository.addFavoritePost(event.postId);
        updatedFavoritePostIds.add(event.postId);
      }
      
      emit(state.copyWith(favoritePostIds: updatedFavoritePostIds));
    } catch (error) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onToggleVendorFavorite(
    ToggleVendorFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final updatedFavoriteVendorIds = List<String>.from(state.favoriteVendorIds);
      
      if (updatedFavoriteVendorIds.contains(event.vendorId)) {
        await _favoritesRepository.removeFavoriteVendor(event.vendorId);
        updatedFavoriteVendorIds.remove(event.vendorId);
      } else {
        await _favoritesRepository.addFavoriteVendor(event.vendorId);
        updatedFavoriteVendorIds.add(event.vendorId);
      }
      
      emit(state.copyWith(favoriteVendorIds: updatedFavoriteVendorIds));
    } catch (error) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onClearAllFavorites(
    ClearAllFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _favoritesRepository.clearAllFavorites();
      emit(state.copyWith(
        favoritePostIds: [],
        favoriteVendorIds: [],
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}