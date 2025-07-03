import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/data/models/address_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/view/main_tab/main_tab_view.dart';
import 'package:foodapp/view/restaurant/widgets/food_image_widget.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/core/services/payment_service.dart';
import 'package:foodapp/core/services/notifications_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:foodapp/core/services/webview.dart';
import '../../ultils/fomatter/formatters.dart';
import 'package:foodapp/view/profile/widget/add_address_view.dart';

class OrderScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final String restaurantId;
  final double totalAmount;

  const OrderScreen({
    Key? key,
    required this.cartItems,
    required this.restaurantId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneController = TextEditingController();
  late String restaurantName;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.thanhtoankhinhanhang;
  final ScreenshotController _screenshotController = ScreenshotController();
  double totalPay = 0.0;
    bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Test chữ ký VNPay với dữ liệu mẫu
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context
            .read<RestaurantViewModel>()
            .selectRestaurant(widget.restaurantId);
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _placeOrder() async {
    final userViewModel = context.read<UserViewModel>();
    final currentUser = userViewModel.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng')),
      );
      return;
    }

    // Kiểm tra địa chỉ
    String deliveryAddress = _addressController.text;
    if (deliveryAddress.isEmpty) {
      deliveryAddress = currentUser.defaultAddress?.street ?? '';
    }

    if (deliveryAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    // Kiểm tra số điện thoại
    String phoneNumber = _phoneController.text;
    if (phoneNumber.isEmpty) {
      phoneNumber = currentUser.phoneNumber;
    }

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cập nhật số điện thoại')),
      );
      return;
    }

    try {
      final orderViewModel = context.read<OrderViewModel>();
      final restaurant = context.read<RestaurantViewModel>().selectedRestaurant;

      await orderViewModel.createOrder(
          context: context,
          userId: currentUser.id,
          restaurantId: restaurant?.token ?? 'tcsE1rI5uwY0u9J61FYu7x2wtFy1',
          items: widget.cartItems,
          address: deliveryAddress,
          paymentMethod: _selectedPaymentMethod,
          note: _noteController.text,
          currentUser: currentUser,
          restaurantName: restaurant?.name ?? 'Cô Vinh Quán - Bánh Mì Chảo');
      await orderViewModel.loadUserOrders(currentUser.id); // Thêm dòng này
      // Hiển thị thông báo local
      try {
        await NotificationsService.showLocalNotification(
          title: 'Đặt hàng thành công',
          body:
              'Đơn hàng của bạn đã được đặt thành công. Chúng tôi sẽ xử lý đơn hàng của bạn sớm nhất có thể.',
          payload: 'order_success',
        );
      } catch (e) {
        print('Lỗi khi hiển thị thông báo: $e');
      }

      // context.go('/main_tab');
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const MainTabView(),
          ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Lỗi khi đặt hàng: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thất bại: ')),
        );
      }
    }
  }

  Future<void> _showEditAddressBottomSheet(UserModel? user) async {
    if (user == null) return;
    final addresses = List<AddressModel>.from(user.addresses);
    addresses.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn địa chỉ giao hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final addr = addresses[index];
                        return ListTile(
                          leading: Icon(
                            addr.isDefault
                                ? Icons.check_circle
                                : Icons.location_on,
                            color: addr.isDefault ? Colors.green : Colors.grey,
                          ),
                          title: Text(addr.street),
                          onTap: () {
                            setState(() {
                              _addressController.text = addr.street;
                            });
                            Navigator.pop(context);
                          },
                          trailing: addr.isDefault
                              ? const Text('Mặc định',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
              right: 24,
              child: FloatingActionButton.extended(
                tooltip: "Xin choa",
                heroTag: 'add_address_fab',
                backgroundColor: TColor.color3,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_location_alt, size: 18),
                label: const Text('Thêm địa chỉ mới',
                    style: TextStyle(fontSize: 13)),
                onPressed: () async {
                  final newAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAddressView(),
                    ),
                  );
                  if (newAddress != null) {
                    await context
                        .read<UserViewModel>()
                        .updateUserAddress(newAddress);
                    if (mounted) {
                      context.read<UserViewModel>().loadCurrentUser();
                      setState(() {
                        _addressController.text = newAddress.street;
                      });
                    }
                  }
                  Navigator.pop(context);
                },
                extendedPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                extendedIconLabelSpacing: 6,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPhoneBottomSheet(UserModel? user) async {
    if (user == null) return;
    final phoneController = TextEditingController(text: user.phoneNumber);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cập nhật số điện thoại',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    labelStyle: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.phone,
                        color: Colors.black54, size: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    hintStyle: const TextStyle(color: Colors.black38),
                  ),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  cursorColor: Colors.black,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final newPhone = phoneController.text.trim();
                        if (newPhone.isNotEmpty &&
                            newPhone != user.phoneNumber) {
                          final userVM = context.read<UserViewModel>();
                          final updatedUser =
                              user.copyWith(phoneNumber: newPhone);
                          await userVM.updateUser(updatedUser);
                          await userVM.loadCurrentUser();
                          if (mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Cập nhật số điện thoại thành công!')),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.orange5,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _captureFullScreen() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Chụp màn hình thành công!'),
          content: Image.memory(image),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chụp màn hình thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.canPop(context)) {
            return true;
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainTabView()),
            );
            return false;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Xác nhận đơn hàng',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            // actions: [
            //   IconButton(
            //     icon: Icon(Icons.camera_alt),
            //     onPressed: _captureFullScreen,
            //   ),
            // ],
          ),
          body: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 0),
            children: [
              _buildAddressSection(),
              //   _buildDeliveryTimeSection(),
              _buildRestaurantAndFoodSection(),
              _buildPaymentDetailsSection(),
              _buildVoucherAndNoteSection(),
              _buildPaymentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Selector<UserViewModel, UserModel?>(
      selector: (_, vm) => vm.currentUser,
      builder: (context, user, _) {
        final phone = _phoneController.text.isNotEmpty
            ? _phoneController.text
            : (user?.phoneNumber ?? "Chưa có số điện thoại");
        final address = _addressController.text.isNotEmpty
            ? _addressController.text
            : (user?.defaultAddress?.street ??
                "Vui lòng nhập địa chỉ giao hàng");

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address == "Vui lòng nhập địa chỉ giao hàng"
                          ? address
                          : "Địa chỉ: $address",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showEditAddressBottomSheet(user),
                    child: Text('Chỉnh sửa',
                        style: TextStyle(color: TColor.color3)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        phone.isEmpty
                            ? "Vui lòng cập nhật số điện thoại"
                            : '${user?.name} | $phone',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13),
                      ),
                    ),
                    TextButton(
                        onPressed: () => _showEditPhoneBottomSheet(user),
                        child: Text(
                          "Chỉnh sửa",
                          style: TextStyle(color: TColor.orange3),
                        ))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildRestaurantAndFoodSection() {
    final displayedItems = isExpanded
        ? widget.cartItems
        : widget.cartItems.take(3).toList();

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 0),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.store, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FoodMot - Gà Rán, Gà Luộc & Gà Ủ Muối Hoa Tiêu - Kim Mã',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
                padding: EdgeInsets.only(bottom: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = displayedItems[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildFoodImage(item.image),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.foodName,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              '${TFormatter.formatCurrency(item.price)}đ',
                              style: TextStyle(
                                color: TColor.color3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('x${item.quantity}'),
                    ],
                  ),
                );
              },
            ),

            // Nút "Xem thêm"
            if (widget.cartItems.length > 3 && !isExpanded)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = true;
                    });
                  },
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage(String imageUrl) {
    if (imageUrl.startsWith('assets/') ||
        imageUrl.startsWith('file:///assets/')) {
      final assetPath = imageUrl.replaceFirst('file:///', '');
      return Image.asset(
        assetPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    }
  }

  Widget _buildPaymentDetailsSection() {
    double totalFoodPrice = widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    // double deliveryFee = 5000 * 7.3;
    double totalPayment = totalFoodPrice;
    setState(() {
      totalPay = totalPayment;
    });
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chi tiết thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentRow('Tổng giá món (${widget.cartItems.length} món)',
                '${totalFoodPrice.toStringAsFixed(0)}đ'),
            // _buildPaymentRow(
            //     'Phí giao hàng (7.3 km)', '${deliveryFee.toStringAsFixed(0)}đ'),
            const Divider(),
            _buildPaymentRow(
                'Tổng thanh toán', '${totalPayment.toStringAsFixed(0)}đ',
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${TFormatter.formatCurrency(double.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)}đ',
            style: TextStyle(
              color: isTotal ? TColor.color3 : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.black54),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giao ngay',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Tiêu chuẩn - 23:55',
                  style: TextStyle(color: TColor.color3, fontSize: 13)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('Đổi sang hẹn giờ',
                style: TextStyle(color: TColor.color3)),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherAndNoteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _noteController,
        decoration: InputDecoration(
          // labelText: 'Ghi chú ',
          hintText: 'Nhập ghi chú...',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!, // Màu xám nhạt khi focus
              width: 1,
            ),
          ),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
      
        ),
        maxLines: 2,
        cursorColor: TColor.orange3,
        
        onChanged: (value) {
          setState(() {
            _noteController.text = value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<PaymentMethod>(
            activeColor: TColor.orange4,
            value: PaymentMethod.thanhtoankhinhanhang,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            title: const Text('Thanh toán khi nhận'),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.qr,
            activeColor: TColor.orange4,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            title: const Text('Thanh toán VNPay'),
          ),
          const SizedBox(height: 16),
          Consumer<OrderViewModel>(
            builder: (context, orderViewModel, _) {
              return ElevatedButton(
                  onPressed: orderViewModel.isLoading
                      ? null
                      : () async {
                          if (_selectedPaymentMethod ==
                              PaymentMethod.thanhtoankhinhanhang) {
                            await _placeOrder();
                          } else if (_selectedPaymentMethod ==
                              PaymentMethod.qr) {
                            final userViewModel = context.read<UserViewModel>();
                            final currentUser = userViewModel.currentUser;
                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Vui lòng đăng nhập để thanh toán VNPay')),
                              );
                              return;
                            }
                            final paymentUrl = VNPayService.createPaymentUrl(
                              amount: totalPay.toInt(),
                            );
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                  child: CircularProgressIndicator()),
                            );
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            if (mounted) Navigator.of(context).pop();
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => VNPayWebViewScreen(
                                  paymentUrl: paymentUrl,
                                  userId: currentUser.id,
                                  onComplete: (isSuccess, responseCode) async {
                                    if (isSuccess) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                      await _placeOrder();
                                      if (mounted) Navigator.of(context).pop();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Đặt hàng & thanh toán thành công!',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                _getErrorMessage(responseCode),
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            backgroundColor: Colors.red,
                                            duration:
                                                const Duration(seconds: 3),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[200],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: orderViewModel.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Center(
                          child: Text(
                            'Thanh toán - ${TFormatter.formatCurrency(totalPay)}đ',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ));
            },
          ),
          const SizedBox(
            height: 60,
          )
        ],
      ),
    );
  }

  String _getErrorMessage(String? responseCode) {
    switch (responseCode) {
      case '07':
        return 'Trừ tiền thành công. Giao dịch bị nghi ngờ.';
      case '09':
        return 'Thẻ chưa đăng ký InternetBanking.';
      case '10':
        return 'Xác thực thông tin không đúng quá 3 lần.';
      case '11':
        return 'Đã hết hạn chờ thanh toán.';
      case '12':
        return 'Thẻ/Tài khoản bị khóa.';
      case '13':
        return 'Mật khẩu OTP không đúng.';
      case '24':
        return 'Khách hàng hủy giao dịch.';
      case '51':
        return 'Tài khoản không đủ số dư.';
      case '65':
        return 'Tài khoản vượt quá hạn mức giao dịch.';
      default:
        return 'Giao dịch không thành công. Mã lỗi: $responseCode';
    }
  }
}
