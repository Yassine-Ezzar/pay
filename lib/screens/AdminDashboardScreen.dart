import 'package:animate_do/animate_do.dart';
import 'package:app/services/api_service.dart';
import 'package:app/styles/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> users = [];
  List<dynamic> cards = [];
  List<dynamic> bracelets = [];
  List<dynamic> payments = [];
  List<dynamic> locations = [];
  Map<String, dynamic> stats = {};
  bool isLoadingUsers = true;
  bool isLoadingCards = true;
  bool isLoadingBracelets = true;
  bool isLoadingPayments = true;
  bool isLoadingLocations = true;
  bool isLoadingStats = true;
  String adminName = '';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fetchData();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final name = await ApiService.storage.read(key: 'name') ?? 'Admin';
    setState(() => adminName = name);
  }

  Future<void> _fetchData() async {
    setState(() {
      errorMessage = null;
      isLoadingUsers = true;
      isLoadingCards = true;
      isLoadingBracelets = true;
      isLoadingPayments = true;
      isLoadingLocations = true;
      isLoadingStats = true;
    });

    try {
      final fetchedUsers = await ApiService.getAllUsers();
      final fetchedCards = await ApiService.getAllCards();
      final fetchedBracelets = await ApiService.getAllBracelets();
      final fetchedPayments = await ApiService.getAllPayments();
      final fetchedLocations = await ApiService.getAllLocations();
      final fetchedStats = await ApiService.getDashboardStats();

      setState(() {
        users = fetchedUsers ?? [];
        cards = fetchedCards ?? [];
        bracelets = fetchedBracelets ?? [];
        payments = fetchedPayments ?? [];
        locations = fetchedLocations ?? [];
        stats = fetchedStats ?? {};
        isLoadingUsers = false;
        isLoadingCards = false;
        isLoadingBracelets = false;
        isLoadingPayments = false;
        isLoadingLocations = false;
        isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        users = [];
        cards = [];
        bracelets = [];
        payments = [];
        locations = [];
        stats = {};
        isLoadingUsers = false;
        isLoadingCards = false;
        isLoadingBracelets = false;
        isLoadingPayments = false;
        isLoadingLocations = false;
        isLoadingStats = false;
      });
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await ApiService.deleteUser(userId);
      Get.snackbar('Success', 'User deleted', backgroundColor: Styles.defaultBlueColor);
      _fetchData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      await ApiService.deleteCardAdmin(cardId);
      Get.snackbar('Success', 'Card deleted', backgroundColor: Styles.defaultBlueColor);
      _fetchData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  Future<void> _deleteBracelet(String braceletId) async {
    try {
      await ApiService.deleteBraceletAdmin(braceletId);
      Get.snackbar('Success', 'Bracelet deleted', backgroundColor: Styles.defaultBlueColor);
      _fetchData();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Styles.defaultRedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: Styles.defaultYellowColor,
          child: errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load data: $errorMessage',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultRedColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Styles.defaultPadding / 2),
                      ElevatedButton(
                        onPressed: _fetchData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.defaultBlueColor,
                          shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                          padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding, vertical: Styles.defaultPadding / 2),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: Styles.defaultYellowColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: FadeInDown(
                        child: Container(
                          padding: EdgeInsets.all(Styles.defaultPadding / 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Styles.defaultBlueColor, Styles.defaultBlueColor.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Welcome, $adminName',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.defaultYellowColor,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.logout, color: Styles.defaultYellowColor, size: 20),
                                onPressed: () async {
                                  await ApiService.storage.deleteAll();
                                  Get.offAllNamed('/login');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Overview Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(Styles.defaultPadding, Styles.defaultPadding, Styles.defaultPadding, Styles.defaultPadding / 2),
                        child: Text(
                          'Overview',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.defaultYellowColor,
                          ),
                        ),
                      ),
                    ),
                    // Stats Grid
                    SliverToBoxAdapter(
                      child: FadeInUp(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                          child: isLoadingStats
                              ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
                              : GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: Styles.defaultPadding / 2,
                                  mainAxisSpacing: Styles.defaultPadding / 2,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildStatCard('Users', stats['totalUsers']?.toString() ?? '0', Icons.people),
                                    _buildStatCard('Cards', stats['totalCards']?.toString() ?? '0', Icons.credit_card),
                                    _buildStatCard('Bracelets', stats['totalBracelets']?.toString() ?? '0', Icons.watch),
                                    _buildStatCard('Payments', stats['totalPayments']?.toString() ?? '0', Icons.payment),
                                    _buildStatCard('Locations', stats['totalLocations']?.toString() ?? '0', Icons.location_on),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    // Analytics Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(Styles.defaultPadding, Styles.defaultPadding, Styles.defaultPadding, Styles.defaultPadding / 2),
                        child: Text(
                          'Analytics',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.defaultYellowColor,
                          ),
                        ),
                      ),
                    ),
                    // Charts
                    SliverToBoxAdapter(
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final chartHeight = constraints.maxWidth < 600 ? 160.0 : 200.0;
                              return Container(
                                height: chartHeight,
                                child: _buildLineChart(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Details Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(Styles.defaultPadding, Styles.defaultPadding, Styles.defaultPadding, Styles.defaultPadding / 2),
                        child: Text(
                          'Details',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.defaultYellowColor,
                          ),
                        ),
                      ),
                    ),
                    // Tab Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: Styles.defaultYellowColor,
                          unselectedLabelColor: Styles.defaultLightWhiteColor,
                          indicatorColor: Styles.defaultYellowColor,
                          labelStyle: const TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold, fontSize: 12),
                          tabs: const [
                            Tab(text: 'Users'),
                            Tab(text: 'Cards'),
                            Tab(text: 'Bracelets'),
                            Tab(text: 'Payments'),
                            Tab(text: 'Locations'),
                            Tab(text: 'Stats'),
                          ],
                        ),
                      ),
                    ),
                    // Tab Views
                    SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildUsersTab(),
                            _buildCardsTab(),
                            _buildBraceletsTab(),
                            _buildPaymentsTab(),
                            _buildLocationsTab(),
                            _buildStatsTab(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Styles.defaultBlueColor.withOpacity(0.9), Styles.defaultBlueColor.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: Styles.defaultBorderRadius,
        ),
        padding: EdgeInsets.all(Styles.defaultPadding / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Styles.defaultYellowColor.withOpacity(0.2),
              child: Icon(icon, color: Styles.defaultYellowColor, size: 20),
            ),
            SizedBox(height: Styles.defaultPadding / 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Styles.defaultYellowColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 14,
                color: Styles.defaultLightWhiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // Dynamic data: Count users registered per month
    final userTrend = <double>[];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    if (users.isNotEmpty) {
      for (int i = 0; i < 7; i++) {
        final count = users.where((user) {
          final createdAt = DateTime.tryParse(user['createdAt'] ?? '');
          return createdAt != null && createdAt.month == i + 1;
        }).length;
        userTrend.add(count.toDouble());
      }
    } else {
      userTrend.addAll([0, 0, 0, 0, 0, 0, 0]); // Fallback
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
      child: Container(
        padding: EdgeInsets.all(Styles.defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Registration Trend',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Styles.defaultYellowColor,
              ),
            ),
            SizedBox(height: Styles.defaultPadding / 4),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Styles.defaultLightWhiteColor.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: Styles.defaultLightWhiteColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          months[value.toInt()],
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: Styles.defaultLightWhiteColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: userTrend
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: Styles.defaultYellowColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Styles.defaultYellowColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: (userTrend.isEmpty ? 10 : userTrend.reduce((a, b) => a > b ? a : b) + 5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return isLoadingUsers
        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
        : users.isEmpty
            ? Center(
                child: Text(
                  'No users found.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultLightWhiteColor,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(Styles.defaultPadding / 2),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Styles.defaultBlueColor,
                        child: Text(
                          user['name']?.toString()[0].toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: Styles.defaultYellowColor,
                          ),
                        ),
                      ),
                      title: Text(
                        user['name']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultYellowColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Joined: ${DateTime.tryParse(user['createdAt'] ?? '')?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Styles.defaultRedColor, size: 20),
                        onPressed: () => _deleteUser(user['_id']?.toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildCardsTab() {
    return isLoadingCards
        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
        : cards.isEmpty
            ? Center(
                child: Text(
                  'No cards found.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultLightWhiteColor,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(Styles.defaultPadding / 2),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.credit_card, color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Card: ${card['cardNumber']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultYellowColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'User: ${card['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Styles.defaultRedColor, size: 20),
                        onPressed: () => _deleteCard(card['_id']?.toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildBraceletsTab() {
    return isLoadingBracelets
        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
        : bracelets.isEmpty
            ? Center(
                child: Text(
                  'No bracelets found.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultLightWhiteColor,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(Styles.defaultPadding / 2),
                itemCount: bracelets.length,
                itemBuilder: (context, index) {
                  final bracelet = bracelets[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.watch, color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        bracelet['name']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultYellowColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'User: ${bracelet['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Styles.defaultRedColor, size: 20),
                        onPressed: () => _deleteBracelet(bracelet['braceletId']?.toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildPaymentsTab() {
    return isLoadingPayments
        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
        : payments.isEmpty
            ? Center(
                child: Text(
                  'No payments found.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultLightWhiteColor,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(Styles.defaultPadding / 2),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.payment, color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        payment['merchant']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultYellowColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Amount: \$${payment['amount']?.toStringAsFixed(2) ?? '0.00'}\nUser: ${payment['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildLocationsTab() {
    return isLoadingLocations
        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
        : locations.isEmpty
            ? Center(
                child: Text(
                  'No locations found.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Styles.defaultLightWhiteColor,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(Styles.defaultPadding / 2),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.location_on, color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Bracelet ID: ${location['braceletId']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultYellowColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Lat: ${location['latitude']?.toString() ?? 'N/A'}, Lon: ${location['longitude']?.toString() ?? 'N/A'}\nUser: ${location['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildStatsTab() {
    return isLoadingStats
        ? Center(child: CircularProgressIndicator(color: Styles.defaultYellowColor))
        : Padding(
            padding: EdgeInsets.all(Styles.defaultPadding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Statistics',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Styles.defaultYellowColor,
                  ),
                ),
                SizedBox(height: Styles.defaultPadding / 2),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                  child: ListTile(
                    leading: Icon(Icons.people, color: Styles.defaultBlueColor, size: 20),
                    title: Text(
                      'Total Users',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultYellowColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      stats['totalUsers']?.toString() ?? '0',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultLightWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                  child: ListTile(
                    leading: Icon(Icons.credit_card, color: Styles.defaultBlueColor, size: 20),
                    title: Text(
                      'Total Cards',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultYellowColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      stats['totalCards']?.toString() ?? '0',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultLightWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                  child: ListTile(
                    leading: Icon(Icons.watch, color: Styles.defaultBlueColor, size: 20),
                    title: Text(
                      'Total Bracelets',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultYellowColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      stats['totalBracelets']?.toString() ?? '0',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultLightWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                  child: ListTile(
                    leading: Icon(Icons.payment, color: Styles.defaultBlueColor, size: 20),
                    title: Text(
                      'Total Payments',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultYellowColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      stats['totalPayments']?.toString() ?? '0',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultLightWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: Styles.defaultBlueColor, size: 20),
                    title: Text(
                      'Total Locations',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultYellowColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      stats['totalLocations']?.toString() ?? '0',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: Styles.defaultLightWhiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

// Custom Sliver Delegate for TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Styles.scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}