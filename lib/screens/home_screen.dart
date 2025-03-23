import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> cards = [];
  List<dynamic> payments = [];
  bool isLoadingCards = true;
  bool isLoadingPayments = true;
  bool isRefreshing = false; // État pour gérer l'animation de rafraîchissement
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentCarouselIndex = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _loadUserId();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    userId = await ApiService.storage.read(key: 'userId');
    if (userId == null) {
      Get.offNamed('/login');
    } else {
      _fetchCards();
      _fetchPayments();
    }
  }

  Future<void> _fetchCards() async {
    setState(() => isLoadingCards = true);
    try {
      final fetchedCards = await ApiService.getCards(userId!);
      setState(() {
        cards = fetchedCards;
        isLoadingCards = false;
      });
    } catch (e) {
      setState(() => isLoadingCards = false);
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  Future<void> _fetchPayments() async {
    setState(() {
      isLoadingPayments = true;
      isRefreshing = true; // Activer l'état de rafraîchissement
    });
    try {
      final fetchedPayments = await ApiService.getPaymentHistory(userId!);
      setState(() {
        payments = fetchedPayments;
        isLoadingPayments = false;
        isRefreshing = false; // Désactiver l'état de rafraîchissement
      });
    } catch (e) {
      setState(() {
        isLoadingPayments = false;
        isRefreshing = false;
      });
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
                  colors: const [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Styles.defaultPadding,
                        vertical: Styles.defaultPadding / 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Cards',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Styles.defaultYellowColor,
                              shadows: const [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Styles.defaultYellowColor,
                              size: 28,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Styles.scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => Container(
                                  padding: EdgeInsets.all(Styles.defaultPadding),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.watch, color: Styles.defaultYellowColor),
                                        title: Text(
                                          'Bracelet',
                                          style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                                        ),
                                        onTap: () {
                                          Get.back();
                                          Get.toNamed('/bracelet-management');
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.logout, color: Styles.defaultRedColor),
                                        title: Text(
                                          'Logout',
                                          style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultRedColor),
                                        ),
                                        onTap: () async {
                                          await ApiService.storage.deleteAll();
                                          Get.offAllNamed('/login');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Styles.defaultPadding),
                    // Cards Carousel
                    Expanded(
                      child: isLoadingCards
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Styles.defaultYellowColor,
                                strokeWidth: 3,
                              ),
                            )
                          : cards.isEmpty
                              ? Center(
                                  child: Text(
                                    'No cards added yet.\nTap the + button to add a card.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: Styles.defaultLightWhiteColor,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Expanded(
                                      child: CarouselSlider(
                                        options: CarouselOptions(
                                          height: 200,
                                          enlargeCenterPage: true,
                                          autoPlay: true,
                                          autoPlayInterval: Duration(seconds: 5),
                                          autoPlayAnimationDuration: Duration(milliseconds: 800),
                                          aspectRatio: 16 / 9,
                                          viewportFraction: 0.75,
                                          enableInfiniteScroll: true,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentCarouselIndex = index;
                                            });
                                          },
                                        ),
                                        items: cards.map((card) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return AnimatedBuilder(
                                                animation: _animation,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: 1.0 + (_animation.value * 0.05),
                                                    child: Card(
                                                      elevation: 10,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      shadowColor: Colors.black45,
                                                      child: CreditCardWidget(
                                                        cardNumber: card['cardNumber'],
                                                        expiryDate: card['expiryDate'],
                                                        cardHolderName: card['cardHolderName'] ?? 'No Name',
                                                        cvvCode: card['cvv'],
                                                        showBackView: false,
                                                        onCreditCardWidgetChange: (creditCardBrand) {},
                                                        cardBgColor: Color(0xFF1E3A8A),
                                                        textStyle: TextStyle(
                                                          fontFamily: 'Rubik',
                                                          color: Styles.defaultYellowColor,
                                                          fontSize: 16,
                                                          shadows: const [
                                                            Shadow(
                                                              color: Colors.black26,
                                                              offset: Offset(1, 1),
                                                              blurRadius: 2,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(height: Styles.defaultPadding / 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: cards.asMap().entries.map((entry) {
                                        return GestureDetector(
                                          onTap: () => setState(() => _currentCarouselIndex = entry.key),
                                          child: Container(
                                            width: _currentCarouselIndex == entry.key ? 10 : 6,
                                            height: _currentCarouselIndex == entry.key ? 10 : 6,
                                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentCarouselIndex == entry.key
                                                  ? Styles.defaultYellowColor
                                                  : Styles.defaultLightGreyColor.withOpacity(0.4),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lower half: Transactions (now showing payment history)
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
                        'Transactions',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Styles.defaultYellowColor,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchPayments, 
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isRefreshing) 
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Styles.defaultYellowColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            Text(
                              'REFRESH',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                color: Styles.defaultYellowColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  Expanded(
                    child: isLoadingPayments
                        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
                        : payments.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(Styles.defaultPadding),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'No transactions yet.\nMake a payment with your bracelet to see it here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      color: Styles.defaultLightWhiteColor,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: payments.length,
                                itemBuilder: (context, index) {
                                  final payment = payments[index];
                                  return Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                                    color: Colors.white.withOpacity(0.1),
                                    child: ListTile(
                                      leading: Icon(Icons.payment, color: Styles.defaultYellowColor),
                                      title: Text(
                                        payment['merchant'],
                                        style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultYellowColor),
                                      ),
                                      subtitle: Text(
                                        'Amount: \$${payment['amount'].toStringAsFixed(2)}\nDate: ${DateTime.parse(payment['date']).toLocal().toString().split('.')[0]}',
                                        style: TextStyle(fontFamily: 'Rubik', color: Styles.defaultLightWhiteColor),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-card'),
        backgroundColor: Styles.defaultBlueColor,
        child: Icon(Icons.add, color: Styles.defaultYellowColor),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[600],
        selectedItemColor: Styles.defaultYellowColor,
        unselectedItemColor: Styles.defaultLightWhiteColor.withOpacity(0.6),
        selectedLabelStyle: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontFamily: 'Rubik'),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 28),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
        
        },
        elevation: 15,
      ),
    );
  }
}