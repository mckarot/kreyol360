import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseService extends ChangeNotifier {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090');

  // Fallback structures if the database becomes offline
  Map<String, dynamic>? _fallbackProverb;
  List<Map<String, dynamic>> _fallbackVocab = [];
  List<Map<String, dynamic>> _fallbackRecipes = [];
  List<Map<String, dynamic>> _fallbackMusic = [];
  List<Map<String, dynamic>> _fallbackEvents = [];
  List<Map<String, dynamic>> _fallbackMarkers = [];
  List<Map<String, dynamic>> _fallbackTraditions = [];
  List<Map<String, dynamic>> _fallbackQuizzes = [];

  PocketBaseService() {
    _initFallbacks();
  }

  void _initFallbacks() {
    _fallbackProverb = {
      "creole": "Pati pou chaché, pa di ou trouvé",
      "translation": "To go looking doesn't mean you've found.",
      "explanation": "Ce proverbe rappelle que l'effort n'est que la première étape avant le succès."
    };

    _fallbackVocab = [
      {"creole": "Bonjou", "french": "Bonjour", "category": "Salutations", "example_creole": "Bonjou Mathieu, kouman ou yé?", "example_french": "Bonjour Mathieu, comment vas-tu?"},
      {"creole": "Bel ti manmay", "french": "Bel enfant", "category": "Expressions", "example_creole": "I sé an bel ti manmay.", "example_french": "C'est un bel enfant."}
    ];

    _fallbackRecipes = [
      {
        "title": "Accras de Morue",
        "description": "Les fameux beignets croustillants à la morue et aux piments doux, incontournables des Antilles.",
        "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAhlK7znsUTtJetY-JqPP-c7HZ8YGsejUdEbHi3eT1Suxjb7OHdeQFETRcsz1cPk3u5ZLwPIezV8D90wsDZxajiZ7xlJp5_mkY6rye7_wHdID7lHGR4C4Z7Sk4yGbskVGjeeLnMT8Hb59t7B_KInUuf_rFHIebxm_vlIcZHrHP6t91uyQnV9RCEYewEPPV7WZFKTE9QQYuPlfvlUkjZC5GUbUG7uoP3XhLnW0h-UBmB6vD34Afa2Ej6NbHfbexSd6YDmDheJXWijA",
        "prep_time": 30,
        "difficulty": "Facile",
        "ingredients": ["250g de morue", "200g de farine", "Ail, Persil, Cives", "Piment végétarien"],
        "steps": ["Émietter la morue.", "Mélanger la farine et l'eau.", "Frire à l'huile chaude."]
      }
    ];

    _fallbackMusic = [
      {
        "title": "Rhythm of Bèlè",
        "rhythm": "Bèlè",
        "artist": "Ti Raoul",
        "cover_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDne7s-KB8vwrk95giZfgIN0YcqNzJbR6ESraBuKM0gt2fpiOevm4pDMmMEDiCfCA9vU39CvRingAnzXpFqIjcs4pSjiUgeasv3XPA7LNkX4jHU0NEeBIgpuhzJ2ub8nR7OPbqhB_Auxz4rltaEMEQYbU6J_2n46AC9Y66-7I8f_-YAJrj2WApqRONg8xxmeOjo1czugwt-Z8nKtbi6X_iOBzRf2gnWWJbn_d52lxtTjwu4g8IemG0coXxfFEMNrtoinCOyHw7TCw",
        "history": "Le Bèlè est une danse et un rythme traditionnel de la Martinique."
      }
    ];

    _fallbackMarkers = [
      {"name": "Maison du Bèlè", "description": "Centre culturel dédié au tambour bèlè.", "latitude": 14.782, "longitude": -60.993, "category": "Patrimoine"}
    ];
  }

  // Generic helper to parse list rules safely
  List<Map<String, dynamic>> _parseList(List<RecordModel> items) {
    return items.map((item) => item.toJson()).toList();
  }

  // 1. Proverbs
  Future<Map<String, dynamic>> fetchProverbOfTheDay() async {
    try {
      final records = await pb.collection('proverbs').getList(page: 1, perPage: 1);
      if (records.items.isNotEmpty) {
        return records.items.first.toJson();
      }
    } catch (e) {
      debugPrint("PocketBase fetchProverbOfTheDay error: $e");
    }
    return _fallbackProverb!;
  }

  // 2. Vocabulary
  Future<List<Map<String, dynamic>>> fetchVocabularyList() async {
    try {
      final records = await pb.collection('vocabulary').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchVocabulary error: $e");
    }
    return _fallbackVocab;
  }

  // 3. Quizzes
  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      final records = await pb.collection('quizzes').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchQuizzes error: $e");
    }
    return _fallbackQuizzes;
  }

  // 4. Questions
  Future<List<Map<String, dynamic>>> fetchQuestionsForQuiz(String quizId) async {
    try {
      final records = await pb.collection('questions').getFullList(
        filter: 'quiz_id = "$quizId"',
      );
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchQuestions error: $e");
    }
    return [];
  }

  // 5. Recipes
  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    try {
      final records = await pb.collection('recipes').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchRecipes error: $e");
    }
    return _fallbackRecipes;
  }

  // 6. Music
  Future<List<Map<String, dynamic>>> fetchMusic() async {
    try {
      final records = await pb.collection('music').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchMusic error: $e");
    }
    return _fallbackMusic;
  }

  // 7. Events
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      final records = await pb.collection('events').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchEvents error: $e");
    }
    return _fallbackEvents;
  }

  // 8. Map Markers
  Future<List<Map<String, dynamic>>> fetchMapMarkers() async {
    try {
      final records = await pb.collection('map_markers').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchMapMarkers error: $e");
    }
    return _fallbackMarkers;
  }

  // 9. Traditions
  Future<List<Map<String, dynamic>>> fetchTraditions() async {
    try {
      final records = await pb.collection('traditions').getFullList();
      return _parseList(records);
    } catch (e) {
      debugPrint("PocketBase fetchTraditions error: $e");
    }
    return _fallbackTraditions;
  }
}
