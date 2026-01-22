class Movie {
  final String title;
  final String year;
  final String imdbID;
  final String poster;
  final String? genre;
  final String? director;
  final String? rating;
  final String? plot;
  final String? cast;
  final String? runtime;

  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.poster,
    this.genre,
    this.director,
    this.rating,
    this.plot,
    this.cast,
    this.runtime,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'Unknown Title',
      year: json['Year'] ?? '',
      imdbID: json['imdbID'] ?? '',
      // Handle "N/A" posters by providing a fallback URL
      poster: (json['Poster'] == null || json['Poster'] == "N/A")
          ? 'https://via.placeholder.com/400x600?text=No+Poster+Available'
          : json['Poster'],
      genre: json['Genre'],
      director: json['Director'],
      rating: json['imdbRating'],
      plot: json['Plot'],
      cast: json['Actors'],
      runtime: json['Runtime'],
    );
  }
}
