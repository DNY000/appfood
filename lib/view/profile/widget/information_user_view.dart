import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodapp/common_widget/appbar/t_appbar.dart';
import 'package:foodapp/common_widget/t_refresh_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/view/profile/widget/edit_user_view.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class InformationUserView extends StatefulWidget {
  const InformationUserView({super.key});

  @override
  State<InformationUserView> createState() => _InformationUserViewState();
}

class _InformationUserViewState extends State<InformationUserView> {
  File? _avatarImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Load user data when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>  context.read<UserViewModel>().loadCurrentUser(),);
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TAppBar(
      title: Text(
          'Thông tin tài khoản',
          style: TextStyle(
            color: TColor.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
         action: [
          IconButton(
            icon: Icon(Icons.edit, color: TColor.orange3),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditUserView(),
                ),
              );
              if (mounted) {
                context.read<UserViewModel>().loadCurrentUser();
              }
            },
          ),
        ],
        showBackArrow: true,
      ),
      
      
      body: Consumer<UserViewModel>(
        builder: (context, userVM, child) {
          if (userVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userVM.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(userVM.error!),
                  ElevatedButton(
                    onPressed: () => userVM.loadCurrentUser(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final user = userVM.currentUser;
          if (user == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin người dùng'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
               await context.read<UserViewModel>().loadCurrentUser();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: MediaQuery.of(context).padding.copyWith(
                        bottom: 0,
                      ),
                ),
                child: Column(
                  children: [
                    // Header profile section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  child: _isUploading
                                      ? const CircularProgressIndicator()
                                      : _avatarImage != null
                                          ? ClipOval(
                                              child: Image.file(
                                                _avatarImage!,
                                                width: 96,
                                                height: 96,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : (user.avatarUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    user.avatarUrl,
                                                    width: 96,
                                                    height: 96,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  width: 96,
                                                  height: 96,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        TColor.orange3,
                                                        TColor.color1
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      user.name.isNotEmpty
                                                          ? user.name[0]
                                                              .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                        fontSize: 36,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (context) => SafeArea(
                                        child: SizedBox(
                                          height: 200,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.photo_library,
                                                    color: TColor.orange3),
                                                title: const Text(
                                                    'Chọn từ thư viện'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _pickImage(ImageSource.gallery);
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.camera_alt,
                                                    color: TColor.orange3),
                                                title: const Text('Chụp ảnh'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _pickImage(ImageSource.camera);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: TColor.orange3,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 20),
            
                    // Personal info section
                    _buildSectionContainer(
                      title: 'Thông tin cá nhân',
                      icon: CupertinoIcons.person_fill,
                      // ignore: deprecated_member_use
                      iconColor: Colors.black.withOpacity(0.2),
                      content: Column(
                        children: [
                          _buildInfoRow(
                            icon: CupertinoIcons.person,
                            label: 'Tên hiển thị',
                            value: user.name,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            icon: CupertinoIcons.calendar,
                            label: 'Ngày sinh',
                            value:
                                DateFormat('dd/MM/yyyy').format(user.dateOfBirth),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            icon: CupertinoIcons.phone_fill,
                            label: 'Số điện thoại',
                            value: user.phoneNumber,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            icon:
                                CupertinoIcons.person_crop_circle_badge_checkmark,
                            label: 'Giới tính',
                            value: user.gender,
                          ),
                        ],
                      ),
                    ),
            
                    const SizedBox(height: 20),
            
                    // Contact info section
                    _buildSectionContainer(
                      title: 'Thông tin liên hệ',
                      icon: CupertinoIcons.mail_solid,
                      // ignore: deprecated_member_use
                      iconColor: Colors.black.withOpacity(0.2),
                      content: Column(
                        children: [
                          _buildInfoRow(
                            icon: CupertinoIcons.mail,
                            label: 'Email',
                            value: user.email ?? 'Chưa cập nhật',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            icon: CupertinoIcons.location_solid,
                            label: 'Địa chỉ',
                            value: user.defaultAddress?.street ?? 'Chưa cập nhật',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionContainer(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: TColor.gray,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: TColor.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      await _uploadAvatarToFirebase();
      if (mounted) {
        await context.read<UserViewModel>().loadCurrentUser();
        setState(() {
          _avatarImage = null;
        });
      }
    }
  }

  Future<void> _uploadAvatarToFirebase() async {
    if (_avatarImage == null) return;
    if (!mounted) return;
    setState(() {
      _isUploading = true;
    });
    try {
      final userId = context.read<UserViewModel>().currentUser?.id ?? "default";
      final storageRef =
          FirebaseStorage.instance.ref().child('avatars').child('$userId.jpg');
      await storageRef.putFile(_avatarImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      // Cập nhật đúng trường avatarUrl
      await context.read<UserViewModel>().updateAvatar(userId, downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
        );
        // Load lại user data để cập nhật UI
        await context.read<UserViewModel>().loadCurrentUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải ảnh: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _avatarImage =
              null; // Reset _avatarImage sau khi đã cập nhật thành công
        });
      }
    }
  }
}
