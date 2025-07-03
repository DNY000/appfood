import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:foodapp/view/profile/change_password.dart';
import 'package:foodapp/view/profile/widget/information_user_view.dart';
import 'package:foodapp/view/profile/widget/my_address.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import '../../ultils/const/color_extension.dart';
import 'package:foodapp/view/profile/information_app.dart';
import '../../core/data_import_service.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadUserData();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await userViewModel.fetchUser(userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final currentUser = userViewModel.currentUser;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading || userViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    // Header with user info
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.transparent,
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Avatar với viền và bóng
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: Colors.white,
                                child: _buildAvatar(currentUser),
                              ),
                            ),
                            // Tên user
                            Text(
                              currentUser?.name ?? 'User',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Menu sections
                    _buildSection(
                      'Tài khoản',
                      [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Thông tin cá nhân',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InformationUserView(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_reset,
                          title: 'Đổi mật khẩu',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordView(),
                              ),
                            );
                          },
                        ),
                        // _buildMenuItem(
                        //   icon: Icons.payment,
                        //   title: 'Quản lý phương thức thanh toán',
                        //   onTap: () {},
                        // ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSection(
                      'Cài đặt',
                      [
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt chung',
                          onTap: () {},
                        ),
                        // _buildMenuItem(
                        //   icon: Icons.lock_outline,
                        //   title: 'Quyền riêng tư',
                        //   onTap: () {},
                        // ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Địa chỉ ',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyAddressView(),
                              )),
                        ),
                        // _buildMenuItem(
                        //   icon: Icons.lock_outline,
                        //   title: 'resturant ',
                        //   onTap: () => _importRestaurants(context),
                        // ),
                        // _buildMenuItem(
                        //   icon: Icons.lock_outline,
                        //   title: 'food',
                        //   onTap: () => _importFoods(context),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Section giới thiệu app
                    Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InformationAppView(),
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.black54, size: 24),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Giới thiệu ứng dụng',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showLogoutConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.orange3,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.orange.shade700,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Đăng xuất",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _performLogout(context);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.orange3,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    final loginViewModel = context.read<LoginViewModel>();

    try {
      await loginViewModel.logOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng xuất: $e'),
          backgroundColor: TColor.color1,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildAvatar(dynamic currentUser) {
    if (currentUser?.avatarUrl != null && currentUser.avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          currentUser.avatarUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialAvatar(currentUser);
          },
        ),
      );
    }
    return _buildInitialAvatar(currentUser);
  }

  Widget _buildInitialAvatar(dynamic currentUser) {
    final initial = (currentUser?.name?.isNotEmpty == true)
        ? currentUser.name.substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [TColor.orange3, TColor.color1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _importCategories(BuildContext context) async {
    await DataImportService().importCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import categories thành công!')),
    );
  }

  void _importRestaurants(BuildContext context) async {
    await DataImportService().importRestaurants();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import restaurants thành công!')),
    );
  }

  void _importFoods(BuildContext context) async {
    await DataImportService().importFoods();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import foods thành công!')),
    );
  }
}
