import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> address;
  final bool isAddressEdit;
  final VoidCallback? function;

  const EditAddressScreen({
    super.key,
    required this.address,
    this.isAddressEdit = false,
    this.function,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

enum AddressType { Home, Work, Other }

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController areaController;
  late TextEditingController pincodeController;
  late TextEditingController stateController;

  AddressType _selectedType = AddressType.Home;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.address['name'] ?? '');
    mobileController =
        TextEditingController(text: widget.address['phone'] ?? '');
    addressController =
        TextEditingController(text: widget.address['address1'] ?? '');
    cityController = TextEditingController(text: widget.address['city'] ?? '');
    areaController = TextEditingController(text: widget.address['area'] ?? '');
    pincodeController =
        TextEditingController(text: widget.address['pincode'] ?? '');
    stateController = TextEditingController(
        text: widget.address['state'] ?? ''); // ✅ Fix here

    _selectedType = AddressType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() ==
          (widget.address['type_address'] ?? 'Home').toLowerCase(),
      orElse: () => AddressType.Home,
    );
  }

  Future<void> updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final userId = await SharedPref.getUserId();

    if (userId == null) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'User ID not found. Please login again.');
      return;
    }

    final body = {
      "user_id": userId.toString(),
      "name": nameController.text,
      "phone": mobileController.text,
      "address1": addressController.text,
      "city": cityController.text,
      "area": areaController.text,
      "pincode": pincodeController.text,
      "state": stateController.text,
      "type_address": _selectedType.name,
    };

    if (widget.isAddressEdit) {
      body["address_id"] = widget.address['id'];
    }

    final url = widget.isAddressEdit
        ? Uri.parse('$baseUrl/Auth/address_update')
        : Uri.parse('$baseUrl/Auth/address_save');

    try {
      print("Sending POST to: $url");
      print("Body: $body");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      setState(() => isLoading = false);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 200) {
          Get.back(result: true);
          widget.function?.call();
          Get.snackbar(
            'Success',
            widget.isAddressEdit ? 'Address updated' : 'Address added',
          );
        } else {
          Get.snackbar('Error', res['message'] ?? 'Operation failed');
        }
      } else {
        Get.snackbar('Error', 'Something went wrong');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Exception occurred: $e");
      Get.snackbar('Error', 'Something went wrong. Please try again later.');
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: widget.isAddressEdit ? "Edit Address" : "Add Address",
        showBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: buildInputDecoration("Name"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: mobileController,
                decoration: buildInputDecoration("Mobile"),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter mobile number';
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Mobile number must be exactly 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                decoration: buildInputDecoration("Address"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter address' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityController,
                decoration: buildInputDecoration("City"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter city' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: areaController,
                decoration: buildInputDecoration("Area"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter area' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pincodeController,
                decoration: buildInputDecoration("Pincode"),
                keyboardType: TextInputType.number,
                maxLength: 7,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter pincode';
                  if (!RegExp(r'^\d{7}$').hasMatch(value)) {
                    return 'Pincode must be exactly 7 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stateController,
                decoration: buildInputDecoration("State"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter state' : null,
              ),
              const SizedBox(height: 20),
              const Text("Address Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: AddressType.values.map((type) {
                  return Expanded(
                    child: RadioListTile<AddressType>(
                      title: Text(type.name),
                      value: type,
                      groupValue: _selectedType,
                      onChanged: (value) =>
                          setState(() => _selectedType = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : updateAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.isAddressEdit
                        ? "Update Address"
                        : "Add Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
