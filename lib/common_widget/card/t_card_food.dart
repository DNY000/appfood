import 'package:flutter/material.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/fomatter/formatters.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/view/restaurant/widgets/food_image_widget.dart';

class FoodListView extends StatelessWidget {
  final List<FoodModel> foods;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const FoodListView({
    super.key,
    required this.foods,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return  Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fastfood, size: 48, color: TColor.orange3),
            SizedBox(height: 8),
            Text(
              'Không có món ăn nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Danh sách món ăn hiện đang trống',
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        final uniqueHeroTag =
            'food_${food.id}_${DateTime.now().millisecondsSinceEpoch}';

        return RepaintBoundary(
          child: Card(
            color: Colors.white,
            elevation: 0.8,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleFoodDetail(
                      foodItem: food,
                      restaurantId: food.restaurantId,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Hero(
                        tag: uniqueHeroTag,
                        child: (food.images.isNotEmpty)
                            ? FoodImageWidget(
                                imageSource: food.images.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    Icon(Icons.fastfood, color: TColor.orange5),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: TColor.gray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: [
                                   Icon(Icons.star,
                                      color: TColor.orange2, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    (food.rating).toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${TFormatter.formatCurrency(food.price)}đ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.orange3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
