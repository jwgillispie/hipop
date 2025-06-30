import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/favorites_service.dart';
import '../../models/user_favorite.dart';
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
    on<ToggleMarketFavorite>(_onToggleMarketFavorite);
    on<ClearAllFavorites>(_onClearAllFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    
    try {
      List<String> favoritePostIds = [];
      List<String> favoriteVendorIds = [];
      List<String> favoriteMarketIds = [];
      
      if (event.userId != null) {
        // Use Firestore service for authenticated users
        final vendorFavorites = await FavoritesService.getUserFavoriteVendors(event.userId!);
        final marketFavorites = await FavoritesService.getUserFavoriteMarkets(event.userId!);
        
        favoriteVendorIds = vendorFavorites.map((v) => v.id).toList();
        favoriteMarketIds = marketFavorites.map((m) => m.id).toList();
        
        // Note: Posts are not supported in Firestore service yet, keep local for now
        favoritePostIds = await _favoritesRepository.getFavoritePostIds();
      } else {
        // Use local repository for anonymous users
        favoritePostIds = await _favoritesRepository.getFavoritePostIds();
        favoriteVendorIds = await _favoritesRepository.getFavoriteVendorIds();
        favoriteMarketIds = await _favoritesRepository.getFavoriteMarketIds();
      }
      
      emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favoritePostIds: favoritePostIds,
        favoriteVendorIds: favoriteVendorIds,
        favoriteMarketIds: favoriteMarketIds,
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
      
      if (event.userId != null) {
        // Use Firestore service for authenticated users
        final newIsFavorited = await FavoritesService.toggleFavorite(
          userId: event.userId!,
          itemId: event.vendorId,
          type: FavoriteType.vendor,
        );
        
        if (newIsFavorited) {
          if (!updatedFavoriteVendorIds.contains(event.vendorId)) {
            updatedFavoriteVendorIds.add(event.vendorId);
          }
        } else {
          updatedFavoriteVendorIds.remove(event.vendorId);
        }
      } else {
        // Use local repository for anonymous users
        if (updatedFavoriteVendorIds.contains(event.vendorId)) {
          await _favoritesRepository.removeFavoriteVendor(event.vendorId);
          updatedFavoriteVendorIds.remove(event.vendorId);
        } else {
          await _favoritesRepository.addFavoriteVendor(event.vendorId);
          updatedFavoriteVendorIds.add(event.vendorId);
        }
      }
      
      emit(state.copyWith(favoriteVendorIds: updatedFavoriteVendorIds));
    } catch (error) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onToggleMarketFavorite(
    ToggleMarketFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final updatedFavoriteMarketIds = List<String>.from(state.favoriteMarketIds);
      
      if (event.userId != null) {
        // Use Firestore service for authenticated users
        final newIsFavorited = await FavoritesService.toggleFavorite(
          userId: event.userId!,
          itemId: event.marketId,
          type: FavoriteType.market,
        );
        
        if (newIsFavorited) {
          if (!updatedFavoriteMarketIds.contains(event.marketId)) {
            updatedFavoriteMarketIds.add(event.marketId);
          }
        } else {
          updatedFavoriteMarketIds.remove(event.marketId);
        }
      } else {
        // Use local repository for anonymous users
        if (updatedFavoriteMarketIds.contains(event.marketId)) {
          await _favoritesRepository.removeFavoriteMarket(event.marketId);
          updatedFavoriteMarketIds.remove(event.marketId);
        } else {
          await _favoritesRepository.addFavoriteMarket(event.marketId);
          updatedFavoriteMarketIds.add(event.marketId);
        }
      }
      
      emit(state.copyWith(favoriteMarketIds: updatedFavoriteMarketIds));
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
      if (event.userId != null) {
        // Use Firestore service for authenticated users
        await FavoritesService.clearAllFavorites(event.userId!);
      } else {
        // Use local repository for anonymous users
        await _favoritesRepository.clearAllFavorites();
      }
      
      emit(state.copyWith(
        favoritePostIds: [],
        favoriteVendorIds: [],
        favoriteMarketIds: [],
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}