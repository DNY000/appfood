import 'package:flutter/material.dart';
import '../../ultils/const/color_extension.dart';

class InformationAppView extends StatelessWidget {
  const InformationAppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giới thiệu ứng dụng'),
        backgroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            '''FoodApp - Đặt món online

FoodApp là ứng dụng giúp bạn đặt món ăn nhanh chóng, tiện lợi và an toàn. Chúng tôi kết nối hàng trăm nhà hàng, quán ăn uy tín, mang đến cho bạn trải nghiệm ẩm thực đa dạng, phong phú ngay trên điện thoại.

- Đặt món dễ dàng chỉ với vài thao tác.
- Theo dõi trạng thái đơn hàng theo thời gian thực.
- Nhiều ưu đãi hấp dẫn, mã giảm giá mỗi ngày.
- Hỗ trợ nhiều phương thức thanh toán an toàn.
- Đội ngũ shipper chuyên nghiệp, giao hàng nhanh chóng.

FoodApp cam kết mang đến cho bạn dịch vụ tốt nhất, món ăn chất lượng và sự hài lòng tuyệt đối.

Cảm ơn bạn đã tin tưởng và sử dụng FoodApp!''',
            style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
          ),
        ),
      ),
    );
  }
}
