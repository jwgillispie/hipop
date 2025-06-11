import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const String _favoriteVendorsKey = 'favorite_vendors';
  static const String _favoritePostsKey = 'favorite_posts';

  // Favorite vendor posts
  Future<List<String>> getFavoritePostIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritePostsKey) ?? [];
    return favoritesJson;
  }

  Future<void> addFavoritePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoritePostIds();
    if (!favorites.contains(postId)) {
      favorites.add(postId);
      await prefs.setStringList(_favoritePostsKey, favorites);
    }
  }

  Future<void> removeFavoritePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoritePostIds();
    favorites.remove(postId);
    await prefs.setStringList(_favoritePostsKey, favorites);
  }

  Future<bool> isPostFavorite(String postId) async {
    final favorites = await getFavoritePostIds();
    return favorites.contains(postId);
  }

  // Favorite vendors
  Future<List<String>> getFavoriteVendorIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteVendorsKey) ?? [];
    return favoritesJson;
  }

  Future<void> addFavoriteVendor(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteVendorIds();
    if (!favorites.contains(vendorId)) {
      favorites.add(vendorId);
      await prefs.setStringList(_favoriteVendorsKey, favorites);
    }
  }

  Future<void> removeFavoriteVendor(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteVendorIds();
    favorites.remove(vendorId);
    await prefs.setStringList(_favoriteVendorsKey, favorites);
  }

  Future<bool> isVendorFavorite(String vendorId) async {
    final favorites = await getFavoriteVendorIds();
    return favorites.contains(vendorId);
  }

  // Clear all favorites (useful for logout)
  Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritePostsKey);
    await prefs.remove(_favoriteVendorsKey);
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    final posts = await getFavoritePostIds();
    final vendors = await getFavoriteVendorIds();
    return posts.length + vendors.length;
  }
}