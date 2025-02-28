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
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs correctement', backgroundColor: Styles.defaultRedColor);
      return;
    }
    try {
      await ApiService.resetPin(
        _nameController.text,
        _answerController.text,
        _newPinController.text,
      );
      Get.back();
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Styles.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reset PIN',
          style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor, fontSize: 24),
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPin.length ? Styles.defaultYellowColor : Styles.defaultGreyColor,
                        border: Border.all(color: Styles.defaultLightWhiteColor),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              Text(
                _enteredPin.isEmpty ? '****' : _enteredPin,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Styles.defaultYellowColor,
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.defaultGreyColor),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.defaultYellowColor, width: 2),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                ),
                style: TextStyle(color: Styles.defaultYellowColor, fontFamily: 'Rubik', fontSize: 18),
              ),
              SizedBox(height: Styles.defaultPadding),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Nom de votre animal',
                  labelStyle: TextStyle(color: Styles.defaultLightWhiteColor),
                  filled: true,
                  fillColor: Styles.defaultLightGreyColor.withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.defaultGreyColor),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.defaultYellowColor, width: 2),
                    borderRadius: Styles.defaultBorderRadius,
                  ),
                ),
                style: TextStyle(color: Styles.defaultYellowColor, fontFamily: 'Rubik', fontSize: 18),
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
                      backgroundColor: Styles.defaultLightGreyColor,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 24, fontFamily: 'Rubik', fontWeight: FontWeight.bold),
                    ),
                  );
                })..addAll([
                  ElevatedButton(
                    onPressed: _deleteNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.defaultLightGreyColor,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Icon(Icons.backspace, size: 24, color: Styles.defaultYellowColor),
                  ),
                  ElevatedButton(
                    onPressed: () => _addNumber('0'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.defaultLightGreyColor,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      '0',
                      style: TextStyle(fontSize: 24, fontFamily: 'Rubik', fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox.shrink(),
                ]),
              ),
              SizedBox(height: Styles.defaultPadding * 2),
              ElevatedButton(
                onPressed: _enteredPin.length == 4 &&
                        _nameController.text.isNotEmpty &&
                        _answerController.text.isNotEmpty
                    ? _resetPin
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.defaultBlueColor,
                  foregroundColor: Styles.defaultYellowColor,
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 80),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                ),
                child: Text(
                  'SUBMIT',
                  style: TextStyle(fontSize: 20, fontFamily: 'Rubik', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}