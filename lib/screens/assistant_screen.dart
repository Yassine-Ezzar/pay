import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/styles/styles.dart';

class AssistantScreen extends StatefulWidget {
  @override
  _AssistantScreenState createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _sendQuestion() {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'message': _questionController.text.trim()});
      _isLoading = true;
      _fadeController.reset();
      _fadeController.forward();
    });

    _processResponse(_questionController.text.trim());
    _questionController.clear();
  }

  void _processResponse(String question) async {
    String response = _getBotResponse(question);
    await Future.delayed(const Duration(milliseconds: 800)); 

    setState(() {
      _chatHistory.add({'role': 'bot', 'message': response});
      _isLoading = false;
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  String _getBotResponse(String question) {
    question = question.toLowerCase().trim();

    if (question.startsWith('hello') || question.startsWith('salut') || question.startsWith('bonjour')) {
      return 'Hello! I’m your virtual assistant. How can I help you today?'.tr;
    } else if (question.contains('merci') || question.contains('thank you') || question.contains('thanks')) {
      return 'You’re welcome! If you have any more questions, feel free to ask.'.tr;
    } else if (question.contains('lost my bracelet') || question.contains('desactivate bracelet') || question.contains('bracelet not working')) {
      return 'If you lost your bracelet, use the geolocation feature in the app to find it. If it’s not working, reset it or ensure Bluetooth is connected.'.tr;
    } else if (question.contains('delete my data') || question.contains('remove my data') || question.contains('data deletion')) {
      return 'You can request data deletion anytime by contacting the administrator.'.tr;
    } else if (question.contains('carte') || question.contains('add card') || question.contains('wallet') || question.contains('carte bancaire') || question.contains('bank card')) {
      return 'To add a bank card, go to the "Wallet" icon in the app. Add a credit/debit card manually or by scanning, with a stable internet connection.'.tr;
    } else if (question.contains('activate bracelet') || question.contains('how to use bracelet') || question.contains('bracelet tutorial')) {
      return 'To activate your bracelet, follow the tutorial in the app. Enable Bluetooth and ensure it’s charged. Contact support if needed.'.tr;
    } else if (question.contains('notifications') || question.contains('settings') || question.contains('preferences')) {
      return 'Manage notifications under "Settings" in the app for transactions, promotions, or updates.'.tr;
    } else if (question.contains('profile') || question.contains('account') || question.contains('settings')) {
      return 'Edit your profile under "Profile" in the app to update personal info, password, and account settings.'.tr;
    } else if (question.contains('theme') || question.contains('dark mode') || question.contains('light mode')) {
      return 'Change the theme in "Theme Settings" under settings, choosing between light and dark mode.'.tr;
    } else if (question.contains('language') || question.contains('change language') || question.contains('langue')) {
      return 'Change the language in "Language Selection" under settings, with support for multiple languages.'.tr;
    } else if (question.contains('location') || question.contains('find bracelet') || question.contains('geolocation')) {
      return 'Use the geolocation feature to find your bracelet. Ensure GPS is enabled and the bracelet is in range.'.tr;
    } else if (question.contains('help') || question.contains('support') || question.contains('aide')) {
      return 'I’m here to help! Check our FAQ for technical issues or access tutorials for bracelet use, payments, or location. Our 24/7 support is available via email or in-app chat.'.tr;
    } else if (question.contains('technical') || question.contains('bug') || question.contains('problème')) {
      return 'For bugs or connection issues with your bracelet or payment, consult the FAQ or contact technical support.'.tr;
    } else if (question.contains('tutorial') || question.contains('guide') || question.contains('utilisation')) {
      return 'Find tutorials in the app for activating your bracelet, adding payment methods, or locating a lost bracelet.'.tr;
    } else if (question.contains('contact') || question.contains('email') || question.contains('phone')) {
      return 'Contact us at: Email: contact@sierrabravointelligence.com, Phone: (+216) 28070378 or (+212) 664156495, Address: 1, rue Julius et Ethel Rosenberg, immeuble SCENEO - Paris-France. Response within 24-48 hours.'.tr;
    } else if (question.contains('privacy') || question.contains('data') || question.contains('sécurité')) {
      return 'Your data security is priority. We collect personal info (name, email), GPS, and payment data for transactions and tracking, encrypted and not sold. Delete via account settings.'.tr;
    } else {
      return 'Sorry, I can’t help with that. I’m specialized in this app only. Ask about help, contact, or privacy!'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'assistant'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () {
              Get.snackbar(
                'Info'.tr,
                'Ask me anything about the app!'.tr,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Styles.darkDefaultGreyColor
                    : Colors.grey[300],
                colorText: Theme.of(context).textTheme.bodyLarge?.color,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(10),
                borderRadius: 10,
              );
            },
          ),
        ],
      ),
      body: Container(
        height: screenHeight - safePadding - kToolbarHeight,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, 
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkScaffoldBackgroundColor.withOpacity(0.9)
                      : Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final chat = _chatHistory[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: chat['role'] == 'user' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: chat['role'] == 'user' ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (chat['role'] == 'bot')
                            const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.smart_toy, size: 20, color: Colors.white),
                            ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: chat['role'] == 'user'
                                    ? Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({})?.withOpacity(0.9)
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Styles.darkDefaultLightGreyColor
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                chat['message']!,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: chat['role'] == 'user'
                                      ? Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({})
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                          if (chat['role'] == 'user')
                            const SizedBox(width: 10),
                          if (chat['role'] == 'user')
                            const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 20, color: Colors.white),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05, 
                10,
                screenWidth * 0.05, 
                10 + MediaQuery.of(context).viewInsets.bottom, 
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Styles.darkDefaultLightGreyColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          hintText: 'ask_me'.tr,
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        ),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendQuestion,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}