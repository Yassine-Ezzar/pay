import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> cards = [];
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fetchCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchCards() async {
    setState(() => isLoading = true);
    try {
      final userId = await ApiService.storage.read(key: 'userId');
      if (userId != null) {
        final fetchedCards = await ApiService.getCards(userId);
        setState(() {
          cards = fetchedCards;
          isLoading = false;
        });
      } else {
        Get.snackbar('Error', 'User not logged in.', backgroundColor: Styles.defaultRedColor);
        Get.offNamed('/login');
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Upper half: Card Section with AppBar integrated
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)], // Dark gradient
                ),
              ),
              child: Column(
                children: [
                  // Integrated AppBar with "Your Card" and Menu
                  Padding(
                    padding: EdgeInsets.all(Styles.defaultPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Card',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Styles.defaultYellowColor,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.menu, color: Styles.defaultYellowColor, size: 28),
                          onPressed: () {
                            // Add menu logic here
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding / 2),
             
                  SizedBox(height: Styles.defaultPadding),
                  // Cards Carousel
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Styles.defaultYellowColor,
                              strokeWidth: 2,
                            ),
                          )
                        : cards.isEmpty
                            ? Center(
                                child: Text(
                                  'No cards added yet.',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    color: Styles.defaultLightWhiteColor,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : CarouselSlider(
                                options: CarouselOptions(
                                  height: 220,
                                  enlargeCenterPage: true,
                                  autoPlay: false,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.75,
                                  enableInfiniteScroll: false,
                                ),
                                items: cards.map((card) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: CreditCardWidget(
                                            cardNumber: card['cardNumber'],
                                            expiryDate: card['expiryDate'],
                                            cardHolderName: card['cardHolderName'] ?? 'No Name',
                                            cvvCode: card['cvv'],
                                            showBackView: false,
                                            onCreditCardWidgetChange: (creditCardBrand) {},
                                            cardBgColor: Color(0xFF1E3A8A), // Teal-like color
                                            textStyle: TextStyle(
                                              fontFamily: 'Rubik',
                                              color: Styles.defaultYellowColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                  ),
                ],
              ),
            ),
          ),
          // Lower half: Transactions
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[300]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.all(Styles.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Styles.defaultYellowColor,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See all',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: Styles.defaultYellowColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Transactions will be displayed here soon.',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[600],
        selectedItemColor: Styles.defaultYellowColor,
        unselectedItemColor: const Color.fromARGB(179, 13, 13, 13),
        selectedLabelStyle: TextStyle(fontFamily: 'Rubik'),
        unselectedLabelStyle: TextStyle(fontFamily: 'Rubik'),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Add navigation logic if needed
        },
        elevation: 10,
      ),
    );
  }
}