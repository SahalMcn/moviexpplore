import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_xpplore/models/movie_model.dart';
import 'package:movie_xpplore/providers/movie_provider.dart';
import 'package:movie_xpplore/screens/detail_screen.dart';
import 'package:movie_xpplore/widgets/shimmer_loader.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 6 : (screenWidth > 800 ? 4 : 2);
    double horizontalPadding = screenWidth > 1200 ? 100 : 20;

    final provider = context.watch<MovieProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0101), 
      body: CustomScrollView(
        slivers: [
          // 1. Responsive Hero Section
          SliverToBoxAdapter(
            child: _buildResponsiveHero(
              context,
              screenWidth,
              provider.movies.isNotEmpty ? provider.movies[0] : null,
              provider.isLoading,
            ),
          ),

          // 2. Sections with dynamic padding and grid columns
          _buildSliverHeader("Trending Movie Near You", horizontalPadding),
          _buildResponsiveGrid(
            context,
            crossAxisCount,
            horizontalPadding,
            isBanner: true,
          ),

          _buildSliverHeader("Upcoming", horizontalPadding),
          _buildResponsiveGrid(
            context,
            crossAxisCount,
            horizontalPadding,
            isBanner: false,
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildResponsiveHero(
    BuildContext context,
    double width,
    Movie? movie,
    bool isLoading,
  ) {
    double heroHeight = width > 800 ? 600 : 450;

    // Show shimmer when loading and no movies are available yet
    if (isLoading && movie == null) {
      return HeroShimmer();
    }

    // Fallback if no movie is loaded yet
    if (movie == null) return SizedBox(height: heroHeight);

    return Stack(
      children: [
        SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: movie.poster,
            fit: BoxFit.cover,
            // Graceful error handling for broken URLs
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.movie_creation_outlined,
                color: Colors.white24,
                size: 50,
              ),
            ),
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          ),
        ),
        // Cinematic Gradient Overlay
        Container(
          height: heroHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xFF0F0101)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width > 1200 ? 100 : 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () {
                        // Check if the movie is valid before navigating
                        if (movie.poster != "N/A" && movie.poster.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(movie: movie),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Details not available for this title.",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Watch Now"),
                    ),
                    const SizedBox(width: 15),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Trailer not available for this movie."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text("Watch Trailer"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(String title, double padding) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    int columns,
    double padding, {
    required bool isBanner,
  }) {
    final provider = context.watch<MovieProvider>();

    // FILTER: Filter out movies that have "N/A" posters to keep UI clean
    final validMovies = provider.movies
        .where((m) => m.poster != "N/A" && m.poster.isNotEmpty)
        .toList();

    // Show shimmer grid while loading and the list is empty
    if (provider.isLoading && validMovies.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: isBanner ? 1.6 : 0.7,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => MovieCardShimmer(isBanner: isBanner),
            childCount: columns * 2, // Show a couple of rows of shimmers
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: isBanner ? 1.6 : 0.7,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (validMovies.isEmpty) return const SizedBox();
          final movie = validMovies[index];
          return HoverableMovieCard(movie: movie, isBanner: isBanner);
        }, childCount: validMovies.length),
      ),
    );
  }
}

class HoverableMovieCard extends StatefulWidget {
  final Movie movie;
  final bool isBanner;

  const HoverableMovieCard({
    super.key,
    required this.movie,
    required this.isBanner,
  });

  @override
  State<HoverableMovieCard> createState() => _HoverableMovieCardState();
}

class _HoverableMovieCardState extends State<HoverableMovieCard> {
  bool _isHovered = false;
  bool _imageFailed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0, // Scale effect for PC
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: () {
            // Ensure we don't navigate if the poster is "N/A" or image failed to load
            if (widget.movie.poster != "N/A" &&
                widget.movie.poster.isNotEmpty &&
                !_imageFailed) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(movie: widget.movie),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Details not available for this title."),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.movie.poster,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.white10),
                    // Secondary error check
                    errorWidget: (context, url, error) {
                      if (!_imageFailed) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _imageFailed = true;
                            });
                          }
                        });
                      }
                      return Container(
                        color: Colors.black,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                        ),
                      );
                    },
                  ),
                  if (!widget.isBanner)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      bottom: _isHovered ? 0 : -60, // Slide in from bottom
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50,
                        color: Colors.red.withOpacity(0.9),
                        child: const Center(
                          child: Text(
                            "Book Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
