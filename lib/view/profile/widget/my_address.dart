import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/appbar/t_appbar.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/view/profile/widget/add_address_view.dart';

class MyAddressView extends StatefulWidget {
  const MyAddressView({Key? key}) : super(key: key);

  @override
  State<MyAddressView> createState() => _MyAddressViewState();
}

class _MyAddressViewState extends State<MyAddressView> {
  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final currentUser = userViewModel.currentUser;

    return Scaffold(
      appBar: TAppBar(
        title: const Text('Địa chỉ của tôi'),
        showBackArrow: true,
      ),
      backgroundColor: Colors.white,
      body: currentUser == null || currentUser.addresses.isEmpty ||(currentUser.defaultAddress?.street ?? '').isEmpty
          ? Center(
              child: Text(
                'Bạn chưa có địa chỉ nào. Hãy thêm địa chỉ mới!',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: currentUser.addresses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final addr = currentUser.addresses[index];
                return ListTile(
                  leading: Icon(
                    addr.isDefault ? Icons.check_circle : Icons.location_on,
                    color: addr.isDefault ? Colors.green : Colors.grey,
                  ),
                  title: Text(addr.street),
                  trailing: addr.isDefault
                      ? const Text('Mặc định',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold))
                      : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_address_fab_profile',
        backgroundColor: TColor.color3,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt, size: 18),
        label: const Text('Thêm địa chỉ mới', style: TextStyle(fontSize: 13)),
        onPressed: () async {
          final newAddress = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAddressView(),
            ),
          );
          if (newAddress != null) {
            await context.read<UserViewModel>().updateUserAddress(newAddress);
            if (mounted) {
              context.read<UserViewModel>().loadCurrentUser();
              setState(() {});
            }
          }
        },
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        extendedIconLabelSpacing: 6,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
