import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:movie_xpplore/models/movie_model.dart';
import 'package:movie_xpplore/providers/movie_provider.dart';
import 'package:movie_xpplore/widgets/movie_ticket.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class BookingScreen extends StatefulWidget {
  final Movie movie;
  const BookingScreen({super.key, required this.movie});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // Helper to convert seat indices to a user-friendly format (e.g., "A1, B2")
  String _formatSeatNumbers(List<int> seats) {
    if (seats.isEmpty) return "N/A";
    return seats.map((seatIndex) {
      final row = String.fromCharCode('A'.codeUnitAt(0) + (seatIndex ~/ 8));
      final col = (seatIndex % 8) + 1;
      return '$row$col';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<MovieProvider>();
    double width = MediaQuery.of(context).size.width;
    String formattedSeats = _formatSeatNumbers(booking.selectedSeats);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0101),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Your Ticket", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width > 600 ? 400 : width * 0.9,
                child: Screenshot(
                  controller: _screenshotController,
                  child: MovieTicket(
                    top: _buildTicketTop(booking, formattedSeats),
                    bottom: _buildTicketBottom(booking, formattedSeats),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _downloadTicket,
                    child: const Text("Download Ticket", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text("Done", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadTicket() async {
    // 1. Check for storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Storage permission is required to save the ticket."),
      ));
      return;
    }

    // 2. Capture widget
    final Uint8List? image = await _screenshotController.capture(
      delay: const Duration(milliseconds: 10),
    );

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to capture ticket. Please try again."),
      ));
      return;
    }

    // 3. Save to gallery
    try {
      final result = await ImageGallerySaverPlus.saveImage(image);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Ticket saved to gallery!"),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception(result['errorMessage']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to save ticket: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _buildTicketTop(MovieProvider booking, String formattedSeats) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(widget.movie.poster, height: 150, fit: BoxFit.cover),
        ),
        const SizedBox(height: 20),
        Text(
          widget.movie.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoCol("Date", booking.selectedDate ?? "Not Set"),
            _buildInfoCol("Time", booking.selectedTime ?? "Not Set"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoCol("Cinema", booking.selectedTheater ?? "Not Set"),
            _buildInfoCol("Seats", formattedSeats),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketBottom(MovieProvider booking, String formattedSeats) {
    return Column(
      children: [
        BarcodeWidget(
          barcode: Barcode.code128(),
          data: '${widget.movie.imdbID}-${booking.selectedTime}-$formattedSeats',
          width: 250,
          height: 80,
          color: Colors.white,
          drawText: false,
        ),
        const SizedBox(height: 10),
        const Text(
          "SCAN THIS AT ENTRANCE",
          style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}