import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/common_widget/grid/food_grid_item.dart';
import 'package:foodapp/viewmodels/favorite_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class FarvoriteView extends StatefulWidget {
  const FarvoriteView({super.key});

  @override
  State<FarvoriteView> createState() => _FarvoriteViewState();
}

class _FarvoriteViewState extends State<FarvoriteView> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách yêu thích khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteViewModel = context.watch<FavoriteViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Món ăn yêu thích',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        //   leading: IconButton(
        //       onPressed: () => Navigator.pop(context),
        //       icon: const Icon(Icons.arrow_back)),
        //   backgroundColor: Colors.white,
        //   elevation: 0,
        //
      ),
      body: favoriteViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteViewModel.favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: TColor.gray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có món ăn yêu thích',
                        style: TextStyle(
                          fontSize: 16,
                          color: TColor.gray,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteViewModel.favorites.length,
                  itemBuilder: (context, index) {
                    final food = favoriteViewModel.favorites[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FoodListItem(
                        food: food,
                        showButtonAddToCart: false,
                      ),
                    );
                  },
                ),
    );
  }
}
