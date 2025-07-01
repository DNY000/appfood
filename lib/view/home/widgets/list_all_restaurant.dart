import 'package:flutter/material.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/common_widget/grid/restaurant_grid_item.dart';
import 'package:foodapp/view/restaurant/restaurant_detail_view.dart';

class ListAllRestaurant extends StatelessWidget {
  const ListAllRestaurant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Danh sách quán ăn",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Consumer<RestaurantViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.restaurants.isEmpty) {
            return const Center(child: Text('Không có quán ăn nào.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: viewModel.restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = viewModel.restaurants[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RestaurantDetailView(restaurant: restaurant),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: restaurant.mainImage.isNotEmpty
                            ? Image.asset(
                                restaurant.mainImage,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: double.infinity,
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.restaurant,
                                      size: 40, color: Colors.orange),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(Icons.restaurant,
                                    size: 40, color: Colors.orange),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      color: Colors.orange, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurant.address,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
