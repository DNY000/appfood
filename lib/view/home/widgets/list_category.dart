import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/selection_text_view.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/common_widget/grid/grid_view.dart';
import 'package:foodapp/data/models/category_model.dart';
import 'package:foodapp/view/home/widgets/category_gird_view.dart';
import 'package:foodapp/view/home/widgets/list_food_by_category.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import 'package:provider/provider.dart';

class ListCategory extends StatelessWidget {
  const ListCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: SelectionTextView(
              title: "Danh mục món ăn",
              onSeeAllTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListFoodByCategory(
                      category: "",
                    ),
                  )),
            ),
          ),

          // Categories content
          Consumer<CategoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return SizedBox(
                  height: mediaSize.width * 0.25,
                  child: Center(
                    child: CircularProgressIndicator(color: TColor.color3),
                  ),
                );
              }

              if (viewModel.error != null) {
                return Container(
                  height: mediaSize.width * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 35,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Không thể tải danh mục',
                          style: TextStyle(
                              color: TColor.text, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.loadCategories(),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.color3,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (viewModel.categories.isEmpty) {
                return Container(
                  height: mediaSize.width * 0.25,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Chưa có danh mục',
                      style: TextStyle(color: TColor.gray, fontSize: 14),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: mediaSize.width * 0.24,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    return GestureDetector(
                      onTap: () {
                        // Xử lý khi nhấn vào category nếu cần
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(16), // Bo góc ảnh
                              child: Image.network(
                                category.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                filterQuality:
                                    FilterQuality.high, // Làm mượt ảnh
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.category,
                                      color: Colors.orange),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
