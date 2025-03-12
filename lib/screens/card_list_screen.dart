import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  String? userId;
  List<dynamic> cards = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.snackbar('Erreur', 'Utilisateur non connecté', backgroundColor: Styles.defaultRedColor);
      Get.offNamed('/login');
    } else {
      _fetchCards();
    }
  }

  void _fetchCards() async {
    if (userId != null) {
      try {
        final fetchedCards = await ApiService.getCards(userId!);
        setState(() {
          cards = fetchedCards;
        });
      } catch (e) {
        Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
      }
    }
  }

  void _deleteCard(String cardId) async {
    if (userId != null) {
      try {
        await ApiService.deleteCard(cardId);
        _fetchCards();
        Get.snackbar('Succès', 'Carte supprimée', backgroundColor: Styles.defaultBlueColor);
      } catch (e) {
        Get.snackbar('Erreur', e.toString(), backgroundColor: Styles.defaultRedColor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes cartes', style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor)),
        backgroundColor: Styles.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.defaultYellowColor),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: cards.isEmpty
          ? Center(
              child: Text(
                'Aucune carte ajoutée',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18,
                  color: Styles.defaultYellowColor,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(Styles.defaultPadding),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return Column(
                  children: [
                    CreditCardWidget(
                      cardNumber: card['cardNumber'],
                      expiryDate: card['expiryDate'],
                      cardHolderName: '',
                      cvvCode: card['cvv'],
                      showBackView: false,
                      onCreditCardWidgetChange: (creditCardBrand) {},
                      cardBgColor: Styles.defaultGreyColor,
                      textStyle: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                    ),
                    ElevatedButton(
                      onPressed: () => _deleteCard(card['_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.defaultRedColor,
                        foregroundColor: Styles.defaultYellowColor,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                      ),
                      child: Text('Supprimer', style: TextStyle(fontFamily: 'Rubik', fontSize: 16)),
                    ),
                    SizedBox(height: Styles.defaultPadding),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-card'),
        backgroundColor: Styles.defaultBlueColor,
        child: Icon(Icons.add, color: Styles.defaultYellowColor),
      ),
    );
  }
}