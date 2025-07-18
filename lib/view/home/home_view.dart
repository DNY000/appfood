import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/appbar/t_appbar.dart';
import 'package:foodapp/core/location_service.dart';
import 'package:foodapp/services/notifications_service.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/view/home/widgets/list_banner.dart';
import 'package:foodapp/view/home/widgets/list_best_seller_food.dart';
import 'package:foodapp/view/home/widgets/list_category.dart';
import 'package:foodapp/view/home/widgets/list_restaurant_new.dart';
import 'package:foodapp/view/home/widgets/restaurant_tab_view.dart';
import 'package:foodapp/view/notifications/notification_view.dart';
import 'package:foodapp/viewmodels/notification_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import '../../common_widget/button/selection_text_view.dart';
import '../../viewmodels/category_viewmodel.dart';
import 'package:foodapp/viewmodels/home_viewmodel.dart';
import 'package:foodapp/view/search/food_search_view.dart';
import 'package:foodapp/view/home/widgets/list_all_restaurant.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: const _HomeViewContent(),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  const _HomeViewContent({Key? key}) : super(key: key);

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    NotificationsService.initialize(context);
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<UserViewModel>().loadCurrentUser();
        final userId = context.read<UserViewModel>().currentUser?.id;
        if (userId != null && userId.isNotEmpty) {
          await context
              .read<NotificationViewModel>()
              .getUnreadNotificationsCount(userId);
        }
        await Future.wait([
          context.read<FoodViewModel>().loadFoods(),
          context.read<CategoryViewModel>().loadCategories(),
          context.read<RestaurantViewModel>().getNewRestaurants(),
        ]);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });

    _loadCurrentAddress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    // context.read<NotificationViewModel>().removeListener(() {});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCurrentAddress();
    }
  }

  Future<void> _loadCurrentAddress() async {
    try {
      final position = await LocationService.getCurrentLocation(context);
      if (position != null) {
        final address = await LocationService.getAddressFromPosition(position);
        if (mounted) {
          setState(() {
            _currentAddress = address ?? 'Không xác định';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentAddress = 'Không xác định';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Không xác định';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: TColor.bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                child: Column(
                  children: [
                    TAppBar(
                      centerTitle: false,
                      padding: 20,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Selector<UserViewModel, String>(
                            selector: (context, user) =>
                                user.currentUser?.name ?? '',
                            builder: (context, name, child) => Text(
                              'Vị trí',
                              style: TextStyle(
                                color: TColor.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            _currentAddress ?? 'Đang lấy vị trí...',
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      action: [
                        Selector<NotificationViewModel, int>(
                          selector: (p0, p1) => p1.countNotification,
                          builder:
                              (BuildContext context, value, Widget? child) {
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: IconButton(
                                  icon: Badge(
                                    label: Text(
                                      '$value',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      size: 24,
                                      color: TColor.text,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final userId = context
                                        .read<UserViewModel>()
                                        .currentUser
                                        ?.id;
                                    if (userId != null && userId.isNotEmpty) {
                                      await context
                                          .read<NotificationViewModel>()
                                          .getUnreadNotificationsCount(userId);
                                    }

                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const NotificationsView()),
                                      ).then((_) async {
                                        final userId = context
                                            .read<UserViewModel>()
                                            .currentUser
                                            ?.id;
                                        if (userId != null &&
                                            userId.isNotEmpty &&
                                            context.mounted) {
                                          await context
                                              .read<NotificationViewModel>()
                                              .getUnreadNotificationsCount(
                                                  userId);
                                        }
                                      });
                                    }
                                  },
                                ));
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FoodSearchView()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: TColor.gray),
                              const SizedBox(width: 8),
                              Text(
                                'Tìm kiếm món ăn...',
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: ListBanner()),
            const SliverToBoxAdapter(child: ListCategory()),
            const SliverToBoxAdapter(child: ListFoodYouMaybeLike()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SelectionTextView(
                    title: "Khám phá quán mới",
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListAllRestaurant(),
                        ),
                      );
                    },
                  ),
                  const ListRestaurantNew(),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  labelPadding: EdgeInsets.only(top: 4),
                  controller: _tabController,
                  indicatorColor: Colors.orange,
                  labelColor: Colors.orange,
                  unselectedLabelColor: TColor.gray,
                  tabs: const [
                    Tab(
                      child: Column(
                        children: [
                          Icon(Icons.location_on, size: 18),
                          SizedBox(width: 4),
                          Text("Gần tôi", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        children: [
                          Icon(Icons.trending_up, size: 18),
                          SizedBox(width: 4),
                          Text("Bán chạy", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        children: [
                          Icon(Icons.star, size: 18),
                          SizedBox(width: 4),
                          Text("Đánh giá", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: RestaurantTabView(tabController: _tabController),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: child,
    );
  }

  @override
  double get maxExtent => 105;

  @override
  double get minExtent => 105;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
