import 'package:app/screens/menu.dart' show Menu;
import 'package:app/screens/navbar.dart';
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
  bool isRefreshing = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentCarouselIndex = 0;
  String? userId;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
    }
  }

  Future<void> _fetchPayments() async {
    setState(() {
      isLoadingPayments = true;
      isRefreshing = true;
    });
    try {
      final fetchedPayments = await ApiService.getPaymentHistory(userId!);
      setState(() {
        payments = fetchedPayments;
        isLoadingPayments = false;
        isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPayments = false;
        isRefreshing = false;
      });
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent);
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/location');
        break;
      case 2:
        Get.offNamed('/notifications');
        break;
      case 3:
        Get.offNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), 
      body: Stack(
        children: [
          Column(
            children: [
              // Upper half: Cards Section
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Cards',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF000080),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Menu(),
                            ],
                          ),
                        ),
                        SizedBox(height: Styles.defaultPadding),
                        Expanded(
                          child: isLoadingCards
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : cards.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No cards added yet.\nTap the + button to add a card.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white70,
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
                                              autoPlayInterval: const Duration(seconds: 5),
                                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                              aspectRatio: 16 / 9,
                                              viewportFraction: 0.85,
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
                                                      return Transform(
                                                        transform: Matrix4.identity()
                                                          ..setEntry(3, 2, 0.001)
                                                          ..rotateY(_animation.value * 0.1),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(20),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Colors.black54,
                                                                offset: Offset(0, 4),
                                                                blurRadius: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(20),
                                                            child: CreditCardWidget(
                                                              cardNumber: card['cardNumber'],
                                                              expiryDate: card['expiryDate'],
                                                              cardHolderName: card['cardHolderName'] ?? 'No Name',
                                                              cvvCode: card['cvv'],
                                                              showBackView: false,
                                                              onCreditCardWidgetChange: (creditCardBrand) {},
                                                              cardBgColor: const Color(0xFF1E3A8A),
                                                              glassmorphismConfig: Glassmorphism.defaultConfig(),
                                                              textStyle: const TextStyle(
                                                                fontFamily: 'Poppins',
                                                                color: Colors.white,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                              ),
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
                                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _currentCarouselIndex == entry.key
                                                      ? Colors.white
                                                      : Colors.white.withOpacity(0.4),
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
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xFFFFFFFF), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Styles.defaultPadding,
                          vertical: Styles.defaultPadding / 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transactions',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF000080),
                                letterSpacing: 1.2,
                              ),
                            ),
                            TextButton(
                              onPressed: _fetchPayments,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isRefreshing)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF000080),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  const Text(
                                    'REFRESH',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF000080),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoadingPayments
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF000080)))
                            : payments.isEmpty
                                ? Container(
                                    margin: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                                    padding: EdgeInsets.all(Styles.defaultPadding),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF000080).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'No transactions yet.\nMake a payment with your bracelet to see it here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFF000080),
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                                    itemCount: payments.length,
                                    itemBuilder: (context, index) {
                                      final payment = payments[index];
                                      return Card(
                                        elevation: 0,
                                        color: const Color(0xFF000080).withOpacity(0.05),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF000080).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.store,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            payment['merchant'],
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Color(0xFF000080),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Date: ${DateTime.parse(payment['date']).toLocal().toString().split('.')[0]}',
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Color(0xFF000080),
                                              fontSize: 12,
                                            ),
                                          ),
                                          trailing: Text(
                                            '-\$${payment['amount'].toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.redAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
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
              const SizedBox(height: 90), 
            ],
          ),
          CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onNavItemTapped,
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), 
        child: FloatingActionButton(
          onPressed: () => Get.toNamed('/add-card-guide'),
          backgroundColor: const Color(0xFF000080),
          elevation: 8,
          child: const Icon(Icons.add, color: Color(0xFF98b5e4), size: 28),
        ),
      ),
    );
  }
}