part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class TogglePostFavorite extends FavoritesEvent {
  final String postId;

  const TogglePostFavorite({required this.postId});

  @override
  List<Object> get props => [postId];
}

class ToggleVendorFavorite extends FavoritesEvent {
  final String vendorId;

  const ToggleVendorFavorite({required this.vendorId});

  @override
  List<Object> get props => [vendorId];
}

class ClearAllFavorites extends FavoritesEvent {
  const ClearAllFavorites();
}