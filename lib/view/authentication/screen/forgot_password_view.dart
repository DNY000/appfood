import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final viewModel = Provider.of<LoginViewModel>(context);
    bool isLoading = viewModel.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: TColor.color3,
                      ),
                    ),
                  ),

                  // Icon
                  Icon(
                    Icons.lock_reset_outlined,
                    size: 80,
                    color: TColor.color3,
                  ),
                  SizedBox(height: media.width * 0.05),

                  Text(
                    "Quên mật khẩu",
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: media.width * 0.02),
                  Text(
                    "Vui lòng nhập email của bạn để đặt lại mật khẩu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: media.width * 0.1),
                 TextFormField(
                          controller: viewModel.txtEmail,
                          onChanged: (_) => viewModel.clearError(),
                          keyboardType: TextInputType.emailAddress,
                          validator: viewModel.validateEmail,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true, // Add fill
                            fillColor:
                                Colors.grey.shade200, // Light grey background
                            hintText: "duy000.vn@gmail.com", // Example hint
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600, // Darker grey hint
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Slightly rounded corners
                              borderSide: BorderSide.none, // No visible border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1), // Orange border when focused
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14), // Adjusted padding
                            // suffixIcon: Icon(
                            //   Icons.email_outlined,
                            //   color: TColor.gray,
                            //   size: 18,
                            // ), // Removed email icon
                          ),
                        ),
                 

                  SizedBox(height: media.width * 0.1),

                  // Reset Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                viewModel.txtEmail.text = _emailController.text;
                                await viewModel.resetPassword();

                                if (viewModel.isSuccess && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Email khôi phục mật khẩu đã được gửi!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  if (context.mounted) Navigator.pop(context);
                                } else if (viewModel.error.isNotEmpty &&
                                    context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(viewModel.error),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.orange3,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Xác nhận',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),

                  SizedBox(height: media.width * 0.1),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Quay lại ",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: TColor.color3,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
