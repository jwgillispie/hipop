import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String marketId; // Market this recipe belongs to
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final List<String> tags; // e.g., ['vegetarian', 'gluten-free', 'seasonal']
  final List<String> vendorIds; // Vendors whose products are featured
  final List<String> productCategories; // What types of market products are used
  final String? imageUrl;
  final String createdBy; // Market organizer who created this
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final bool isFeatured;
  final int viewCount;
  final int favoriteCount;
  final Map<String, dynamic> metadata; // Flexible field for additional data

  const Recipe({
    required this.id,
    required this.marketId,
    required this.title,
    required this.description,
    this.ingredients = const [],
    this.instructions = const [],
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 1,
    this.tags = const [],
    this.vendorIds = const [],
    this.productCategories = const [],
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
    this.isFeatured = false,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.metadata = const {},
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Recipe(
      id: doc.id,
      marketId: data['marketId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      prepTimeMinutes: data['prepTimeMinutes'] ?? 0,
      cookTimeMinutes: data['cookTimeMinutes'] ?? 0,
      servings: data['servings'] ?? 1,
      tags: List<String>.from(data['tags'] ?? []),
      vendorIds: List<String>.from(data['vendorIds'] ?? []),
      productCategories: List<String>.from(data['productCategories'] ?? []),
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'marketId': marketId,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'tags': tags,
      'vendorIds': vendorIds,
      'productCategories': productCategories,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'metadata': metadata,
    };
  }

  Recipe copyWith({
    String? id,
    String? marketId,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    List<String>? tags,
    List<String>? vendorIds,
    List<String>? productCategories,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    bool? isFeatured,
    int? viewCount,
    int? favoriteCount,
    Map<String, dynamic>? metadata,
  }) {
    return Recipe(
      id: id ?? this.id,
      marketId: marketId ?? this.marketId,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      tags: tags ?? this.tags,
      vendorIds: vendorIds ?? this.vendorIds,
      productCategories: productCategories ?? this.productCategories,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;
  
  String get formattedPrepTime {
    if (prepTimeMinutes == 0) return '';
    if (prepTimeMinutes < 60) return '${prepTimeMinutes}m';
    final hours = prepTimeMinutes ~/ 60;
    final minutes = prepTimeMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
  
  String get formattedCookTime {
    if (cookTimeMinutes == 0) return '';
    if (cookTimeMinutes < 60) return '${cookTimeMinutes}m';
    final hours = cookTimeMinutes ~/ 60;
    final minutes = cookTimeMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
  
  String get formattedTotalTime {
    if (totalTimeMinutes == 0) return '';
    if (totalTimeMinutes < 60) return '${totalTimeMinutes}m';
    final hours = totalTimeMinutes ~/ 60;
    final minutes = totalTimeMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }

  bool get isDraft => !isPublished;
  bool get isComplete => title.isNotEmpty && description.isNotEmpty && 
                        ingredients.isNotEmpty && instructions.isNotEmpty;

  // Publish the recipe
  Recipe publish() {
    return copyWith(
      isPublished: true,
      updatedAt: DateTime.now(),
    );
  }

  // Unpublish the recipe
  Recipe unpublish() {
    return copyWith(
      isPublished: false,
      updatedAt: DateTime.now(),
    );
  }

  // Feature the recipe
  Recipe feature() {
    return copyWith(
      isFeatured: true,
      updatedAt: DateTime.now(),
    );
  }

  // Unfeature the recipe
  Recipe unfeature() {
    return copyWith(
      isFeatured: false,
      updatedAt: DateTime.now(),
    );
  }

  // Increment view count
  Recipe incrementViews() {
    return copyWith(
      viewCount: viewCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  // Update favorite count
  Recipe updateFavoriteCount(int newCount) {
    return copyWith(
      favoriteCount: newCount,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        marketId,
        title,
        description,
        ingredients,
        instructions,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        tags,
        vendorIds,
        productCategories,
        imageUrl,
        createdBy,
        createdAt,
        updatedAt,
        isPublished,
        isFeatured,
        viewCount,
        favoriteCount,
        metadata,
      ];

  @override
  String toString() {
    return 'Recipe(id: $id, marketId: $marketId, title: $title, isPublished: $isPublished, isFeatured: $isFeatured)';
  }
}