import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodapp/ultils/fomatter/formatters.dart';
import 'package:foodapp/view/restaurant/restaurant_detail_view.dart';
import 'package:foodapp/view/restaurant/widgets/food_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/image_food.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/data/models/restaurant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/food_model.dart';

class FoodSearchView extends StatefulWidget {
  const FoodSearchView({Key? key}) : super(key: key);

  @override
  State<FoodSearchView> createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends State<FoodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<String> _searchHistory = [];
  final List<Map<String, String>> _suggestions = [
    {"name": "Cơm rang", "image": TImageFood.comrang1},
    {"name": "Cơm rang trứng", "image": TImageFood.comrang2},
    {"name": "Cơm rang dưa bò", "image": TImageFood.comrang3},
    {"name": "Cơm rang hải sản", "image": TImageFood.comrang4},
    {"name": "Cơm rang gà", "image": TImageFood.comrang5},
    {"name": "Mì xào", "image": TImageFood.mi1},
    {"name": "Mì xào bò", "image": TImageFood.mi2},
    {"name": "Mì xào hải sản", "image": TImageFood.mi3},
    {"name": "Mì xào trứng", "image": TImageFood.mi4},
    {"name": "Mì xào gà", "image": TImageFood.mi5},
    {"name": "Bún đậu", "image": TImageFood.bundau1},
    {"name": "Bún đậu mắm tôm", "image": TImageFood.bundau2},
    {"name": "Bún đậu chả cốm", "image": TImageFood.bundau4},
    {"name": "Bún chả", "image": TImageFood.bun1},
    {"name": "Bún bò", "image": TImageFood.bun2},
    {"name": "Bún cá", "image": TImageFood.bun3},
    {"name": "Bún mọc", "image": TImageFood.bun4},
    {"name": "Bún riêu", "image": TImageFood.bun5},
    {"name": "Bún thang", "image": TImageFood.bun6},
    {"name": "Bún ốc", "image": TImageFood.bun7},
    {"name": "Gà rán", "image": TImageFood.garan1},
    {"name": "Gà rán cay", "image": TImageFood.garan2},
    {"name": "Gà rán phô mai", "image": TImageFood.garan3},
    {"name": "Gà rán sốt", "image": TImageFood.garan4},
    {"name": "Phở bò", "image": TImageFood.phobo1},
    {"name": "Phở bò tái", "image": TImageFood.phobo2},
    {"name": "Phở bò gầu", "image": TImageFood.phobo3},
    {"name": "Phở bò viên", "image": TImageFood.phobo4},
    {"name": "Trà chanh", "image": TImageFood.trachanh},
    {"name": "Trà quất", "image": TImageFood.traquat},
    {"name": "Coca", "image": TImageFood.coca},
    {"name": "Pessi", "image": TImageFood.pessi},
    {"name": "Redbull", "image": TImageFood.redbull},
    {"name": "Sting", "image": TImageFood.sting},
  ];
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final storage = TLocalStorage.instance();
    final history = storage.readData<List<dynamic>>('search_history');
    setState(() {
      _searchHistory = history?.cast<String>() ?? [];
    });
  }

  Future<void> _addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final storage = TLocalStorage.instance();
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 5) {
        _searchHistory = _searchHistory.sublist(0, 5);
      }
      storage.saveData('search_history', _searchHistory);
    });
  }

  Future<void> _removeFromSearchHistory(String query) async {
    final storage = TLocalStorage.instance();
    setState(() {
      _searchHistory.remove(query);
      storage.saveData('search_history', _searchHistory);
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (mounted && query.trim().isNotEmpty) {
        await _addToSearchHistory(query);
        await context.read<FoodViewModel>().searchFoods(query);
        setState(() {
          _showResult = true;
        });
      } else {
        setState(() {
          _showResult = false;
        });
      }
    });
    setState(() {
      if (query.trim().isEmpty) {
        _showResult = false;
      }
    });
  }

  void _onSubmitted(String query) {
    _addToSearchHistory(query);
    context.read<FoodViewModel>().searchFoods(query);
    setState(() {
      _showResult = true;
    });
  }

  void _onBackFromResult() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onSubmitted: _onSubmitted,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm món ăn...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: TColor.gray),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<FoodViewModel>().clearSearchResults();
                setState(() {
                  _showResult = false;
                });
              },
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            if (_showResult) {
              _onBackFromResult();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Consumer2<FoodViewModel, RestaurantViewModel>(
        builder: (context, foodVM, restaurantVM, child) {
          if (foodVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (foodVM.error?.isNotEmpty == true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: TColor.color3),
                  const SizedBox(height: 16),
                  Text(
                    foodVM.error!,
                    style: TextStyle(color: TColor.text),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final searchResults = foodVM.searchResults;
          final query = _searchController.text.trim();

          if (_showResult) {
            // Group các món ăn theo quán
            final Map<String, List<FoodModel>> foodsByRestaurant = {};
            for (final food in searchResults) {
              foodsByRestaurant
                  .putIfAbsent(food.restaurantId, () => <FoodModel>[])
                  .add(food);
            }
            // Lấy danh sách quán từ restaurantVM.restaurants dựa trên restaurant.token
            final List<RestaurantModel> displayRestaurants = restaurantVM
                .restaurants
                .where((r) => foodsByRestaurant.containsKey(r.token))
                .toList();
            // Nếu không có quán phù hợp, hiển thị danh sách món ăn phù hợp như cũ
            if (displayRestaurants.isEmpty) {
              if (searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Icon(Icons.search_off, size: 48, color: TColor.gray),
                      const SizedBox(height: 16),
                      Text('Không tìm thấy kết quả phù hợp',
                          style: TextStyle(color: TColor.gray, fontSize: 16)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final food = searchResults[index];
                  final restaurant = restaurantVM.restaurants.firstWhere(
                    (r) => r.token == food.restaurantId,
                    orElse: () => RestaurantModel(
                        id: '',
                        name: 'Không rõ quán',
                        description: '',
                        address: '',
                        location: const GeoPoint(0, 0),
                        operatingHours: {},
                        rating: 0,
                        images: {},
                        status: '',
                        minOrderAmount: 0,
                        createdAt: DateTime.now(),
                        categories: [],
                        metadata: {},
                        token: ""),
                  );
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (food.images.isNotEmpty)
                              ? FoodImageWidget(
                                  imageSource: food.images.first,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood,
                                  size: 40, color: Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(food.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 13)),
                              Text(restaurant.name,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Text(
                          '${food.finalPrice.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            // Hiển thị các quán phù hợp, mỗi quán là 1 container lớn, child là các món phù hợp
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...displayRestaurants.map((restaurant) {
                    final foods = foodsByRestaurant[restaurant.token]!;
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailView(
                              restaurant: restaurant,
                            ),
                          )),
                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column 1: Ảnh quán ăn
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: restaurant.mainImage.isNotEmpty
                                        ? FoodImageWidget(
                                            imageSource: restaurant.mainImage,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Column 2: Thông tin quán ăn và các món ăn
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(restaurant.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 16, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text(
                                            restaurant.rating
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...foods.map((food) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: (food.images.isNotEmpty)
                                                    ? FoodImageWidget(
                                                        imageSource:
                                                            food.images.first,
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(food.name,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(food.description,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: TColor.gray,
                                                            fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '${TFormatter.formatCurrency(food.price)}đ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: TColor.color3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }

          // Gợi ý lịch sử dựa trên từ khoá nhập
          final List<String> filteredHistory = query.isEmpty
              ? _searchHistory
              : _searchHistory
                  .where((h) => h.toLowerCase().contains(query.toLowerCase()))
                  .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (filteredHistory.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Lịch sử tìm kiếm',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColor.text,
                            fontSize: 16)),
                  ),
                  ...filteredHistory.map((query) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(query),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeFromSearchHistory(query),
                        ),
                        onTap: () {
                          _searchController.text = query;
                          _onSearchChanged(query);
                          _onSubmitted(query);
                        },
                      )),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Gợi ý tìm kiếm',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColor.text,
                          fontSize: 16)),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () {
                        _searchController.text = suggestion["name"]!;
                        _onSearchChanged(suggestion["name"]!);
                        _onSubmitted(suggestion["name"]!);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  suggestion["image"]!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.fastfood,
                                          size: 32, color: Colors.orange),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                suggestion["name"]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: TColor.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
