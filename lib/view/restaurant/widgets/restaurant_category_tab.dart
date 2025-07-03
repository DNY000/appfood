import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/view/restaurant/widgets/food_image_widget.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/common_widget/food_order_controller.dart';
import 'package:foodapp/view/order/order_screen.dart';
import '../../../ultils/fomatter/formatters.dart';
import 'package:foodapp/data/models/category_model.dart';

class RestaurantFoodsScreen extends StatefulWidget {
  final String restaurantId;
  final List<CategoryModel> categories;

  const RestaurantFoodsScreen(
      {Key? key, required this.restaurantId, required this.categories})
      : super(key: key);

  @override
  _RestaurantFoodsScreenState createState() => _RestaurantFoodsScreenState();
}

class _RestaurantFoodsScreenState extends State<RestaurantFoodsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CartViewModel cartViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartViewModel = Provider.of<CartViewModel>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    // Xóa các món ăn của nhà hàng này khỏi giỏ hàng khi vào lại màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cartViewModel.removeItemsByRestaurant(widget.restaurantId);
      }
    });
    Future.microtask(() {
      Provider.of<FoodViewModel>(context, listen: false)
          .fetchFoodsByRestaurant(widget.restaurantId);
    });
    _tabController =
        TabController(length: widget.categories.length, vsync: this);

    if (widget.categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadCategoryFoods(widget.categories[0].id);
        }
      });
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        _loadCategoryFoods(widget.categories[_tabController.index].id);
      }
    });
  }

  void _loadCategoryFoods(String categoryId) {
    try {
      context.read<FoodViewModel>().fetchFoodsByCategoryAndRestaurant(
            widget.restaurantId,
            categoryId,
          );
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    cartViewModel.removeItemsByRestaurant(widget.restaurantId);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Không có danh mục món ăn'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 48, // Chiều cao cố định cho TabBar
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              indicatorWeight: 2,
              tabs: widget.categories.map((category) {
                return Tab(
                  text: category.name.toUpperCase(),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.categories
                  .map((category) => _buildTabContent(category.id))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          final totalAmount =
              cartVM.getTotalAmountByRestaurant(widget.restaurantId);
          final cartItems =
              cartVM.getCartItemsByRestaurant(widget.restaurantId);

          if (cartItems.isEmpty) return const SizedBox.shrink();

          return Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.only(left: 28, right: 28, bottom: 16),
            child: FloatingActionButton.extended(
              backgroundColor: TColor.orange3,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(
                          value: Provider.of<OrderViewModel>(context,
                              listen: false),
                        ),
                        ChangeNotifierProvider.value(
                          value: Provider.of<CartViewModel>(context,
                              listen: false),
                        ),
                      ],
                      child: OrderScreen(
                        cartItems: cartItems,
                        restaurantId: widget.restaurantId,
                        totalAmount: totalAmount,
                      ),
                    ),
                  ),
                );
              },
              label: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "${totalAmount.toStringAsFixed(0)}đ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 64),
                  const Text(
                    "Giao hàng",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabContent(String categoryId) {
    return Consumer<FoodViewModel>(
      builder: (context, foodViewModel, child) {
        if (foodViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (foodViewModel.error?.isNotEmpty ?? false) {
          return Center(child: Text(foodViewModel.error ?? 'Đã xảy ra lỗi'));
        }

        final foods = foodViewModel.categoryFoods[categoryId] ?? [];

        if (foods.isEmpty) {
          return const Center(child: Text("Không có món ăn nào."));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
              child: Text(
                "Danh sách món ăn",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.color3,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  final soldCount = context
                      .read<RestaurantViewModel>()
                      .getFoodSoldCount(food.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleFoodDetail(
                              foodItem: food,
                              restaurantId: widget.restaurantId,
                            ),
                          ));
                    },
                    child: Card(
                      elevation: 0.5,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  FoodImageWidget(imageSource: food.images[0]),
                                  if (soldCount > 0)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "$soldCount đã bán",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      food.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      food.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${TFormatter.formatCurrency(food.price)}đ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: TColor.orange3,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (soldCount > 0)
                                          Text(
                                            "$soldCount đã bán",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          FoodOrderController(
                                  food: food,
                                  restaurantId: widget.restaurantId,
                                  showQuantitySelector: true,
                                ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                          ],
                        ),
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
}
