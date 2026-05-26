import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import '../../../core/network/pocketbase_client.dart';
import 'recipes_screen.dart'; // To access RecipeDetailScreen

class CategoryRecipesScreen extends StatefulWidget {
  final String categoryName;

  const CategoryRecipesScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryRecipesScreen> createState() => _CategoryRecipesScreenState();
}

class _CategoryRecipesScreenState extends State<CategoryRecipesScreen> {
  List<Map<String, dynamic>> _categoryRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final allRecipes = await pbService.fetchRecipes();
      
      // Filter by category
      final filtered = allRecipes.where((recipe) {
        final cat = recipe["category"]?.toString().trim().toLowerCase();
        final target = widget.categoryName.trim().toLowerCase();
        return cat == target;
      }).toList();

      if (mounted) {
        setState(() {
          _categoryRecipes = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AmbientGlow(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.categoryName,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _categoryRecipes.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: AppColors.onSurfaceVariant.withOpacity(0.4),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Aucune recette trouvée dans cette catégorie.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: 'Be Vietnam Pro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: _categoryRecipes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final recipe = _categoryRecipes[index];
                      final prepTime = recipe["prep_time"]?.toString() ?? "30";
                      final difficulty = recipe["difficulty"]?.toString() ?? "Facile";
                      
                      // Map field names to match RecipeDetailScreen format
                      final detailRecipe = {
                        "title": recipe["title"] ?? "",
                        "desc": recipe["description"] ?? "",
                        "time": "${prepTime}min",
                        "tag": difficulty,
                        "imageUrl": recipe["image_url"] ?? "",
                        "ingredients": List<String>.from(recipe["ingredients"] ?? []),
                        "steps": List<String>.from(recipe["steps"] ?? []),
                      };

                      return GlassPanel(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe["image_url"] != null && recipe["image_url"].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                                child: SizedBox(
                                  height: 160,
                                  width: double.infinity,
                                  child: Image.network(
                                    recipe["image_url"],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe["title"] ?? "",
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 18,
                                      fontFamily: 'Epilogue',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    recipe["description"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                      fontSize: 12,
                                      fontFamily: 'Be Vietnam Pro',
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule, color: AppColors.tertiary, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${prepTime} min",
                                            style: const TextStyle(
                                              color: AppColors.tertiary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.trending_up, color: AppColors.secondaryLight, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            difficulty,
                                            style: const TextStyle(
                                              color: AppColors.secondaryLight,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => RecipeDetailScreen(
                                                recipe: detailRecipe,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppColors.primary, AppColors.tertiary],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Text(
                                            "Découvrir",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
