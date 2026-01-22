import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Shimmer getShimmer(Widget child) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[900]!,
    highlightColor: Colors.grey[800]!,
    child: child,
  );
}

class HeroShimmer extends StatelessWidget {
  const HeroShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double heroHeight = screenWidth > 800 ? 600 : 450;
    double sidePadding = screenWidth > 1200 ? 100 : 20;

    return getShimmer(
      SizedBox(
        height: heroHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: screenWidth * 0.6,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(height: 50, width: 120, color: Colors.black),
                  const SizedBox(width: 15),
                  Container(height: 50, width: 120, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCardShimmer extends StatelessWidget {
  final bool isBanner;
  const MovieCardShimmer({super.key, required this.isBanner});

  @override
  Widget build(BuildContext context) {
    return getShimmer(
      Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
