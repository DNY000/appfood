import 'package:flutter/material.dart';
import 'package:foodapp/data/models/address_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({Key? key}) : super(key: key);

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _addressController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;
    final fullStreet = [
      _addressController.text,
      _wardController.text,
      _districtController.text,
      _cityController.text,
    ].where((e) => e.isNotEmpty).join(', ');
    final address = AddressModel(
      street: fullStreet,
      isDefault: _isDefault,
    );
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm địa chỉ mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _cityController,
                label: 'Thành phố',
                icon: Icons.location_on,
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập thành phố'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _districtController,
                label: 'Quận/Huyện',
                icon: Icons.map,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _wardController,
                label: 'Xã/Phường',
                icon: Icons.location_city,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Địa chỉ (số nhà, tên đường)',
                icon: Icons.home,
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập địa chỉ'
                    : null,
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val ?? false),
                title: const Text('Đặt làm địa chỉ mặc định'),
                activeColor: TColor.color3,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveAddress,
                  icon: const Icon(Icons.save, size: 22),
                  label: const Text('Lưu địa chỉ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.color3,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    shadowColor: TColor.orange3,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.black54, size: 22) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      cursorColor: Colors.black,
    );
  }
}
