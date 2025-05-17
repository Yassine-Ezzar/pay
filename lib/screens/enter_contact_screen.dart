import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class EnterContactScreen extends StatefulWidget {
  @override
  _EnterContactScreenState createState() => _EnterContactScreenState();
}

class _EnterContactScreenState extends State<EnterContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String _identifier = '';
  String _type = 'sms'; // Default to SMS
  bool _isLoading = false;

  Future<void> _submitContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await ApiService.sendOTP(_identifier, _type);
        Get.snackbar('Success', 'OTP sent successfully', backgroundColor: Colors.green);
        Get.toNamed('/enter-otp', arguments: {
          'identifier': _identifier,
          'type': _type,
          ...Get.arguments, // Pass along the card details
        });
      } catch (e) {
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF063B87)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Enter Contact Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Color(0xFF063B87),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose how to receive your OTP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Color(0xFF063B87),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'SMS',
                        style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: 'sms',
                        groupValue: _type,
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                            _identifier = ''; // Reset identifier
                          });
                        },
                        activeColor: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Email',
                        style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: 'email',
                        groupValue: _type,
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                            _identifier = ''; // Reset identifier
                          });
                        },
                        activeColor: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: _type == 'sms' ? 'Phone Number (e.g., +12345678901)' : 'Email Address',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    _type == 'sms' ? Icons.phone : Icons.email,
                    color: Colors.black,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                keyboardType: _type == 'sms' ? TextInputType.phone : TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _type == 'sms' ? 'Please enter your phone number' : 'Please enter your email address';
                  }
                  if (_type == 'sms' && !RegExp(r'^\+\d{10,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number in international format (e.g., +12345678901)';
                  }
                  if (_type == 'email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => _identifier = value!,
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 363,
                  height: 68,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}