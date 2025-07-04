import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodapp/data/models/restaurant_model.dart';
import 'package:foodapp/view/restaurant/review_user.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/view/restaurant/widgets/food_image_widget.dart';
import 'package:foodapp/view/restaurant/widgets/restaurant_category_tab.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import '../../ultils/fomatter/formatters.dart';
import 'package:foodapp/data/models/category_model.dart';

import '../../ultils/const/color_extension.dart';

class RestaurantDetailView extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailView({super.key, required this.restaurant});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  @override
  void initState() {
    super.initState();
    _initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RestaurantViewModel>().updateUserLocation();
      }
    });
  }
  void _saveDraftOrderIfNeeded() {
  final cartVM = Provider.of<CartViewModel>(context, listen: false);
  final items = cartVM.getCartItemsByRestaurant(widget.restaurant.id);

  if (items.isNotEmpty) {
    final total = cartVM.getTotalAmountByRestaurant(widget.restaurant.id);

    // final draftOrder = DraftOrderModel(
    //   id: DateTime.now().toString(),
    //   restaurantId: widget.restaurant.id,
    //   items: List<CartItemModel>.from(items),
    //   totalAmount: total,
    //   createdAt: DateTime.now(),
    // );

    // final storage = TLocalStorage.instance();
    // final draftOrdersJson = storage.readData<String>('draft_orders') ?? '[]';
    // final List<dynamic> draftOrdersList = json.decode(draftOrdersJson);
    // final draftOrders = draftOrdersList
    //     .map((json) => DraftOrderModel.fromJson(json))
    //     .toList();

    // draftOrders.add(draftOrder);

    // storage.saveData(
    //   'draft_orders',
    //   json.encode(draftOrders.map((order) => order.toJson()).toList()),
    // );

    cartVM.removeItemsByRestaurant(widget.restaurant.id);
  }
}

@override
void dispose() {
_saveDraftOrderIfNeeded();
  super.dispose();
}
  Future<void> _initializeData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<RestaurantViewModel>()
              .fetchPopularFoods(widget.restaurant.id);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildPopularFoods() {
    return Consumer<RestaurantViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.error != null && viewModel.error!.isNotEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Error: ${viewModel.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (viewModel.popularFoods.isEmpty) {
          return const Padding(
              padding: EdgeInsets.only(top: 20), child: SizedBox.shrink());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Món ăn phổ biến',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220, // Tăng chiều cao để chứa thêm thông tin
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: viewModel.popularFoods.length,
                itemBuilder: (context, index) {
                  final foodData = viewModel.popularFoods[index];
                  final food = foodData;
                  final soldQuantity = foodData.soldCount;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleFoodDetail(
                                    foodItem: food,
                                    restaurantId: food.restaurantId,
                                  )));
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              food.images.first,
                              width: 160,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.fastfood,
                                      size: 60, color: Colors.orange),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${TFormatter.formatCurrency(food.price)}đ',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Đã bán: $soldQuantity',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: media.width * 0.4,
            floating: false,
            pinned: true,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              background: FoodImageWidget(
                imageSource: widget.restaurant.mainImage,
                fit: BoxFit.cover,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 0,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    widget.restaurant.name,
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewUser(
                                  foodId: widget.restaurant.id,
                                  restaurantId: widget.restaurant.id,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              RatingBar.builder(
                                initialRating: widget.restaurant.rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                ignoreGestures: true,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: TColor.orange3,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.restaurant.rating.toString(),
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: TColor.gray,
                      ),
                      Expanded(
                        child: Consumer<RestaurantViewModel>(
                          builder: (context, viewModel, child) {
                            if (viewModel.userLocation == null) {
                              return const Text('Đang lấy vị trí...');
                            }
                            final distance =
                                viewModel.calculateDistanceToRestaurant(
                                    widget.restaurant);
                            return Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: TColor.orange3,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    viewModel.formatDistance(distance),
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPopularFoods(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Consumer<CategoryViewModel>(
                    builder: (context, categoryVM, child) {
                      final categoryModels = widget.restaurant.categories
                          .map((id) => categoryVM.categories.firstWhere(
                                (cat) => cat.id == id,
                                orElse: () =>
                                    CategoryModel(id: id, name: id, image: ''),
                              ))
                          .toList();
                      return RestaurantFoodsScreen(
                        categories: categoryModels,
                        restaurantId: widget.restaurant.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
