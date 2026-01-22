import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_xpplore/widgets/expandable_text.dart';
import 'package:provider/provider.dart';
import 'package:movie_xpplore/models/movie_model.dart';
import 'package:movie_xpplore/providers/movie_provider.dart';
import 'package:movie_xpplore/screens/booking_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Movie movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Selection States
  int _selectedDateIndex = 3; // Defaults to Mon 15
  String? _selectedTime;
  String? _selectedTheater;
  final List<int> _selectedSeats = []; // Tracking selected seats

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      if (provider.selectedMovie == null ||
          provider.selectedMovie!.imdbID != widget.movie.imdbID) {
        provider.fetchMovieDetails(widget.movie.imdbID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double sidePadding = width > 1200 ? width * 0.2 : 20.0;
    final provider = Provider.of<MovieProvider>(context);
    final movie = provider.selectedMovie ?? widget.movie;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0101),
      body: provider.isLoadingDetails
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(context, width, movie),
                    ),
                    _buildSectionTitle("About The Movie", sidePadding),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      sliver: SliverToBoxAdapter(
                        child: ExpandableText(
                          movie.plot ?? "No plot available.",
                          style: TextStyle(
                            color: Colors.grey[400],
                            height: 1.5,
                            fontSize: 14,
                          ),
                          trimLines: 3,
                        ),
                      ),
                    ),
                    _buildSectionTitle("Cast", sidePadding),
                    SliverToBoxAdapter(
                      child: _buildCastList(sidePadding, movie),
                    ),
                    _buildSectionTitle("Select Showtimes", sidePadding),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildDateSelector(),
                            const SizedBox(height: 20),
                            _buildTheaterSection(
                              "Cinepolis Gokulam Mall, Kozhikode",
                            ),
                            _buildTheaterSection("PVS Film City, Calicut"),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomBar(context),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, double width, Movie movie) {
    return SizedBox(
      height: 450,
      child: Stack(
        children: [
          Image.network(
            movie.poster,
            width: width,
            height: 450,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: movie.imdbID,
                      child: Image.network(movie.poster, width: 140),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (movie.rating != null &&
                            movie.genre != null &&
                            movie.runtime != null)
                          _buildTags([
                            "⭐ ${movie.rating}",
                            movie.genre!,
                            movie.runtime!,
                          ]),
                        const SizedBox(height: 10),
                        _buildTags(["2D, IMAX 2D", "English"]),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                tag,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionTitle(String title, double padding) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(padding, 30, padding, 15),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCastList(double padding, Movie movie) {
    final cast = movie.cast?.split(', ') ?? [];
    if (cast.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          "No cast information available.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: padding),
        itemCount: cast.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.white10, radius: 25),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cast[index].trim(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    List<String> days = ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedDateIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${12 + index}",
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTheaterSection(String theaterName) {
    List<String> times = ["09:40 AM", "12:30 PM", "03:45 PM", "07:00 PM"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          theaterName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times.map((time) {
            bool isSelected =
                _selectedTime == time && _selectedTheater == theaterName;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedTime = time;
                  _selectedTheater = theaterName;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.white24,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      "Dolby 7.1",
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context); // Close the animation overlay
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(movie: widget.movie),
            ),
          );
        });

        return Scaffold(
          backgroundColor: const Color(0xFF0F0101),
          body: Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: Image.network(
                  widget.movie.poster,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/success.json',
                      width: 200,
                      repeat: false,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(widget.movie.poster),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Booking Successful!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
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

  void _showSeatSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0101),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
children: [
                const Text(
                  "Select Seats",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 4,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white12,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const Text(
                  "SCREEN",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.builder(
                    itemCount: 60,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                      itemBuilder: (context, index) {
                        bool isBooked = index % 7 == 0;
                        bool isSelected = _selectedSeats.contains(index);
                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  setModalState(() {
                                    if (isSelected) {
                                      _selectedSeats.remove(index);
                                    } else {
                                      _selectedSeats.add(index);
                                    }
                                  });
                                  setState(() {});
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey[900]
                                  : (isSelected ? Colors.red : Colors.white12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isBooked
                                ? const Icon(
                                    Icons.close,
                                    color: Colors.white24,
                                    size: 10,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectedSeats.isEmpty
                        ? null
                        : () {
                            context.read<MovieProvider>().setBooking(
                              "Jan ${12 + _selectedDateIndex}",
                              _selectedTime!,
                              seats: _selectedSeats,
                              theater: _selectedTheater,
                            );
                            Navigator.pop(context);
                            _showSuccessAnimation(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text("Confirm ${_selectedSeats.length} Seats"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    bool canProceed = _selectedTime != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A0101),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTheater ?? "Select Theater",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedTime ?? "Select Showtime",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canProceed ? _showSeatSelection : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              disabledBackgroundColor: Colors.grey[800],
              minimumSize: const Size(180, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _selectedSeats.isEmpty ? "Select Seats" : "Change Seats",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
