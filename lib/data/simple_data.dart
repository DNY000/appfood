import 'package:cloud_firestore/cloud_firestore.dart';

class SampleData {
  static List<Map<String, dynamic>> getCategories() {
    return [
      {
        'id': 'lau',
        'name': 'Lẩu',
        'image': 'assets/img/logo/logo7.jpg',
        'icon': 'hot_tub',
        'description': 'Các món lẩu ngon nóng hổi',
        'isActive': true,
        'sortOrder': 7,
      },
      {
        'id': 'chao',
        'name': 'Cháo',
        'image': 'assets/img/logo/logo8.jpg',
        'icon': 'soup_kitchen',
        'description': 'Món cháo bổ dưỡng, nóng hổi',
        'isActive': true,
        'sortOrder': 8,
      },
      {
        'id': 'banhxeo',
        'name': 'Bánh xèo',
        'image': 'assets/img/logo/logo9.jpg',
        'icon': 'local_dining',
        'description': 'Bánh xèo miền Trung giòn rụm',
        'isActive': true,
        'sortOrder': 9,
      },
      {
        'id': 'che',
        'name': 'Chè',
        'image': 'assets/img/logo/logo10.jpg',
        'icon': 'icecream',
        'description': 'Món chè ngọt thanh, mát lạnh',
        'isActive': true,
        'sortOrder': 10,
      },
    ];
  }

  static List<Map<String, dynamic>> getRestaurants() {
    return [
      // {
      //   'id': '1',
      //   'name': 'Tít Mít Quán -  Bún Cá Ốc',
      //   'description': 'Quán bún cá ốc ngon nổi tiếng Hà Nội',
      //   'address': '39A Triều Khúc, P. Thanh Xuân Nam',
      //   'location': const GeoPoint(20.98626004927923, 105.79808926615186),
      //   'operatingHours': {
      //     'openTime': '06:00',
      //     'closeTime': '22:00',
      //   },
      //   'rating': 4.5,
      //   'images': {
      //     'main': 'assets/img/logo/logo6.jpg',
      //     'gallery': ['assets/img/logo/logo6.jpg'],
      //   },
      //   'status': 'open',
      //   'minOrderAmount': 30000,
      //   'createdAt': Timestamp.now(),
      //   'categories': ['bun', 'pho'],
      //   'metadata': {
      //     'isActive': true,
      //     'isVerified': true,
      //     'lastUpdated': Timestamp.now(),
      //   },
      // },
      // {
      //   'id': '2',
      //   'name': 'Sinry Chicken - Gà Rán & Cơm Trộn Hàn Quốc',
      //   'description': 'Quán gà rán và cơm trộn Hàn Quốc ngon nhất khu vực',
      //   'address': '48 Ngõ 42 Triều Khúc',
      //   'location': const GeoPoint(20.98539794624276, 105.79762799498806),
      //   'operatingHours': {
      //     'openTime': '10:00',
      //     'closeTime': '22:00',
      //   },
      //   'rating': 4.7,
      //   'images': {
      //     'main': 'assets/img/logo/logo7.jpg',
      //     'gallery': ['assets/img/logo/logo7.jpg'],
      //   },
      //   'status': 'open',
      //   'minOrderAmount': 50000,
      //   'createdAt': Timestamp.now(),
      //   'categories': ['garan', 'com'],
      //   'metadata': {
      //     'isActive': true,
      //     'isVerified': true,
      //     'lastUpdated': Timestamp.now(),
      //   },
      // },
      // {
      //   'id': '3',
      //   'name': 'Cô Vinh Quán - Bánh Mì Chảo',
      //   'description': 'Bánh mì chảo ngon nức tiếng khu vực',
      //   'address': '75 Ngõ 66B Triều Khúc',
      //   'location': const GeoPoint(20.982592480664962, 105.79835233731562),
      //   'operatingHours': {
      //     'openTime': '06:00',
      //     'closeTime': '21:00',
      //   },
      //   'rating': 4.6,
      //   'images': {
      //     'main': 'assets/img/logo/logo8.jpg',
      //     'gallery': ['assets/img/logo/logo8.jpg'],
      //   },
      //   'status': 'open',
      //   'minOrderAmount': 25000,
      //   'createdAt': Timestamp.now(),
      //   'categories': ['banhmi', 'com'],
      //   'metadata': {
      //     'isActive': true,
      //     'isVerified': true,
      //     'lastUpdated': Timestamp.now(),
      //   },
      // },
      // {
      //   'id': '4',
      //   'name': 'Cơm Gà Phương Thúy',
      //   'description': 'Cơm gà ngon, phần ăn đầy đặn',
      //   'address': '7N2 Ngõ 58 Triều Khúc, P. Thanh Xuân Nam',
      //   'location': const GeoPoint(20.98418519991842, 105.79913554204764),
      //   'operatingHours': {
      //     'openTime': '10:00',
      //     'closeTime': '21:00',
      //   },
      //   'rating': 4.4,
      //   'images': {
      //     'main': 'assets/img/logo/logo9.jpg',
      //     'gallery': ['assets/img/logo/logo9.jpg'],
      //   },
      //   'status': 'open',
      //   'minOrderAmount': 35000,
      //   'createdAt': Timestamp.now(),
      //   'categories': ['com', 'pho'],
      //   'metadata': {
      //     'isActive': true,
      //     'isVerified': true,
      //     'lastUpdated': Timestamp.now(),
      //   },
      // },
      // {
      //   'id': '5',
      //   'name': 'KTOP Hotdog',
      //   'description': 'Xúc xích Hàn Quốc ngon chuẩn vị',
      //   'address': '21 Triều Khúc, Quận Thanh Xuân, Hà Nội',
      //   'location': const GeoPoint(20.982024098102716, 105.79895552382416),
      //   'operatingHours': {
      //     'openTime': '11:00',
      //     'closeTime': '22:00',
      //   },
      //   'rating': 4.3,
      //   'images': {
      //     'main': 'assets/img/logo/logo10.jpg',
      //     'gallery': ['assets/img/logo/logo10.jpg'],
      //   },
      //   'status': 'open',
      //   'minOrderAmount': 40000,
      //   'createdAt': Timestamp.now(),
      //   'categories': ['mi', 'pho'],
      //   'metadata': {
      //     'isActive': true,
      //     'isVerified': true,
      //     'lastUpdated': Timestamp.now(),
      //   },
      // },
      {
        "id": "6",
        "name": "Vua bún mọc",
        "description": "Tô bún mọc nóng hổi, chất lượng, không gian sạch sẽ",
        "address": "51-53-55 P. Giáp Nhất, Thượng Đình, Thanh Xuân, Hà Nội",
        "location": {"latitude": 21.003645, "longitude": 105.813372},
        "operatingHours": {"openTime": "06:00", "closeTime": "14:00"},
        "rating": 4.1,
        "images": {
          "main": "assets/img/logo/vuabunmoc.jpg",
          "gallery": ["assets/img/logo/vuabunmoc.jpg"]
        },
        "status": "open",
        "minOrderAmount": 30000,
        "createdAt": Timestamp.now(),
        "categories": ["bun"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },
      {
        "id": "7",
        "name": "Bún riêu cá Trường Sa",
        "description":
            "Bún riêu cá chất lượng, giá bình dân, kèm măng và trà đá",
        "address": "61 Nguyễn Viết Xuân, Khương Mai, Thanh Xuân, Hà Nội",
        "location": {"latitude": 20.999611, "longitude": 105.828197},
        "operatingHours": {"openTime": "06:00", "closeTime": "21:00"},
        "rating": 4.3,
        "images": {
          "main": "assets/img/logo/bunrieuca.jpg",
          "gallery": ["assets/img/logo/bunrieuca.jpg"]
        },
        "status": "open",
        "minOrderAmount": 20000,
        "createdAt": Timestamp.now(),
        "categories": ["bun"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },
      {
        "id": "8",
        "name": "Bánh mì chảo Phú Ông",
        "description": "Bánh mì chảo nóng hổi, sạch sẽ, phục vụ nhiệt tình",
        "address": "Số 47 Nguyễn Quý Đức, Thanh Xuân Bắc, Thanh Xuân, Hà Nội",
        "location": {"latitude": 20.997187, "longitude": 105.799646},
        "operatingHours": {"openTime": "08:00", "closeTime": "22:00"},
        "rating": 4.1,
        "images": {
          "main": "assets/img/logo/phuongbanhmichao.jpg",
          "gallery": ["assets/img/logo/phuongbanhmichao.jpg"]
        },
        "status": "open",
        "minOrderAmount": 50000,
        "createdAt": Timestamp.now(),
        "categories": [
          "banhmi",
        ],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },

      {
        "id": "12",
        "name": "Lẩu Phan Thượng Đình",
        "description": "Buffet bò giá hợp lý, phục vụ nhiệt tình",
        "address": "278 Thượng Đình, Thanh Xuân, Hà Nội",
        "location": {"latitude": 21.002222, "longitude": 105.812433},
        "operatingHours": {"openTime": "10:00", "closeTime": "23:00"},
        "rating": 4.1,
        "images": {
          "main": "assets/img/logo/lauphan.jpg",
          "gallery": ["assets/img/logo/lauphan.jpg"]
        },
        "status": "open",
        "minOrderAmount": 100000,
        "createdAt": Timestamp.now(),
        "categories": [
          "lau",
        ],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },

      {
        "id": "14",
        "name": "Sườn Mười - Sườn nướng BBQ",
        "description": "Sườn nướng, gà bỏ lò, không gian sạch sẽ",
        "address": "264 P. Hoàng Văn Thái, Khương Trung, Thanh Xuân, Hà Nội",
        "location": {"latitude": 20.998118, "longitude": 105.820539},
        "operatingHours": {"openTime": "10:00", "closeTime": "22:00"},
        "rating": 4.4,
        "images": {
          "main": "assets/img/logo/suonmuoi.jpg",
          "gallery": ["assets/img/logo/suonmuoi.jpg"]
        },
        "status": "open",
        "minOrderAmount": 80000,
        "createdAt": Timestamp.now(),
        "categories": ["com"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },
      {
        "id": "15",
        "name": "Nhất Cháo Quán",
        "description": "Cháo đa dạng, sạch sẽ, mở khuya",
        "address": "Ngõ 1 P. Hoàng Đạo Thúy, Nhân Chính, Thanh Xuân, Hà Nội",
        "location": {"latitude": 21.001217, "longitude": 105.805403},
        "operatingHours": {"openTime": "08:00", "closeTime": "23:00"},
        "rating": 4.2,
        "images": {
          "main": "assets/img/logo/nhatchao.jpg",
          "gallery": ["assets/img/logo/nhatchao.jpg"]
        },
        "status": "open",
        "minOrderAmount": 50000,
        "createdAt": Timestamp.now(),
        "categories": ["chao"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },
      {
        "id": "16",
        "name": "Bánh xèo Tư Đông",
        "description": "Bánh xèo miền Trung, giá hợp lý",
        "address": "29 P. Vũ Tông Phan, Khương Trung, Thanh Xuân, Hà Nội",
        "location": {"latitude": 20.996293, "longitude": 105.812969},
        "operatingHours": {"openTime": "10:00", "closeTime": "23:00"},
        "rating": 4.0,
        "images": {
          "main": "assets/img/logo/banhxeo.jpg",
          "gallery": ["assets/img/logo/banhxeo.jpg"]
        },
        "status": "open",
        "minOrderAmount": 20000,
        "createdAt": Timestamp.now(),
        "categories": ["banhxeo"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },
      {
        "id": "17",
        "name": "Chè ngon Vy Vy",
        "description": "Chè đa dạng, ngon, nằm trong ngõ",
        "address": "49 Ng. 69A Hoàng Văn Thái, Khương Mai, Thanh Xuân, Hà Nội",
        "location": {"latitude": 20.995472, "longitude": 105.817089},
        "operatingHours": {"openTime": "08:30", "closeTime": "20:00"},
        "rating": 4.1,
        "images": {
          "main": "assets/img/logo/chevyvy.jpg",
          "gallery": ["assets/img/logo/chevyvy.jpg"]
        },
        "status": "open",
        "minOrderAmount": 15000,
        "createdAt": Timestamp.now(),
        "categories": ["che"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      },

      {
        "id": "19",
        "name": "Chè mít quán",
        "description": "Chè mít truyền thống, thực đơn đa dạng",
        "address":
            "27A, Đường Chính Kinh, Thanh Xuân Trung, Thanh Xuân, Hà Nội",
        "location": {"latitude": 20.998103, "longitude": 105.803182},
        "operatingHours": {"openTime": "09:00", "closeTime": "23:00"},
        "rating": 4.0,
        "images": {
          "main": "assets/img/logo/chemit.jpg",
          "gallery": ["assets/img/logo/chemit.jpg"]
        },
        "status": "open",
        "minOrderAmount": 15000,
        "createdAt": Timestamp.now(),
        "categories": ["che"],
        "metadata": {
          "isActive": true,
          "isVerified": true,
          "lastUpdated": Timestamp.now()
        }
      }
    ];
  }

  static List<Map<String, dynamic>> getFoods() {
    List<Map<String, dynamic>> foods = [];

    // // Món phở
    // final phoList = [
    //   {
    //     'id': 'pho_0001',
    //     'name': 'Phở Bò Tái',
    //     'description': 'Phở bò với thịt bò tái mềm, nước dùng đậm đà',
    //     'price': 45000,
    //     'discountPrice': 40000,
    //     'images': ['assets/img/logo/logo1.jpg'],
    //     'ingredients': ['Bánh phở', 'Thịt bò tái', 'Hành', 'Rau thơm'],
    //     'category': 'pho',
    //     'restaurantId': '1',
    //     'isAvailable': true,
    //     'rating': 4.5,
    //     'soldCount': 100,
    //     'createdAt': Timestamp.now(),
    //   },
    //   {
    //     'id': 'pho_0002',
    //     'name': 'Phở Bò Nạm',
    //     'description': 'Phở với thịt bò nạm mềm, nước dùng đậm đà',
    //     'price': 50000,
    //     'discountPrice': 45000,
    //     'images': ['assets/img/food/phobo2.jpg'],
    //     'ingredients': ['Bánh phở', 'Thịt bò nạm', 'Hành', 'Rau thơm'],
    //     'category': 'pho',
    //     'restaurantId': '2',
    //     'isAvailable': true,
    //     'rating': 4.3,
    //     'soldCount': 80,
    //     'createdAt': Timestamp.now(),
    //   },
    // ];
    // foods.addAll(phoList);

    // // Món cơm
    // final comList = [
    //   {
    //     'id': 'com_0001',
    //     'name': 'Cơm Gà Xối Mỡ',
    //     'description': 'Cơm gà xối mỡ thơm ngon, da giòn rụm',
    //     'price': 45000,
    //     'discountPrice': null,
    //     'images': ['assets/img/food/comga1.jpg'],
    //     'ingredients': ['Cơm', 'Gà', 'Rau sống', 'Nước mắm'],
    //     'category': 'com',
    //     'restaurantId': '9',
    //     'isAvailable': true,
    //     'rating': 4.5,
    //     'soldCount': 150,
    //     'createdAt': Timestamp.now(),
    //   },
    //   {
    //     'id': 'com_0002',
    //     'name': 'Cơm Tấm Sườn',
    //     'description': 'Cơm tấm sườn nướng thơm ngon, kèm bì chả',
    //     'price': 50000,
    //     'discountPrice': null,
    //     'images': ['assets/img/food/comtam1.jpg'],
    //     'ingredients': ['Cơm tấm', 'Sườn nướng', 'Bì', 'Chả'],
    //     'category': 'com',
    //     'restaurantId': '9',
    //     'isAvailable': true,
    //     'rating': 4.7,
    //     'soldCount': 200,
    //     'createdAt': Timestamp.now(),
    //   },
    // ];
    // foods.addAll(comList);

    // // Món bún
    // final bunList = [
    //   {
    //     'id': 'bun_0001',
    //     'name': 'Bún Cá',
    //     'description': 'Bún cá với nước dùng đậm đà, cá tươi ngon',
    //     'price': 45000,
    //     'discountPrice': 40000,
    //     'images': ['assets/img/food/bunca1.jpg'],
    //     'ingredients': ['Bún', 'Cá', 'Rau sống', 'Gia vị'],
    //     'category': 'bun',
    //     'restaurantId': '6',
    //     'isAvailable': true,
    //     'rating': 4.6,
    //     'soldCount': 120,
    //     'createdAt': Timestamp.now(),
    //   },
    //   {
    //     'id': 'bun_0002',
    //     'name': 'Bún Ốc',
    //     'description': 'Bún ốc Hà Nội truyền thống, ốc tươi ngon',
    //     'price': 40000,
    //     'discountPrice': null,
    //     'images': ['assets/img/food/bunoc1.jpg'],
    //     'ingredients': ['Bún', 'Ốc', 'Rau sống', 'Gia vị'],
    //     'category': 'bun',
    //     'restaurantId': '6',
    //     'isAvailable': true,
    //     'rating': 4.4,
    //     'soldCount': 90,
    //     'createdAt': Timestamp.now(),
    //   },
    // ];
    // foods.addAll(bunList);

    // // Món gà rán
    // final gaRanList = [
    //   {
    //     'id': 'garan_0001',
    //     'name': 'Gà Rán Sốt Cay',
    //     'description': 'Gà rán sốt cay Hàn Quốc, giòn rụm',
    //     'price': 65000,
    //     'discountPrice': 55000,
    //     'images': ['assets/img/food/garan1.jpg'],
    //     'ingredients': ['Gà', 'Sốt cay', 'Salad', 'Khoai tây chiên'],
    //     'category': 'garan',
    //     'restaurantId': '7',
    //     'isAvailable': true,
    //     'rating': 4.8,
    //     'soldCount': 300,
    //     'createdAt': Timestamp.now(),
    //   },
    //   {
    //     'id': 'garan_0002',
    //     'name': 'Gà Rán Sốt Phô Mai',
    //     'description': 'Gà rán sốt phô mai béo ngậy',
    //     'price': 70000,
    //     'discountPrice': null,
    //     'images': ['assets/img/food/garan2.jpg'],
    //     'ingredients': ['Gà', 'Sốt phô mai', 'Salad', 'Khoai tây chiên'],
    //     'category': 'garan',
    //     'restaurantId': '7',
    //     'isAvailable': true,
    //     'rating': 4.7,
    //     'soldCount': 250,
    //     'createdAt': Timestamp.now(),
    //   },
    // ];
    // foods.addAll(gaRanList);

    // // Bánh mì
    // final banhMiList = [
    //   {
    //     'id': 'banhmi_0001',
    //     'name': 'Bánh Mì Chảo',
    //     'description': 'Bánh mì chảo nóng hổi, đầy đặn nhân',
    //     'price': 35000,
    //     'discountPrice': 30000,
    //     'images': ['assets/img/food/banhmi1.jpg'],
    //     'ingredients': ['Bánh mì', 'Thịt bò', 'Trứng', 'Rau sống'],
    //     'category': 'banhmi',
    //     'restaurantId': '8',
    //     'isAvailable': true,
    //     'rating': 4.6,
    //     'soldCount': 180,
    //     'createdAt': Timestamp.now(),
    //   },
    //   {
    //     'id': 'banhmi_0002',
    //     'name': 'Bánh Mì Thịt Nướng',
    //     'description': 'Bánh mì thịt nướng thơm ngon',
    //     'price': 25000,
    //     'discountPrice': null,
    //     'images': ['assets/img/food/banhmi2.jpg'],
    //     'ingredients': ['Bánh mì', 'Thịt nướng', 'Rau sống', 'Gia vị'],
    //     'category': 'banhmi',
    //     'restaurantId': '8',
    //     'isAvailable': true,
    //     'rating': 4.5,
    //     'soldCount': 150,
    //     'createdAt': Timestamp.now(),
    //   },
    // ];
    // foods.addAll(banhMiList);
    final allFoodList = [
      {
        'id': 'bun_00010',
        'name': 'Bún Cá',
        'description': 'Bún cá với nước dùng đậm đà, cá tươi ngon',
        'price': 45000,
        'discountPrice': 40000,
        'images': ['assets/img/food/bunca1.jpg'],
        'ingredients': ['Bún', 'Cá', 'Rau sống', 'Gia vị'],
        'category': 'bun',
        'restaurantId': '6',
        'isAvailable': true,
        'rating': 4.6,
        'soldCount': 120,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'bun_00021',
        'name': 'Bún Mọc Thập Cẩm',
        'description': 'Bún mọc thập cẩm với đầy đủ giò, mọc, nấm',
        'price': 50000,
        'discountPrice': null,
        'images': ['assets/img/food/bunmoc1.jpg'],
        'ingredients': ['Bún', 'Mọc', 'Giò', 'Nấm hương'],
        'category': 'bun',
        'restaurantId': '6',
        'isAvailable': true,
        'rating': 4.5,
        'soldCount': 90,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'bun_00031',
        'name': 'Bún Riêu Cá',
        'description': 'Bún riêu cá đậm vị, ăn kèm măng và rau sống',
        'price': 45000,
        'discountPrice': 40000,
        'images': ['assets/img/food/bunrieuca.jpg'],
        'ingredients': ['Bún', 'Cá', 'Măng', 'Rau sống'],
        'category': 'bun',
        'restaurantId': '7',
        'isAvailable': true,
        'rating': 4.6,
        'soldCount': 80,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'bun_00041',
        'name': 'Bún Thập Cẩm',
        'description': 'Bún riêu thập cẩm đặc biệt, topping phong phú',
        'price': 50000,
        'discountPrice': null,
        'images': ['assets/img/food/bunthapcam.jpg'],
        'ingredients': ['Bún', 'Riêu cua', 'Chả', 'Cá'],
        'category': 'bun',
        'restaurantId': '7',
        'isAvailable': true,
        'rating': 4.5,
        'soldCount': 95,
        'createdAt': Timestamp.now(),
      },

      // Bánh mì - restaurantId: 8
      {
        'id': 'banhmi_00011',
        'name': 'Bánh Mì Chảo Bò Trứng',
        'description': 'Bánh mì chảo với bò, trứng và pate thơm ngon',
        'price': 60000,
        'discountPrice': null,
        'images': ['assets/img/food/banhmichao1.jpg'],
        'ingredients': ['Bánh mì', 'Trứng', 'Bò', 'Pate'],
        'category': 'banhmi',
        'restaurantId': '8',
        'isAvailable': true,
        'rating': 4.4,
        'soldCount': 100,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'banhmi_00021',
        'name': 'Bánh Mì Sốt Vang',
        'description': 'Bánh mì kèm sốt vang bò đậm đà hấp dẫn',
        'price': 55000,
        'discountPrice': null,
        'images': ['assets/img/food/banhmichao2.jpg'],
        'ingredients': ['Bánh mì', 'Sốt vang', 'Bò', 'Rau thơm'],
        'category': 'banhmi',
        'restaurantId': '8',
        'isAvailable': true,
        'rating': 4.3,
        'soldCount': 90,
        'createdAt': Timestamp.now(),
      },

      // Lẩu - restaurantId: 12
      {
        'id': 'lau_00011',
        'name': 'Lẩu Bò Ba Chỉ',
        'description': 'Lẩu bò ba chỉ thỏa thích ăn cùng rau tươi',
        'price': 120000,
        'discountPrice': null,
        'images': ['assets/img/food/laubachi.jpg'],
        'ingredients': ['Bò', 'Rau', 'Nấm', 'Mì'],
        'category': 'lau',
        'restaurantId': '12',
        'isAvailable': true,
        'rating': 4.3,
        'soldCount': 70,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'lau_00021',
        'name': 'Lẩu Chả Bò Đậu Hũ',
        'description': 'Nồi lẩu ngon với chả bò, đậu hũ và nước lẩu đậm đà',
        'price': 110000,
        'discountPrice': null,
        'images': ['assets/img/food/lauchabo.jpg'],
        'ingredients': ['Chả bò', 'Đậu hũ', 'Nước lẩu'],
        'category': 'lau',
        'restaurantId': '12',
        'isAvailable': true,
        'rating': 4.2,
        'soldCount': 60,
        'createdAt': Timestamp.now(),
      },

      // Cơm - restaurantId: 14
      {
        'id': 'com_00011',
        'name': 'Cơm Gà Xối Mỡ',
        'description': 'Cơm gà xối mỡ thơm ngon, da giòn rụm',
        'price': 45000,
        'discountPrice': null,
        'images': ['assets/img/food/comga1.jpg'],
        'ingredients': ['Cơm', 'Gà', 'Rau sống', 'Nước mắm'],
        'category': 'com',
        'restaurantId': '14',
        'isAvailable': true,
        'rating': 4.5,
        'soldCount': 150,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'com_00021',
        'name': 'Cơm Sườn Nướng BBQ',
        'description': 'Sườn nướng BBQ thơm lừng, ăn kèm cơm trắng',
        'price': 65000,
        'discountPrice': null,
        'images': ['assets/img/food/comsuonbbq.jpg'],
        'ingredients': ['Cơm', 'Sườn nướng', 'Dưa leo', 'Nước sốt'],
        'category': 'com',
        'restaurantId': '14',
        'isAvailable': true,
        'rating': 4.6,
        'soldCount': 130,
        'createdAt': Timestamp.now(),
      },

      // Cháo - restaurantId: 15
      {
        'id': 'chao_0001',
        'name': 'Cháo Sườn Non',
        'description': 'Cháo sườn mềm thơm, ăn kèm quẩy',
        'price': 40000,
        'discountPrice': null,
        'images': ['assets/img/food/chaosuon.jpg'],
        'ingredients': ['Gạo', 'Sườn non', 'Hành lá', 'Tiêu'],
        'category': 'chao',
        'restaurantId': '15',
        'isAvailable': true,
        'rating': 4.3,
        'soldCount': 110,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'chao_0002',
        'name': 'Cháo Bò Bằm',
        'description': 'Cháo thịt bò bằm cho bữa khuya nhẹ bụng',
        'price': 45000,
        'discountPrice': null,
        'images': ['assets/img/food/chaobo.jpg'],
        'ingredients': ['Gạo', 'Thịt bò', 'Gia vị'],
        'category': 'chao',
        'restaurantId': '15',
        'isAvailable': true,
        'rating': 4.2,
        'soldCount': 80,
        'createdAt': Timestamp.now(),
      },

      // Bánh xèo - restaurantId: 16
      {
        'id': 'banhxeo_0001',
        'name': 'Bánh Xèo Tôm Thịt',
        'description': 'Bánh xèo tôm thịt giòn rụm, nước mắm chua ngọt',
        'price': 40000,
        'discountPrice': null,
        'images': ['assets/img/food/banhxeo1.jpg'],
        'ingredients': ['Bột gạo', 'Tôm', 'Thịt', 'Rau sống'],
        'category': 'banhxeo',
        'restaurantId': '16',
        'isAvailable': true,
        'rating': 4.3,
        'soldCount': 85,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'banhxeo_0002',
        'name': 'Nem Lụi Huế',
        'description': 'Nem lụi nướng ăn kèm bánh tráng cuốn rau thơm',
        'price': 35000,
        'discountPrice': null,
        'images': ['assets/img/food/nemlui.jpg'],
        'ingredients': ['Thịt heo', 'Sả', 'Bánh tráng', 'Rau sống'],
        'category': 'banhxeo',
        'restaurantId': '16',
        'isAvailable': true,
        'rating': 4.2,
        'soldCount': 75,
        'createdAt': Timestamp.now(),
      },

      // Chè - restaurantId: 17, 19
      {
        'id': 'che_0001',
        'name': 'Chè Khúc Bạch',
        'description': 'Chè khúc bạch thơm ngon mát lạnh, topping đa dạng',
        'price': 25000,
        'discountPrice': null,
        'images': ['assets/img/food/chekhucbach.jpg'],
        'ingredients': ['Khúc bạch', 'Nhãn', 'Sữa', 'Hạnh nhân'],
        'category': 'che',
        'restaurantId': '17',
        'isAvailable': true,
        'rating': 4.2,
        'soldCount': 130,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'che_0002',
        'name': 'Chè Dừa Caramen',
        'description': 'Chè caramen dừa thơm béo, topping đầy đủ',
        'price': 30000,
        'discountPrice': null,
        'images': ['assets/img/food/checaramen.jpg'],
        'ingredients': ['Dừa', 'Caramen', 'Sữa', 'Thạch'],
        'category': 'che',
        'restaurantId': '17',
        'isAvailable': true,
        'rating': 4.3,
        'soldCount': 100,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'che_0003',
        'name': 'Chè Mít Truyền Thống',
        'description': 'Chè mít thơm ngon, hương vị tuổi thơ',
        'price': 25000,
        'discountPrice': null,
        'images': ['assets/img/food/chemit.jpg'],
        'ingredients': ['Mít', 'Dừa', 'Thạch', 'Sữa'],
        'category': 'che',
        'restaurantId': '19',
        'isAvailable': true,
        'rating': 4.0,
        'soldCount': 90,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'che_0004',
        'name': 'Chè Sầu Riêng',
        'description': 'Chè sầu thơm béo, đặc sản miền Nam',
        'price': 30000,
        'discountPrice': null,
        'images': ['assets/img/food/chesaurieng.jpg'],
        'ingredients': ['Sầu riêng', 'Dừa', 'Thạch', 'Sữa'],
        'category': 'che',
        'restaurantId': '19',
        'isAvailable': true,
        'rating': 4.1,
        'soldCount': 80,
        'createdAt': Timestamp.now(),
      },
    ];
    foods.addAll(allFoodList);
    return foods;
  }

  static List<Map<String, dynamic>> getUsers() {
    return [
      {
        'id': 'user_0001',
        'profile': {
          'name': 'Nguyễn Văn A',
          'email': 'nguyenvana@gmail.com',
          'phoneNumber': '0901234567',
          'avatarUrl': 'assets/images/avatar1.jpg',
          'birthday': Timestamp.fromDate(DateTime(1990, 1, 1)),
          'gender': 'male'
        },
        'contact': {
          'addresses': [
            {
              'id': 'address_0001',
              'name': 'Nhà',
              'address': '123 Nguyễn Văn Cừ',
              'district': 'Quận 5',
              'city': 'TP.HCM',
              'phoneNumber': '0901234567',
              'location': const GeoPoint(10.762622, 106.660172),
              'note': 'Gần trường đại học',
              'isDefault': true
            },
            {
              'id': '2',
              'name': 'Công ty',
              'address': '456 Lê Văn Việt',
              'district': 'Quận 9',
              'city': 'TP.HCM',
              'phoneNumber': '0901234567',
              'location': const GeoPoint(10.841394, 106.790347),
              'note': 'Tòa nhà ABC, tầng 5',
              'isDefault': false
            }
          ],
          'emergencyContact': {
            'name': 'Nguyễn Thị B',
            'phoneNumber': '0909876543',
            'relationship': 'Vợ'
          }
        },
        'preferences': {
          'language': 'vi',
          'notificationSettings': {
            'orderUpdates': true,
            'promotions': true,
            'marketing': false
          },
          'favoriteRestaurants': ['6', '7'],
          'favoriteFoods': ['bun1', 'garan1'],
          'recentOrders': ['order1', 'order2']
        },
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastLogin': Timestamp.now(),
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 30)))
        }
      },
      {
        'id': 'user2',
        'profile': {
          'name': 'Trần Thị B',
          'email': 'tranthib@gmail.com',
          'phoneNumber': '0909876543',
          'avatarUrl': 'assets/images/avatar2.jpg',
          'birthday': Timestamp.fromDate(DateTime(1992, 5, 15)),
          'gender': 'female'
        },
        'contact': {
          'addresses': [
            {
              'id': '3',
              'name': 'Nhà trọ',
              'address': '789 Lý Thường Kiệt',
              'district': 'Quận 10',
              'city': 'TP.HCM',
              'phoneNumber': '0909876543',
              'location': const GeoPoint(10.770912, 106.666039),
              'note': 'Gần chợ',
              'isDefault': true
            }
          ],
          'emergencyContact': {
            'name': 'Trần Văn C',
            'phoneNumber': '0901112222',
            'relationship': 'Anh trai'
          }
        },
        'preferences': {
          'language': 'vi',
          'notificationSettings': {
            'orderUpdates': true,
            'promotions': true,
            'marketing': true
          },
          'favoriteRestaurants': ['8', '9'],
          'favoriteFoods': ['banhmi1', 'com1'],
          'recentOrders': []
        },
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastLogin': Timestamp.now(),
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 15)))
        }
      }
    ];
  }

  static List<Map<String, dynamic>> getShippers() {
    return [
      {
        'id': 'shipper1',
        'profile': {
          'name': 'Trần Văn B',
          'phoneNumber': '0909876543',
          'email': 'tranvanb@gmail.com',
          'avatarUrl': 'assets/images/avatar_shipper1.jpg',
          'identityCard': '123456789',
          'identityCardImage': 'assets/images/id_shipper1.jpg',
          'vehicleInfo': {
            'type': 'motorcycle',
            'number': '59P1-23456',
            'image': 'assets/images/vehicle_shipper1.jpg'
          }
        },
        'status': 'active',
        'location': const GeoPoint(10.762622, 106.660172),
        'rating': 4.8,
        'totalDeliveries': 150,
        'currentOrderId': 'order1',
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now()
        }
      },
      {
        'id': 'shipper2',
        'profile': {
          'name': 'Nguyễn Thị D',
          'phoneNumber': '0901112222',
          'email': 'nguyenthid@gmail.com',
          'avatarUrl': 'assets/images/avatar_shipper2.jpg',
          'identityCard': '987654321',
          'identityCardImage': 'assets/images/id_shipper2.jpg',
          'vehicleInfo': {
            'type': 'motorcycle',
            'number': '59P1-78901',
            'image': 'assets/images/vehicle_shipper2.jpg'
          }
        },
        'status': 'active',
        'location': const GeoPoint(10.776543, 106.654321),
        'rating': 4.5,
        'totalDeliveries': 80,
        'currentOrderId': null,
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now()
        }
      }
    ];
  }

  // Tạo Timestamp từ DateTime với offset ngày
  static Timestamp getTimestampWithDayOffset(int days) {
    final now = DateTime.now();
    return Timestamp.fromDate(now.add(Duration(days: days)));
  }
}
