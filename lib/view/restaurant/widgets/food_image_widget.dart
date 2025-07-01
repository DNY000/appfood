import 'package:flutter/material.dart';
import 'package:foodapp/data/models/food_model.dart';

class FoodImageWidget extends StatelessWidget {
  final dynamic imageSource; // FoodModel hoặc String
  final double width;
  final double height;
  final BoxFit fit;

  const FoodImageWidget({
    Key? key,
    required this.imageSource,
    this.width = 90,
    this.height = 90,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    if (imageSource is FoodModel) {
      imageUrl = (imageSource as FoodModel).images.isNotEmpty
          ? (imageSource as FoodModel).images[0]
          : 'assets/img/placeholder_food.png';
    } else if (imageSource is String) {
      imageUrl = imageSource as String;
    } else {
      imageUrl = 'assets/img/placeholder_food.png';
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.fastfood, size: 60, color: Colors.orange),
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.fastfood, size: 60, color: Colors.orange),
      );
    }
  }
}
