import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  String? userId;
  List<dynamic> cards = [];
  final PageController _pageController = PageController(viewportFraction: 0.9);
  bool isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.snackbar('error'.tr, 'user_not_logged_in'.tr,
          backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      Get.offNamed('/login');
    } else {
      _fetchCards();
    }
  }

  void _fetchCards() async {
    if (userId != null) {
      setState(() => isLoading = true);
      try {
        final fetchedCards = await ApiService.getCards(userId!);
        setState(() {
          cards = fetchedCards;
        });
      } catch (e) {
        Get.snackbar('Error', e.toString(),
            backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _deleteCard(String cardId) async {
    if (userId != null) {
      setState(() => isLoading = true);
      try {
        await ApiService.deleteCard(cardId);
        _fetchCards();
        Get.snackbar('success'.tr, 'card_deleted'.tr,
            backgroundColor: Styles.defaultBlueColor, colorText: Styles.defaultYellowColor);
      } catch (e) {
        Get.snackbar('error'.tr, e.toString(),
            backgroundColor: Styles.defaultRedColor, colorText: Styles.defaultLightWhiteColor);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
      backgroundColor:Color.fromRGBO(0, 0, 0, 1),
        title:  Text(
          'your_cards'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.toNamed('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => Get.toNamed('/add-card-guide')?.then((_) => _fetchCards()),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.grey[900]!],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: cards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_off,
                                size: 80,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              SizedBox(height: Styles.defaultPadding),
                               Text(
                                'no_cards_added'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: Styles.defaultPadding),
                              Text(
                                'add_card_to_start'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.vertical, 
                              itemCount: cards.length,
                              itemBuilder: (context, index) {
                                final card = cards[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Styles.defaultPadding,
                                    vertical: Styles.defaultPadding / 2,
                                  ),
                                  child: _buildCardItem(card, index),
                                );
                              },
                            ),
                            if (cards.length > 1)
                              Positioned(
                                right: 20,
                                top: MediaQuery.of(context).size.height * 0.3,
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: cards.length,
                                  axisDirection: Axis.vertical,
                                  effect: WormEffect(
                                    dotColor: Colors.grey[700]!,
                                    activeDotColor: Colors.white,
                                    dotHeight: 8,
                                    dotWidth: 8,
                                    spacing: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardItem(dynamic card, int index) {
    final List<Color> cardColors = [
      const Color.fromARGB(255, 229, 228, 228), 
      const Color.fromARGB(139, 107, 33, 168), 
      const Color.fromARGB(182, 52, 79, 153),
      const Color(0xFF047857), 
      const Color.fromARGB(157, 220, 38, 38),
      const Color.fromARGB(255, 111, 111, 111),
    ];
    final cardColor = cardColors[index % cardColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          CreditCardWidget(
            cardNumber: card['cardNumber'],
            expiryDate: card['expiryDate'],
            cardHolderName: card['cardHolderName'] ?? '',
            cvvCode: card['cvv'],
            showBackView: false,
            onCreditCardWidgetChange: (creditCardBrand) {},
            cardBgColor: cardColor,
            textStyle: const TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            animationDuration: const Duration(milliseconds: 300),
            padding: 20,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white.withOpacity(0.8), size: 24),
              onPressed: () => _deleteCard(card['_id']),
            ),
          ),
        ],
      ),
    );
  }
}