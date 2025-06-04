import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../styles/styles.dart';

class ResetPinScreen extends StatefulWidget {
  @override
  _ResetPinScreenState createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final _nameController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPinController = TextEditingController();
  String _enteredPin = '';

  void _addNumber(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _newPinController.text = _enteredPin;
      });
    }
  }

  void _deleteNumber() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _newPinController.text = _enteredPin;
      });
    }
  }

  void _resetPin() async {
    if (_enteredPin.length != 4 || _nameController.text.isEmpty || _answerController.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
    'please_fill_all_fields'.tr,
        backgroundColor: Styles.defaultRedColor,
        colorText: Colors.white,
      );
      return;
    }
    try {
      await ApiService.resetPin(
        _nameController.text,
        _answerController.text,
        _newPinController.text,
      );
      Get.offNamed('/password-changed'); 
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF063B87)),
          onPressed: () => Get.back(),
        ),
        title:  Text(
        'reset_pin'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF063B87),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding * 1.5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPin.length ? const Color(0xFF063B87) : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Text(
                _enteredPin.isEmpty ? '****' : _enteredPin,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr,
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF063B87)),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              ),
              SizedBox(height: Styles.defaultPadding),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'pet_name'.tr,
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: Styles.defaultBorderRadius,
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF063B87)),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: List.generate(9, (index) {
                  return ElevatedButton(
                    onPressed: () => _addNumber('${index + 1}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                })
                  ..addAll([
                    ElevatedButton(
                      onPressed: _deleteNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Icon(
                        Icons.backspace,
                        size: 24,
                        color: Color(0xFF063B87),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addNumber('0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox.shrink(),
                  ]),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              SizedBox(
                width: 363,
                height: 68,
                child: ElevatedButton(
                  onPressed: _enteredPin.length == 4 &&
                          _nameController.text.isNotEmpty &&
                          _answerController.text.isNotEmpty
                      ? _resetPin
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child:  Text(
                   'submit'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

