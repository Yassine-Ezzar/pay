import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _isLoading = false;

  Future<void> _submitContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await ApiService.sendOTP(_identifier, 'sms');
        Get.snackbar(
          'success'.tr,
          'otp_sent_successfully'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Get.toNamed('/enter-otp', arguments: {
          'identifier': _identifier,
          'type': 'sms',
          ...Get.arguments,
        });
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1E3A8A).withOpacity(0.9), const Color(0xFF4B6CB7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Styles.defaultPadding * 2,
                    horizontal: Styles.defaultPadding,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white.withOpacity(0.9),
                              size: 30,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Icon(
                        Icons.phone_iphone_rounded,
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ).animate().scale(duration: 800.ms, curve: Curves.easeOut),
                      const SizedBox(height: 20),
                      Text(
                        'verify_phone_number'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 10),
                      Text(
                        'otp_via_sms'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 700.ms),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Styles.defaultPadding,
                    vertical: Styles.defaultPadding,
                  ),
                  padding: EdgeInsets.all(Styles.defaultPadding * 1.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkScaffoldBackgroundColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black54.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'phone_number'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightWhiteColor
                                : const Color(0xFF1E3A8A),
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                        const SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: '+12345678901',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Styles.darkDefaultGreyColor
                                  : Colors.grey[500],
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightGreyColor.withOpacity(0.2)
                                : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Styles.darkDefaultBlueColor
                                  : const Color(0xFF0066FF),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Styles.darkDefaultLightWhiteColor
                                : Colors.black87,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_phone'.tr;
                            }
                            if (!RegExp(r'^\+\d{10,15}$').hasMatch(value)) {
                              return 'invalid_phone_format'.tr;
                            }
                            return null;
                          },
                          onSaved: (value) => _identifier = value!,
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                        const SizedBox(height: 40),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitContact,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0066FF),
                                      const Color(0xFF004ECC),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'send_otp'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ).animate().scale(duration: 700.ms, delay: 300.ms),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}