import 'package:flutter/material.dart';

class SeatMap extends StatefulWidget {
  final Function(List<int> selectedSeats) onSeatsChanged;
  const SeatMap({super.key, required this.onSeatsChanged});

  @override
  State<SeatMap> createState() => _SeatMapState();
}

class _SeatMapState extends State<SeatMap> {
  // 0: Available, 1: Selected, 2: Reserved/Gap
  final List<int> _seatStatus = List.generate(80, (index) {
    if (index % 10 == 0 || index % 10 == 9) return 2; // Create aisles
    if (index < 20) return 2; // Front row gap
    return 0;
  });

  final List<int> _selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Screen Indicator
        Container(
          height: 4,
          width: MediaQuery.of(context).size.width * 0.5,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white24,
            boxShadow: [BoxShadow(color: Colors.white12, blurRadius: 10)],
          ),
        ),
        const Text("SCREEN", style: TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 30),

        // Seat Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 80,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            int status = _seatStatus[index];
            if (status == 2) return const SizedBox(); // Empty space for aisles

            bool isSelected = _selectedSeats.contains(index);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSeats.remove(index);
                  } else {
                    _selectedSeats.add(index);
                  }
                });
                widget.onSeatsChanged(_selectedSeats); // Notify parent
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isSelected ? Colors.red : Colors.white24),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
