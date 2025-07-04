import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/cart_order/add_cart_button.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/view/restaurant/widgets/food_image_widget.dart';
import '../../data/models/food_model.dart';
import '../../ultils/fomatter/formatters.dart';

class FoodGridItem extends StatelessWidget {
  final FoodModel food;
  final bool showButtonAddToCart;
  const FoodGridItem({
    super.key,
    required this.food,
    this.showButtonAddToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,

      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: FoodImageWidget(
                  imageSource: food,
                  width: double.infinity,
                  height: 90,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const SizedBox(width: 4),
                          Text(
                            '${TFormatter.formatCurrency(food.price)}đ',
                            style: TextStyle(
                              fontSize: 12,
                              color: (food.discountPrice ?? 0) > 0
                                  ? Colors.grey
                                  : Colors.orange,
                              decoration: (food.discountPrice ?? 0) > 0
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          if ((food.discountPrice ?? 0) > 0) ...[
                            const SizedBox(width: 4,),
                            Text(
                              '${TFormatter.formatCurrency(food.discountPrice ?? 0)}đ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ]),
                        if (showButtonAddToCart)
                          AddCartButton(
                            onPressed: () {},
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Discount badge
          if ((food.discountPrice ?? 0) > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-${_calculateDiscountPercentage(food.price, food.discountPrice ?? 0)}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _calculateDiscountPercentage(double originalPrice, double discountPrice) {
    if (originalPrice <= 0) return 0;
    final percentage = ((originalPrice - discountPrice) / originalPrice) * 100;
    return percentage.isFinite ? percentage.round() : 0;
  }
}

class FoodListItem extends StatelessWidget {
  final FoodModel food;
  final bool showButtonAddToCart;
  const FoodListItem({
    Key? key,
    required this.food,
    this.showButtonAddToCart = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleFoodDetail(
              foodItem: food,
              restaurantId: food.restaurantId,
            ),
          )),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FoodImageWidget(
                  imageSource: food,
                  width: 100,
                  height: 90,
                  fit: BoxFit.cover,
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
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.description,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          TFormatter.formatCurrency(food.price) + 'đ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if ((food.discountPrice ?? 0) > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            TFormatter.formatCurrency(food.discountPrice ?? 0) +
                                'đ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (showButtonAddToCart)
                AddCartButton(
                  onPressed: () {},
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
