import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/network/pocketbase_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _activeTab = 0; // 0 = Apprentissage (Vocab), 1 = Défis & Quizz
  String? _selectedCategory; // Null = Home learning overview, otherwise shows vocab for category

  // Quiz State
  Map<String, dynamic>? _selectedQuiz;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _quizFinished = false;
  int _score = 0;
  bool _answerSubmitted = false;

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
            // User Header Profile Overview
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.tertiary, width: 3),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAo4ohnQNU4A7ci0V3ReoMH0Ah6ROALG34hvhC9CyzJ6YSxMFBabuLPSnaEwqzhdzsS0bvZclLMZvD3xVU4Jwcsz08sHuAHejW_wcnl1zy7IG225uQz-B-aKX406scrdxEdcRKSWt8a6le3Fx-zy1AYHjvEyjK8tIie9-DoV0BFLHTTQPud6T7lu4LitvxeEfKFgqHUMdUvHU8I71bqM7b6Wj8MEIPxkWmnXCHVFD1SJ7rvqlz4KQIkZhgS3g0pW7E5yS0VThYGPw',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mathieu",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 22,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Créolophone Passionné",
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 13,
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Badge XP Stats Row
            Row(
              children: [
                Expanded(
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    borderRadius: 16,
                    child: const Column(
                      children: [
                        Text(
                          "Niveau",
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontFamily: 'Be Vietnam Pro'),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "12",
                          style: TextStyle(color: AppColors.tertiary, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    borderRadius: 16,
                    child: const Column(
                      children: [
                        Text(
                          "Total XP",
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontFamily: 'Be Vietnam Pro'),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "2,450 XP",
                          style: TextStyle(color: AppColors.secondaryLight, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    borderRadius: 16,
                    child: const Column(
                      children: [
                        Text(
                          "Série",
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontFamily: 'Be Vietnam Pro'),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "7 Jours 🔥",
                          style: TextStyle(color: AppColors.primaryLight, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Toggles
            if (_selectedQuiz == null) ...[
              Row(
                children: [
                  _buildTabButton(0, "Langue & Cours", Icons.translate),
                  const SizedBox(width: 12),
                  _buildTabButton(1, "Défis & Quizz", Icons.quiz),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Content switching
            if (_selectedQuiz != null)
              _buildQuizActivePanel()
            else if (_activeTab == 1)
              _buildQuizListTab(pbService)
            else if (_selectedCategory != null)
              _buildCategoryVocabularyView(pbService)
            else
              _buildLearningHubOverview(pbService)
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
            _selectedCategory = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer.withOpacity(0.2) : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? AppColors.primaryLight : AppColors.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.onSurface : AppColors.onSurface.withOpacity(0.6),
                  fontSize: 13,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Faithfully reconstruct the Langue Hub / Apprentissage Overview
  Widget _buildLearningHubOverview(PocketBaseService pbService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Current Progress Card
        GlassPanel(
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Background Image decoration
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDBT56hWmJVHPJQ41WQQiiwPChFLm04IqwpPqRCzOiAyig1wSEjqPUABXjq8N9JURSjnIivK_WHl_s0ejtKNPzsDFmd9TZBWhq5wdGtgBeY9YofYK20PEKuFkO_23Wwl3eHieGkTU4G7qCGB4Ge3wb_DCESlJLv9R-2FF_p1G-OpWAS3HXk_rbhMQ6N4QFzcwjcK0n2G31ciKV84OSWqG9p-a0NEqfAizjjswAHunjlAqkNwyYPGUW1Wmef5rVnNt9uKUilYbgq5w',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Dark gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  "NIVEAU 1",
                                  style: TextStyle(
                                    color: AppColors.secondaryLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Salutations Quotidiennes",
                                style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Continuez votre apprentissage des expressions de base.",
                                style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        // Circular progress representation
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 4,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                              ),
                              const Text(
                                "75%",
                                style: TextStyle(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Linear progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "12/16 Leçons",
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "En cours",
                          style: TextStyle(color: AppColors.secondaryLight, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = "Salutations";
                          });
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Continuer l'apprentissage",
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 16),
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
        const SizedBox(height: 32),

        // 2. Ti Pawol Card
        const Text(
          "Ti Pawol du Jour",
          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: const Border(
              left: BorderSide(color: AppColors.tertiary, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_incandescent, color: AppColors.tertiary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "SAGESSE CRÉOLE",
                    style: TextStyle(color: AppColors.tertiary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "\"Piti piti, zwazo fè nich li.\"",
                style: TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Petit à petit, l'oiseau fait son nid. (Patience et persévérance mènent au succès).",
                style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 3. Learning Domains Grid (Domaines d'Étude)
        const Text(
          "Domaines d'Étude",
          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            _buildDomainCard(
              title: "Pawol Fondamental",
              subtitle: "Vocabulaire de base",
              icon: Icons.chat_bubble,
              color: AppColors.primary,
              categoryKey: "Salutations",
            ),
            _buildDomainCard(
              title: "Proverbes",
              subtitle: "Sagesses culturelles",
              icon: Icons.auto_stories,
              color: AppColors.tertiary,
              categoryKey: "Expressions",
            ),
            _buildDomainCard(
              title: "Grammaire Kréyol",
              subtitle: "Structure & règles",
              icon: Icons.rule,
              color: AppColors.secondary,
              categoryKey: "Salutations", // Fallback to list
            ),
            _buildDomainCard(
              title: "Idiomes",
              subtitle: "Façons de parler",
              icon: Icons.psychology,
              color: AppColors.primaryLight,
              categoryKey: "Sentiments",
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 4. Weekly Challenge Card
        const Text(
          "Défi de la Semaine",
          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GlassPanel(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                ),
                child: const Icon(Icons.star, color: AppColors.tertiary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "5 Jours d'affilée",
                      style: TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Complétez une leçon aujourd'hui.",
                      style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const Text(
                  "Participer",
                  style: TextStyle(color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDomainCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String categoryKey,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryKey;
        });
      },
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.6), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Vocab card category detail view
  Widget _buildCategoryVocabularyView(PocketBaseService pbService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
            ),
            Text(
              "Catégorie : $_selectedCategory",
              style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: pbService.fetchVocabularyList(),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            final filtered = list.where((item) => item["category"] == _selectedCategory).toList();

            if (filtered.isEmpty) {
              return GlassPanel(
                child: const Center(
                  child: Text("Aucune expression trouvée dans cette catégorie.", style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return GlassPanel(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["creole"] ?? "",
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["french"] ?? "",
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Be Vietnam Pro',
                        ),
                      ),
                      if (item["example_creole"] != null) ...[
                        const SizedBox(height: 12),
                        Divider(color: Colors.white.withOpacity(0.05)),
                        const SizedBox(height: 6),
                        Text(
                          "Exemple :",
                          style: TextStyle(color: AppColors.primaryLight.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "\"${item["example_creole"]}\"",
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            fontFamily: 'Be Vietnam Pro',
                          ),
                        ),
                        Text(
                          "\"${item["example_french"]}\"",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'Be Vietnam Pro',
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuizListTab(PocketBaseService pbService) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pbService.fetchQuizzes(),
      builder: (context, snapshot) {
        final quizzes = snapshot.data ?? [];
        if (quizzes.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final q = quizzes[index];
            return GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q["title"] ?? "",
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18,
                      fontFamily: 'Epilogue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q["description"] ?? "",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withOpacity(0.8),
                      fontSize: 13,
                      fontFamily: 'Be Vietnam Pro',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.tertiary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Niveau ${q["level"] ?? 1}",
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final questions = await pbService.fetchQuestionsForQuiz(q["id"]);
                          setState(() {
                            _selectedQuiz = q;
                            _questions = questions;
                            _currentQuestionIndex = 0;
                            _selectedAnswerIndex = null;
                            _quizFinished = false;
                            _score = 0;
                            _answerSubmitted = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Démarrer"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizActivePanel() {
    if (_questions.isEmpty) {
      return GlassPanel(
        child: const Center(
          child: Text("Chargement des questions...", style: TextStyle(color: AppColors.onSurface)),
        ),
      );
    }

    if (_quizFinished) {
      return GlassPanel(
        borderColor: AppColors.secondary,
        child: Column(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.tertiary, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Quizz Terminé !",
              style: TextStyle(color: AppColors.onSurface, fontSize: 22, fontFamily: 'Epilogue', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Votre score : $_score / ${_questions.length}",
              style: const TextStyle(color: AppColors.secondaryLight, fontSize: 18, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedQuiz = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Retour au Profil"),
            ),
          ],
        ),
      );
    }

    final q = _questions[_currentQuestionIndex];
    final options = List<String>.from(q["options"] ?? []);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuiz = null;
                  });
                },
                child: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            q["question_text"] ?? "",
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(options.length, (index) {
            final isSelected = _selectedAnswerIndex == index;
            final isCorrect = q["correct_option_index"] == index;
            
            Color cardColor = AppColors.surfaceContainer;
            Color borderColor = Colors.white.withOpacity(0.05);

            if (_answerSubmitted) {
              if (isCorrect) {
                cardColor = AppColors.secondaryContainer.withOpacity(0.6);
                borderColor = AppColors.secondary;
              } else if (isSelected) {
                cardColor = AppColors.primaryContainer.withOpacity(0.4);
                borderColor = AppColors.primary;
              }
            } else if (isSelected) {
              cardColor = AppColors.primaryContainer.withOpacity(0.2);
              borderColor = AppColors.primary;
            }

            return GestureDetector(
              onTap: _answerSubmitted
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswerIndex = index;
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      options[index],
                      style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontFamily: 'Be Vietnam Pro'),
                    ),
                    if (_answerSubmitted && isCorrect)
                      const Icon(Icons.check_circle, color: AppColors.secondaryLight, size: 20)
                    else if (_answerSubmitted && isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: AppColors.primaryLight, size: 20),
                  ],
                ),
              ),
            );
          }),
          
          if (_answerSubmitted) ...[
            const SizedBox(height: 16),
            Text(
              "Explication :",
              style: TextStyle(color: AppColors.tertiaryLight.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              q["explanation"] ?? "",
              style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.9), fontSize: 13, height: 1.4),
            ),
          ],
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _selectedAnswerIndex == null
                    ? null
                    : () {
                        if (!_answerSubmitted) {
                          setState(() {
                            _answerSubmitted = true;
                            if (_selectedAnswerIndex == q["correct_option_index"]) {
                              _score++;
                            }
                          });
                        } else {
                          setState(() {
                            if (_currentQuestionIndex + 1 < _questions.length) {
                              _currentQuestionIndex++;
                              _selectedAnswerIndex = null;
                              _answerSubmitted = false;
                            } else {
                              _quizFinished = true;
                            }
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_answerSubmitted ? "Suivant" : "Valider"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
