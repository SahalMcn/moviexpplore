import 'package:flutter/material.dart';
import 'package:movie_xpplore/models/movie_model.dart';
import 'package:movie_xpplore/services/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Movie> movies = [];
  Movie? selectedMovie;
  bool isLoading = false;
  bool isLoadingDetails = false;
  int currentPage = 1;
  String currentQuery = ""; // Default search

  // Booking Data
  String? selectedDate;
  String? selectedTime;
  String? selectedTheater; // Added for theater selection
  List<int> selectedSeats = []; // Tracking seats for the success splash

  Future<void> fetchMovieDetails(String imdbID) async {
    isLoadingDetails = true;
    notifyListeners();

    try {
      final Movie? movie = await _api.fetchDetails(imdbID);
      if (movie != null) {
        selectedMovie = movie;
      }
    } catch (e) {
      debugPrint("Provider Detail Fetch Error: $e");
    } finally {
      isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// Searches for movies using the OMDb API key d52ceef6
  Future<void> search(String query, {bool isNewSearch = true}) async {
    if (isNewSearch) {
      currentPage = 1;
      movies.clear();
      currentQuery = query;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Fetch results from API service
      final List<Movie> results = await _api.searchMovies(
        currentQuery,
        currentPage,
      );

      // FILTER: Only add movies with valid posters to maintain UI quality
      final filteredResults = results
          .where((movie) => movie.poster != "N/A" && movie.poster.isNotEmpty)
          .toList();

      movies.addAll(filteredResults);
    } catch (e) {
      debugPrint("Provider Search Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Handles pagination for the responsive grid
  void loadNextPage() {
    currentPage++;
    search(currentQuery, isNewSearch: false);
  }

  /// Sets the final booking details for the ticket and success animation
  void setBooking(
    String date,
    String time, {
    String? theater,
    List<int>? seats,
  }) {
    selectedDate = date;
    selectedTime = time;
    if (theater != null) selectedTheater = theater;
    if (seats != null) selectedSeats = seats;

    notifyListeners();
  }

  /// Resets selection after a successful booking
  void clearBooking() {
    selectedDate = null;
    selectedTime = null;
    selectedTheater = null;
    selectedSeats.clear();
    notifyListeners();
  }
}
