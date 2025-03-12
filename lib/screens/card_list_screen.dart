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
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.snackbar('Erreur', 'Utilisateur non connecté',
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
        Get.snackbar('Erreur', e.toString(),
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
        Get.snackbar('Succès', 'Carte supprimée',
            backgroundColor: Styles.defaultBlueColor, colorText: Styles.defaultYellowColor);
      } catch (e) {
        Get.snackbar('Erreur', e.toString(),
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Styles.scaffoldBackgroundColor,
        title: Text(
          'Mes cartes',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: Styles.defaultYellowColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
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
                              color: Styles.defaultYellowColor.withOpacity(0.5),
                            ),
                            SizedBox(height: Styles.defaultPadding),
                            Text(
                              'Aucune carte ajoutée',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 20,
                                color: Styles.defaultYellowColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Styles.defaultPadding),
                            Text(
                              'Ajoutez une carte pour commencer',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                color: Styles.defaultLightGreyColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(height: Styles.defaultPadding * 2),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: cards.length,
                              itemBuilder: (context, index) {
                                final card = cards[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Styles.defaultPadding / 2,
                                    vertical: Styles.defaultPadding,
                                  ),
                                  child: _buildCardItem(card),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: Styles.defaultPadding),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: cards.length,
                            effect: WormEffect(
                              dotColor: Styles.defaultLightGreyColor,
                              activeDotColor: Styles.defaultYellowColor,
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Styles.defaultYellowColor),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-card')?.then((_) => _fetchCards()), // Rafraîchit après ajout
        backgroundColor: Styles.defaultBlueColor,
        elevation: 6,
        child: Icon(Icons.add, color: Styles.defaultYellowColor, size: 28),
      ),
    );
  }

  Widget _buildCardItem(dynamic card) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: Styles.defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Styles.defaultBlueColor.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CreditCardWidget(
            cardNumber: card['cardNumber'],
            expiryDate: card['expiryDate'],
            cardHolderName: '',
            cvvCode: card['cvv'],
            showBackView: false,
            onCreditCardWidgetChange: (creditCardBrand) {},
            cardBgColor: Styles.defaultGreyColor,
            glassmorphismConfig: Glassmorphism.defaultConfig(),
            textStyle: TextStyle(
              fontFamily: 'Rubik',
              color: Styles.defaultYellowColor,
              fontSize: 16,
            ),
            animationDuration: Duration(milliseconds: 300),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
            child: InkWell(
              onTap: () => _deleteCard(card['_id']),
              borderRadius: Styles.defaultBorderRadius,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Styles.defaultRedColor, Styles.defaultRedColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: Styles.defaultBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Styles.defaultRedColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Styles.defaultYellowColor, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Supprimer',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        color: Styles.defaultYellowColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}