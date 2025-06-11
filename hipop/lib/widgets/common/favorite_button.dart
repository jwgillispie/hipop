import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';

class FavoriteButton extends StatelessWidget {
  final String postId;
  final String? vendorId;
  final double size;
  final Color? favoriteColor;
  final Color? unfavoriteColor;
  final bool showBackground;

  const FavoriteButton({
    super.key,
    required this.postId,
    this.vendorId,
    this.size = 24,
    this.favoriteColor,
    this.unfavoriteColor,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isPostFavorite = state.isPostFavorite(postId);
        final isVendorFavorite = vendorId != null ? state.isVendorFavorite(vendorId!) : false;
        
        return GestureDetector(
          onTap: () {
            context.read<FavoritesBloc>().add(TogglePostFavorite(postId: postId));
            if (vendorId != null) {
              context.read<FavoritesBloc>().add(ToggleVendorFavorite(vendorId: vendorId!));
            }
          },
          child: Container(
            padding: showBackground ? const EdgeInsets.all(8) : EdgeInsets.zero,
            decoration: showBackground
                ? BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : null,
            child: Icon(
              isPostFavorite ? Icons.favorite : Icons.favorite_border,
              size: size,
              color: isPostFavorite
                  ? (favoriteColor ?? Colors.red)
                  : (unfavoriteColor ?? Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedFavoriteButton extends StatefulWidget {
  final String postId;
  final String? vendorId;
  final double size;
  final Color? favoriteColor;
  final Color? unfavoriteColor;

  const AnimatedFavoriteButton({
    super.key,
    required this.postId,
    this.vendorId,
    this.size = 24,
    this.favoriteColor,
    this.unfavoriteColor,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    context.read<FavoritesBloc>().add(TogglePostFavorite(postId: widget.postId));
    if (widget.vendorId != null) {
      context.read<FavoritesBloc>().add(ToggleVendorFavorite(vendorId: widget.vendorId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isPostFavorite = state.isPostFavorite(widget.postId);
        
        return GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  isPostFavorite ? Icons.favorite : Icons.favorite_border,
                  size: widget.size,
                  color: isPostFavorite
                      ? (widget.favoriteColor ?? Colors.red)
                      : (widget.unfavoriteColor ?? Colors.grey[600]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}