import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_xpplore/models/movie_model.dart';

class ApiService {
  // Your OMDb API key
  final String _apiKey = "d52ceef6";
  final Dio _dio = Dio();

  /// Fetches a list of movies based on search query 's' and page number
  Future<List<Movie>> searchMovies(String query, int page) async {
    try {
      final response = await _dio.get(
        'https://www.omdbapi.com/',
        queryParameters: {
          'apikey': _apiKey,
          's': query, // Required search parameter
          'page': page, // For your responsive pagination
          'type': 'movie', // Restricts results to movies only
        },
      );

      if (response.data['Response'] == "True") {
        List list = response.data['Search'];
        // Mapping JSON to your Movie model
        return list.map((m) => Movie.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("API Search Error: $e");
      return [];
    }
  }

  /// Fetches full details for a specific movie using its IMDb ID 'i'
  Future<Movie?> fetchDetails(String id) async {
    try {
      final response = await _dio.get(
        'https://www.omdbapi.com/',
        queryParameters: {
          'apikey': _apiKey,
          'i': id, // Parameter for specific movie ID
          'plot': 'full', // Returns the complete synopsis
        },
      );

      if (response.data['Response'] == "True") {
        return Movie.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("API Detail Fetch Error: $e");
      return null;
    }
  }
}
