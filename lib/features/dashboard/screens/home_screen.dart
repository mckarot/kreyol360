import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/network/pocketbase_client.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../cuisine/screens/recipes_screen.dart';
import '../../traditions/screens/traditions_screen.dart';
import '../../traditions/screens/traditions_fetes_hub_screen.dart';
import 'outings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // Safe play
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
        setState(() {
          _isPlaying = true;
        });
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
      // Simulated play even if URL fails
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar & Level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.tertiary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tertiary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBEkuHsPzQZz7n-GK0fCegHge9K36lUits5JkGF3edjGZ0eTT9Ts_VnI02jzV_G4Xjsv_zGF32bgTlH65eJKS0sYAOpkclmsZU-jk6R2j-U98SXLDl3VitWLQUdmfn2VXyyJpL2GxK547G3hud0RUR9oToadvVtAFj1LtNH3mx76jWy2CpwU60VsmO1ynA80_X7OO9_CN35SPzFC--kG90gWYDPMGT-Kj5-Q5DcIKFYlCk6gGQklpA3mtFZGdVVSFJcuIra_PTr3Q',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bonjou",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'Be Vietnam Pro',
                          ),
                        ),
                        const Text(
                          "Mathieu",
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 20,
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_fire_department, color: AppColors.tertiary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Lvl 12",
                        style: TextStyle(
                          color: AppColors.tertiary,
                          fontSize: 12,
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Ti Pawol du jour Section
            FutureBuilder<Map<String, dynamic>>(
              future: pbService.fetchProverbOfTheDay(),
              builder: (context, snapshot) {
                final proverb = snapshot.data ?? {
                  "creole": "Pati pou chaché, pa di ou trouvé",
                  "translation": "To go looking doesn't mean you've found.",
                  "explanation": "L'effort précède le résultat."
                };
                return GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppColors.secondaryLight, size: 16),
                              SizedBox(width: 8),
                              Text(
                                "TI PAWOL DU JOUR",
                                style: TextStyle(
                                  color: AppColors.secondaryLight,
                                  fontSize: 11,
                                  fontFamily: 'Be Vietnam Pro',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _toggleAudio(proverb["audio_url"]),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainer,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.primaryLight,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        proverb["creole"] ?? "",
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 22,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        proverb["translation"] ?? "",
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withOpacity(0.8),
                          fontSize: 15,
                          fontFamily: 'Be Vietnam Pro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      
                      // Audio waves
                      if (_isPlaying) ...[
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return Row(
                              children: List.generate(12, (index) {
                                final height = (index % 3 == 0)
                                    ? 8 + 14 * _waveController.value
                                    : (index % 2 == 0)
                                        ? 4 + 18 * (1 - _waveController.value)
                                        : 6 + 12 * _waveController.value;
                                return Container(
                                  width: 3,
                                  height: height,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // Bento Grid Explore
            const Text(
              "Explorer",
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 22,
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid of categories
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildBentoCard(
                  title: "Langue",
                  subtitle: "Language & Quiz",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCXjWzH7EKw-lFC_rYgqqC0HjrDAkkfrHOXx7OqQThrcTfeqejMcX8I9fRWnaVeFpbVmxZnOUayEr3aGa1-ofPdaa-GnAgnPboQFPmAMWv1QI6IQdCyeeLdONNXHQQ4yVVSp3fnHt_SISqd1yT5qnBnGb9BMWfhGqFqrUrYuzYJJvRhbeF5QBHup2r8yGVWDxe52_uk37l8VTDS9zfpq1YbGXxZxLRWsuQkh67fAJA3r8_HU88hRFO_MCNUIdFGNkM6yTKcBBTEPA",
                  color: AppColors.primary.withOpacity(0.4),
                  onTap: () {
                    // Navigate to Language and Profile tab (Index 3)
                    Provider.of<NavigationService>(context, listen: false).changeTab(3);
                  },
                ),
                _buildBentoCard(
                  title: "Musique & Rythmes",
                  subtitle: "Music & Rhythms",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuC9Cucz5MvWSOeLtmwV5B6rUjmszW1691FpyEmGZcUzCqyiRMZtmk_gyU4oaWlOuoaEYmIvvJKkp05qVMO08XbIWPVxXpFx3alDkuRAW8ZOGmzr0-JsjcO_d71-tAdj-yXu4Se2704s58UkFWKfymHAVCCuLk1jzET5kiVoWokazLSl55mv4KIqBLI7497xdUgHJBwOpls7g8ldy0c9h_MAueCUqASU7pXayDyfCFcNNYOD4QfKrWmutEzHdLQa3-2Js9Uw7f-fOg",
                  color: AppColors.secondary.withOpacity(0.3),
                  onTap: () {
                    // Switch to music tab (Index 2)
                    Provider.of<NavigationService>(context, listen: false).changeTab(2);
                  },
                ),
                _buildBentoCard(
                  title: "Istwa & Patrimoine",
                  subtitle: "Traditions & History",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuD4v3wDILz__cU5e40bLHi-PreiIaV5s_DHCaX9dhYvEt-hXmREhocL7PbsxkmflgFeQXTGNE1peT5z6emehYTExzaTqXtlHm4RXn51x_AbZo9fbN9y76TGMa5I-IUWKBeVxVzN2RJq7iC5SG8xJRPXbZLxJOiS_nBbwGvXOlOUBDsRCwmHB2upb-ldq8YTE6cpRTQZ3Lwdt67e-OlMXzaUtBEaOEDVszCQFBEYd5D-kpcihdQyLSzSBE2EK4dymqE8vW15-6pCoQ",
                  color: AppColors.tertiary.withOpacity(0.3),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TraditionsScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  title: "Manjé",
                  subtitle: "Creole Cuisine",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAhlK7znsUTtJetY-JqPP-c7HZ8YGsejUdEbHi3eT1Suxjb7OHdeQFETRcsz1cPk3u5ZLwPIezV8D90wsDZxajiZ7xlJp5_mkY6rye7_wHdID7lHGR4C4Z7Sk4yGbskVGjeeLnMT8Hb59t7B_KInUuf_rFHIebxm_vlIcZHrHP6t91uyQnV9RCEYewEPPV7WZFKTE9QQYuPlfvlUkjZC5GUbUG7uoP3XhLnW0h-UBmB6vD34Afa2Ej6NbHfbexSd6YDmDheJXWijA",
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RecipesScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  title: "Traditions & Fêtes",
                  subtitle: "Festivals & Hub",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBBMeAJROrPNbZGENYZstga1I9U1PlnrOelWvLGCjkbewZ1jOnJ5IN-w_583kco_7-rY3TQzIs4yg9iWNIZQW2bjiPNFo2p8-FavRx08rcHH55WZbpp0SvxJVY9UWxNkwrjiV5GagWltqfu9c_tRDaXr_llJuzIxTeVZfMdUcvIOjH7LlHp1rRpF6QNG9T8tfbGE0Ca8gzDhO7oEDYihbGG2LWMS-8R5G7VUPHHPsfSqvBQZa9b7gh-EupKNaGTXK2rRuJ7EwtXSA",
                  color: AppColors.tertiary.withOpacity(0.3),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TraditionsFetesHubScreen()),
                    );
                  },
                ),
                _buildBentoCard(
                  title: "Sortir en Martinique",
                  subtitle: "Agenda & Outings",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDSn9_wYgEGBuWYouZV3pCVK7swux0AnpW4vbIi25gkprKdDrNina-xoTfixoKXo0empN9oMMJthQ2dMTfakdbPo0jxktBdaghnJ8HjPXdnk7GwyU2K_r-tUCNb-j_OJlxwWO4yrxSC4_P-yEKSonMCjtYUTQkpGDY3O3Ys8LvJyfaOtha7WoD0AswUJe8DM4ibhGlbRoGHF_8Q2PNPEhepe-sFVlkldtcduvV7dQkhEyJUIh21nfzHPQrTLDL1QrpyLupMdXn7AA",
                  color: AppColors.primary.withOpacity(0.3),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OutingsScreen(
                          onToggleMap: () {
                            Navigator.of(context).pop();
                            Provider.of<NavigationService>(context, listen: false).changeTab(1);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Surprise widget
            GlassPanel.floating(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Envie d'une vibration ?",
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 14,
                            fontFamily: 'Be Vietnam Pro',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Découvrez un rythme selon votre humeur",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 12,
                            fontFamily: 'Be Vietnam Pro',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Switch to music tab (Index 2)
                      Provider.of<NavigationService>(context, listen: false).changeTab(2);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shuffle, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Vibrer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Be Vietnam Pro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // Tint Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Background Image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppColors.surfaceContainer);
                    },
                  ),
                ),
              ),
              // Gradient bottom overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 16,
                              fontFamily: 'Epilogue',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant.withOpacity(0.7),
                              fontSize: 11,
                              fontFamily: 'Be Vietnam Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.onSurface,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
