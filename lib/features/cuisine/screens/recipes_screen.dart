import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import '../../../core/network/pocketbase_client.dart';
import 'category_recipes_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final recipes = await pbService.fetchRecipes();
      if (mounted) {
        setState(() {
          _allRecipes = recipes;
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

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final results = _allRecipes.where((recipe) {
      final title = (recipe["title"] ?? "").toString().toLowerCase();
      final desc = (recipe["description"] ?? "").toString().toLowerCase();
      
      bool matchesIngredient = false;
      final ingredients = recipe["ingredients"];
      if (ingredients is List) {
        matchesIngredient = ingredients.any((ing) => ing.toString().toLowerCase().contains(query));
      }

      // Match title, description, or ingredients
      return title.contains(query) || desc.contains(query) || matchesIngredient;
    }).toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  final List<Map<String, String>> _categories = [
    {"name": "Entrées", "icon": "tapas"},
    {"name": "Plats", "icon": "restaurant"},
    {"name": "Desserts", "icon": "cake"},
    {"name": "Boissons", "icon": "local_bar"},
    {"name": "Épices", "icon": "spa"},
  ];

  final List<Map<String, String>> _chefs = [
    {
      "name": "Mama Rose",
      "title": "Reine des Accras",
      "desc":
          "Découvrez les secrets transmis de génération en génération pour des fritures parfaites.",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCiVJe5-o91QB4nzDeLR1FfruOGMueJZgjZysYjxNtdxbYaXj2E2fGk9rvgkK_dqFHq7uoyHM_pqlRlHFefttKTueLQRgF2G921jRvDss2q9GA1t5SsFuO0Bm-630lPv7MQTdtbbxYbng0WJOn5ZanjL37jlbxRrh4cebEfSREXgzI-EfqUEyDEmWspIubIYhZSlb8cmaAZCA9y69QlEN0ERhv42J-66i1XUrf8nGvIGDTf4tCTrpX1qOhSwzvGtKUzmDSsopW2Lw",
    },
    {
      "name": "Chef Léo",
      "title": "Gastronomie Moderne",
      "desc":
          "Une réinterprétation audacieuse des classiques de la cuisine antillaise.",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuD-F4SuSDe0xfpuUH2Hbzaflv2vemh4DgbRYKwlncCuRXziJ88l0zoOwetMvvIEysW0BZ3DdMQghFQHT73VzFvSIOS5JKO9flSZlktuiMLDXDiyb7A2qkk-qLNxBiE5VdCzmjw_O3UuF9gFamPx3tJ44HSdxWjihLGEiWEg0oE3XcdoIH0yeP6fnmf7hQiKeLChtQIKBPerVadgJue4zReLVykD5NJBUd4NzhwbMAe1AEAci0CXU-hW7tt3zY5brfe4latiFBgGqw",
    },
  ];

  final Map<String, dynamic> _featuredRecipe = {
    "title": "Colombo de Cabri",
    "desc":
        "L'incontournable plat de fête, mijoté aux épices douces et relevé d'une pointe de piment bondamanjak.",
    "time": "2h 30min",
    "tag": "Populaire",
    "imageUrl":
        "https://lh3.googleusercontent.com/aida-public/AB6AXuDcS5KSleAUd1_DvyMTBw5mhwYCxchjyYXqu3_o6gk-2mEFlliP3u1uqg3GQsDQ-HTl2b04iULqekVENCFRePakUMckRXt8ebDCcV0ikl_oFRtBVEAC8lKMF7ptiEHoKikVdgdnMaQiMV8X-r7YMykmlokWM3tYlBJ4qNAwfnl_bVr-kxagPv4YULRTGd6E_oV0cKvVRCR5tiNhsi7_qo7uDBJnvQbCVpoW4Y8ornN3SpY-EAulCJ5MLroBfcrTUCZFipebBT2RVQ",
    "ingredients": [
      "1kg de viande de cabri",
      "3 cuillères à soupe de poudre de colombo",
      "2 pommes de terre",
      "1 aubergine",
      "3 gousses d'ail",
      "Cives",
      "Citron vert",
      "Piment bondamanjak",
    ],
    "steps": [
      "Faire mariner la viande découpée avec le citron vert, l'ail écrasé et une cuillère de colombo pendant une nuit.",
      "Saisir les morceaux de viande dans un filet d'huile chaude.",
      "Ajouter les cives hachées et faire revenir doucement.",
      "Mouiller avec un peu d'eau, rajouter le reste de poudre de colombo, puis les morceaux de pommes de terre et d'aubergine.",
      "Laisser mijoter doucement à couvert pendant 2 heures.",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return AmbientGlow(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Cuisine Créole (Manjé)",
            style: TextStyle(
              color: AppColors.onSurface,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar Widget
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: GlassPanel.floating(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  borderRadius: 30,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher une recette, un ingrédient...",
                      hintStyle: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        fontFamily: 'Be Vietnam Pro',
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isSearching
                  ? _buildSearchResults()
                  : _buildNormalContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  color: AppColors.onSurfaceVariant.withOpacity(0.4),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Aucune recette ne correspond à votre recherche.",
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
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final recipe = _searchResults[index];
        final prepTime = recipe["prep_time"]?.toString() ?? "30";
        final difficulty = recipe["difficulty"]?.toString() ?? "Facile";

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
    );
  }

  Widget _buildNormalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. Featured Saveurs de Saison Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Saveurs de Saison",
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 20,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: 24,
            child: Stack(
              children: [
                // Background Image
                SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      _featuredRecipe["imageUrl"] ?? "",
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                ),
                // Dark bottom overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
                // Featured details
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  color: AppColors.tertiary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _featuredRecipe["time"],
                                  style: const TextStyle(
                                    color: AppColors.tertiary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: AppColors.secondaryLight,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _featuredRecipe["tag"],
                                  style: const TextStyle(
                                    color: AppColors.secondaryLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _featuredRecipe["title"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _featuredRecipe["desc"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withOpacity(
                            0.8,
                          ),
                          fontSize: 13,
                          fontFamily: 'Be Vietnam Pro',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(
                                recipe: _featuredRecipe,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.tertiary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Text(
                            "Voir la recette",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),

        // 3. Bento Categories Grid Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Parcourez la Carte",
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 20,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesScreen(
                        categoryName: cat["name"] ?? "",
                      ),
                    ),
                  );
                },
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(
                            0.2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _getIconData(cat["icon"]),
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat["name"] ?? "",
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),

        // 4. Chefs & Savoir-faire Horizontal Carousel Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Chefs & Savoir-faire",
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 20,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _chefs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final chef = _chefs[index];
              return GlassPanel(
                padding: const EdgeInsets.all(16),
                borderRadius: 20,
                width: 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.tertiary,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(chef["imageUrl"] ?? ""),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chef["name"] ?? "",
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                chef["title"] ?? "",
                                style: const TextStyle(
                                  color: AppColors.secondaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      chef["desc"] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant.withOpacity(
                          0.8,
                        ),
                        fontSize: 12,
                        fontFamily: 'Be Vietnam Pro',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String? icon) {
    switch (icon) {
      case 'tapas':
        return Icons.restaurant_menu;
      case 'cake':
        return Icons.cake_outlined;
      case 'local_bar':
        return Icons.local_bar_outlined;
      case 'spa':
        return Icons.eco_outlined;
      case 'restaurant':
      default:
        return Icons.restaurant;
    }
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final ingredients = List<String>.from(recipe["ingredients"] ?? []);
    final steps = List<String>.from(recipe["steps"] ?? []);

    return AmbientGlow(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            recipe["title"] ?? "",
            style: const TextStyle(
              color: AppColors.onSurface,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    recipe["imageUrl"] ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.surfaceContainer),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                recipe["desc"] ?? "",
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 15,
                  fontFamily: 'Be Vietnam Pro',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Ingredients
              const Text(
                "Ingrédients",
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GlassPanel(
                child: Column(
                  children: ingredients.map((ing) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.secondaryLight,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ing,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 14,
                                fontFamily: 'Be Vietnam Pro',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Steps
              const Text(
                "Préparation",
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(steps.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryContainer,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            steps[index],
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 14,
                              fontFamily: 'Be Vietnam Pro',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
