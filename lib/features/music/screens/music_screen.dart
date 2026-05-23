import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/network/pocketbase_client.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  Map<String, dynamic>? _nowPlaying;
  bool _isPlaying = false;
  late final AnimationController _visualizerController;

  String _selectedGenre = "Tous";
  final List<String> _genres = [
    "Tous",
    "Bèlè",
    "Zouk",
    "Shatta",
    "Gwo Ka",
    "Bouyon",
  ];

  final List<Map<String, String>> _featuredHeritage = [
    {
      "title": "Bèlè: Heart of Martinique",
      "desc":
          "Découvrez le dialogue rythmique profond entre le danseur et le tambour, symbole de résilience et de liberté.",
      "tag": "Tradition",
      "imageUrl":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDne7s-KB8vwrk95giZfgIN0YcqNzJbR6ESraBuKM0gt2fpiOevm4pDMmMEDiCfCA9vU39CvRingAnzXpFqIjcs4pSjiUgeasv3XPA7LNkX4jHU0NEeBIgpuhzJ2ub8nR7OPbqhB_Auxz4rltaEMEQYbU6J_2n46AC9Y66-7I8f_-YAJrj2WApqRONg8xxmeOjo1czugwt-Z8nKtbi6X_iOBzRf2gnWWJbn_d52lxtTjwu4g8IemG0coXxfFEMNrtoinCOyHw7TCw",
    },
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _player.dispose();
    _visualizerController.dispose();
    super.dispose();
  }

  Future<void> _playTrack(Map<String, dynamic> track) async {
    setState(() {
      _nowPlaying = track;
      _isPlaying = true;
    });

    final audioUrl = track["audio_url"];
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        await _player.setUrl(audioUrl);
        _player.play();
        _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      } catch (e) {
        debugPrint("Play error: $e");
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      _player.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 180,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Musique & Danses",
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 24,
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Search input
            GlassPanel.floating(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              borderRadius: 30,
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher des genres, artistes...",
                  hintStyle: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontFamily: 'Be Vietnam Pro',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(color: AppColors.onSurface, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Genre selector pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_genres.length, (index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer.withOpacity(0.2)
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.onSurface
                                : AppColors.onSurface.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),

            // 3. Featured Heritage Snapping Carousel
            const Text(
              "Héritage Vedette",
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                itemCount: _featuredHeritage.length,
                itemBuilder: (context, index) {
                  final feat = _featuredHeritage[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              feat["imageUrl"] ?? "",
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.55),
                            ),
                          ),
                          // Dark gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
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
                          // Details
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.tertiary.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    feat["tag"]?.toUpperCase() ?? "TRADITION",
                                    style: const TextStyle(
                                      color: AppColors.tertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feat["title"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: 'Epilogue',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  feat["desc"] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant
                                        .withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.tertiary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Démarrer l'initiation",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.play_circle,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

            // Active Track Player Card
            if (_nowPlaying != null) ...[
              GlassPanel(
                borderColor: AppColors.secondary,
                borderOpacity: 0.15,
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.network(
                              _nowPlaying!["cover_url"] ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.surfaceContainer),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nowPlaying!["title"] ?? "",
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                  fontFamily: 'Epilogue',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${_nowPlaying!["artist"]} • ${_nowPlaying!["rhythm"]}",
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: 12,
                                  fontFamily: 'Be Vietnam Pro',
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _togglePlayback,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Music Visualizer Bar Simulation
                    if (_isPlaying)
                      AnimatedBuilder(
                        animation: _visualizerController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(24, (index) {
                              final height = (index % 4 == 0)
                                  ? 8 + 24 * _visualizerController.value
                                  : (index % 3 == 0)
                                  ? 4 + 16 * (1 - _visualizerController.value)
                                  : (index % 2 == 0)
                                  ? 12 + 18 * _visualizerController.value
                                  : 6 + 10 * (1 - _visualizerController.value);
                              return Container(
                                width: 4,
                                height: height,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryLight.withOpacity(
                                    0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // 4. Tracks list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pistes Populaires",
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontFamily: 'Epilogue',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "VOIR TOUT",
                  style: TextStyle(
                    color: AppColors.primaryLight.withOpacity(0.8),
                    fontSize: 11,
                    fontFamily: 'Be Vietnam Pro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: pbService.fetchMusic(),
              builder: (context, snapshot) {
                final tracks = snapshot.data ?? [];
                // Filtering based on genre
                final filtered = _selectedGenre == "Tous"
                    ? tracks
                    : tracks
                          .where((t) => t["rhythm"] == _selectedGenre)
                          .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        "Aucune piste dans cette catégorie.",
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = filtered[index];
                    final isCurrent =
                        _nowPlaying != null && _nowPlaying!["id"] == t["id"];

                    return GestureDetector(
                      onTap: () => _playTrack(t),
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        borderRadius: 16,
                        borderColor: isCurrent
                            ? AppColors.secondary
                            : Colors.white,
                        borderOpacity: isCurrent ? 0.3 : 0.05,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Image.network(
                                  t["cover_url"] ?? "",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppColors.surfaceContainer,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t["title"] ?? "",
                                    style: TextStyle(
                                      color: isCurrent
                                          ? AppColors.secondaryLight
                                          : AppColors.onSurface,
                                      fontSize: 14,
                                      fontFamily: 'Epilogue',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${t["artist"]} • ${t["rhythm"]}",
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant
                                          .withOpacity(0.6),
                                      fontSize: 11,
                                      fontFamily: 'Be Vietnam Pro',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                                color: AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {},
                            ),
                            Icon(
                              isCurrent && _isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle_fill,
                              color: isCurrent
                                  ? AppColors.secondaryLight
                                  : AppColors.onSurface.withOpacity(0.3),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
