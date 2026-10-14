import 'package:supabase_flutter/supabase_flutter.dart';
import '../database_service.dart';
class RatingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer les statistiques d'un appartement
  Future<Map<String, dynamic>> getAppartmentStats(String appartementId) async {
    try {
      final response = await _supabase
          .from('ratings')
          .select('rating')
          .eq('appartement_id', appartementId);

      final List<dynamic> ratings = response;

      if (ratings.isEmpty) {
        return {
          'avg_rating': 0.0,
          'ratings_count': 0,
          'distribution': {},
        };
      }

      final List<int> ratingValues = ratings.map((r) => r['rating'] as int).toList();
      final double avg = ratingValues.reduce((a, b) => a + b) / ratingValues.length;

      final Map<int, int> distribution = {};
      for (final rating in ratingValues) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      return {
        'avg_rating': avg,
        'ratings_count': ratingValues.length,
        'distribution': distribution,
      };
    } catch (e) {
      print('Erreur getAppartmentStats: $e');
      return {
        'avg_rating': 0.0,
        'ratings_count': 0,
        'distribution': {},
      };
    }
  }

  // Récupérer la note de l'utilisateur pour un appartement
  Future<int?> getUserRating(String appartementId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('ratings')
          .select('rating')
          .eq('appartement_id', appartementId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null ? response['rating'] as int : null;
    } catch (e) {
      print('Erreur getUserRating: $e');
      return null;
    }
  }

  // Récupérer les commentaires d'un appartement
  Future<List<Map<String, dynamic>>> getComments(String appartementId) async {
    try {
      final response = await _supabase
          .from('ratings')
          .select('''
            rating,
            comment,
            created_at,
            users:user_id (prenom, nom)
          ''')
          .eq('appartement_id', appartementId)
          .not('comment', 'is', null)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getComments: $e');
      return [];
    }
  }

  // Soumettre une note
  Future<void> submitRating({
    required String appartementId,
    required int rating,
    String? comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final data = {
        'appartement_id': appartementId,
        'user_id': user.id,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Vérifier si l'utilisateur a déjà noté
      final existing = await _supabase
          .from('ratings')
          .select('id')
          .eq('appartement_id', appartementId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        // Mettre à jour
        await _supabase
            .from('ratings')
            .update(data)
            .eq('id', existing['id']);
      } else {
        // Insérer
        await _supabase.from('ratings').insert(data);
      }
    } catch (e) {
      print('Erreur submitRating: $e');
      rethrow;
    }
  }

  // Charger les ratings pour plusieurs appartements (pour les listes)
  Future<Map<String, Map<String, dynamic>>> loadRatingsForAppartements(List<String> ids) async {
    try {
      final response = await _supabase
          .from('ratings')
          .select('appartement_id, rating')
          .inFilter('appartement_id', ids);

      final Map<String, List<int>> ratingsList = {};
      for (final r in response) {
        final id = r['appartement_id'].toString();
        final ratingValue = r['rating'] as int;
        ratingsList.putIfAbsent(id, () => []);
        ratingsList[id]!.add(ratingValue);
      }

      final Map<String, Map<String, dynamic>> result = {};
      for (final id in ids) {
        final list = ratingsList[id] ?? [];
        final avg = list.isNotEmpty ? list.reduce((a, b) => a + b) / list.length : 0.0;
        result[id] = {
          'avg_rating': avg,
          'ratings_count': list.length,
          'distribution': {},
        };
      }

      return result;
    } catch (e) {
      print('Erreur loadRatingsForAppartements: $e');
      return {};
    }
  }
}

// Extension pour DatabaseService (pour garder la compatibilité)
extension RatingServiceExtension on DatabaseService {
  Future<Map<String, dynamic>> getRatingStats(String appartementId) {
    return RatingService().getAppartmentStats(appartementId);
  }

  Future<int?> getUserRating(String appartementId) {
    return RatingService().getUserRating(appartementId);
  }

  Future<void> rateAppartement({
    required String appartementId,
    required int rating,
    String? comment,
  }) {
    return RatingService().submitRating(
      appartementId: appartementId,
      rating: rating,
      comment: comment,
    );
  }
}