part of 'favorites_bloc.dart';

enum FavoritesStatus { loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<String> favoritePostIds;
  final List<String> favoriteVendorIds;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.loaded,
    this.favoritePostIds = const [],
    this.favoriteVendorIds = const [],
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<String>? favoritePostIds,
    List<String>? favoriteVendorIds,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoritePostIds: favoritePostIds ?? this.favoritePostIds,
      favoriteVendorIds: favoriteVendorIds ?? this.favoriteVendorIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isPostFavorite(String postId) {
    return favoritePostIds.contains(postId);
  }

  bool isVendorFavorite(String vendorId) {
    return favoriteVendorIds.contains(vendorId);
  }

  int get totalFavorites => favoritePostIds.length + favoriteVendorIds.length;

  @override
  List<Object?> get props => [
        status,
        favoritePostIds,
        favoriteVendorIds,
        errorMessage,
      ];
}