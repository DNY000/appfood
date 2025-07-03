import 'package:flutter/material.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:foodapp/data/repositories/restaurant_repository.dart';
import 'package:foodapp/data/repositories/user_repository.dart';
import 'package:foodapp/viewmodels/banner_viewmodel.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import 'package:foodapp/viewmodels/home_viewmodel.dart';
import 'package:foodapp/view/authentication/viewmodel/signup_viewmodel.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:foodapp/viewmodels/review_viewmodel.dart';
import 'package:foodapp/viewmodels/favorite_viewmodel.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:foodapp/viewmodels/notification_viewmodel.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodViewModel(FoodRepository())),
        ChangeNotifierProvider(create: (_) => RestaurantViewModel(RestaurantRepository())),
        ChangeNotifierProvider( create: (_) => OrderViewModel(OrderRepository(), foodRepository: FoodRepository())),
        ChangeNotifierProvider(create: (_) => UserViewModel(UserRepository())),
        ChangeNotifierProvider(create: (_) => BannerViewmodel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (context) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: child,
    );
  }
}
