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

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
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
      Get.snackbar('Success', 'User deleted',
          backgroundColor: Styles.defaultBlueColor, colorText: Colors.white);
      _fetchData();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
    }
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      await ApiService.deleteCardAdmin(cardId);
      Get.snackbar('Success', 'Card deleted',
          backgroundColor: Styles.defaultBlueColor, colorText: Colors.white);
      _fetchData();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
    }
  }

  Future<void> _deleteBracelet(String braceletId) async {
    try {
      await ApiService.deleteBraceletAdmin(braceletId);
      Get.snackbar('Success', 'Bracelet deleted',
          backgroundColor: Styles.defaultBlueColor, colorText: Colors.white);
      _fetchData();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Styles.defaultRedColor, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: Styles.defaultBlueColor,
          child: errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load data: $errorMessage',
                        style: TextStyle(
                          fontFamily: 'Poppins',
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
                          shape: RoundedRectangleBorder(
                              borderRadius: Styles.defaultBorderRadius),
                          padding: EdgeInsets.symmetric(
                              horizontal: Styles.defaultPadding,
                              vertical: Styles.defaultPadding / 2),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: FadeInDown(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              Styles.defaultPadding / 2,
                              Styles.defaultPadding * 2,
                              Styles.defaultPadding / 2,
                              Styles.defaultPadding / 2),
                          color: Styles.cardBackgroundColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Welcome, $adminName',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.defaultBlueColor,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.logout,
                                    color: Styles.defaultBlueColor, size: 20),
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            Styles.defaultPadding,
                            Styles.defaultPadding,
                            Styles.defaultPadding,
                            Styles.defaultPadding / 2),
                        child: Text(
                          'Overview',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF063B87), 
                          ),
                        ),
                      ),
                    ),
                    // Stats Grid
                    SliverToBoxAdapter(
                      child: FadeInUp(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Styles.defaultPadding),
                          child: isLoadingStats
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: Styles.defaultBlueColor))
                              : GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: Styles.defaultPadding / 2,
                                  mainAxisSpacing: Styles.defaultPadding / 2,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildStatCard('Users',
                                        stats['totalUsers']?.toString() ?? '0', Icons.people),
                                    _buildStatCard('Cards',
                                        stats['totalCards']?.toString() ?? '0', Icons.credit_card),
                                    _buildStatCard('Bracelets',
                                        stats['totalBracelets']?.toString() ?? '0', Icons.watch),
                                    _buildStatCard('Payments',
                                        stats['totalPayments']?.toString() ?? '0', Icons.payment),
                                    _buildStatCard('Locations',
                                        stats['totalLocations']?.toString() ?? '0', Icons.location_on),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            Styles.defaultPadding,
                            Styles.defaultPadding,
                            Styles.defaultPadding,
                            Styles.defaultPadding / 2),
                        child: Text(
                          'Analytics',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF063B87), 
                          ),
                        ),
                      ),
                    ),
                    // Charts
                    SliverToBoxAdapter(
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Styles.defaultPadding),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final chartHeight =
                                  constraints.maxWidth < 600 ? 160.0 : 200.0;
                              return Column(
                                children: [
                                  Container(
                                    height: chartHeight,
                                    child: _buildGenderPieChart(),
                                  ),
                                  SizedBox(height: Styles.defaultPadding / 2),
                                  Container(
                                    height: chartHeight,
                                    child: _buildLineChart(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            Styles.defaultPadding,
                            Styles.defaultPadding,
                            Styles.defaultPadding,
                            Styles.defaultPadding / 2),
                        child: Text(
                          'Details',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF063B87), 
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
                          labelColor: Styles.defaultBlueColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Styles.defaultBlueColor,
                          labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
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
        color: Styles.cardBackgroundColor,
        padding: EdgeInsets.all(Styles.defaultPadding / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Styles.defaultBlueColor.withOpacity(0.1),
              child: Icon(icon, color: Styles.defaultBlueColor, size: 20),
            ),
            SizedBox(height: Styles.defaultPadding / 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Styles.defaultBlueColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Styles.defaultLightWhiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPieChart() {
    final genderStats = stats['genderStats'] as Map<String, dynamic>? ?? {};
    final total = (genderStats['Male'] ?? 0) +
        (genderStats['Female'] ?? 0) +
        (genderStats['NotSpecified'] ?? 0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
      child: Container(
        color: Styles.cardBackgroundColor,
        padding: EdgeInsets.all(Styles.defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender Distribution',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063B87), // Explicitly set to #063b87
              ),
            ),
            SizedBox(height: Styles.defaultPadding / 2),
            Expanded(
              child: total == 0
                  ? Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.blue,
                            value: (genderStats['Male'] ?? 0).toDouble(),
                            title:
                                'Male\n${((genderStats['Male'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.pink,
                            value: (genderStats['Female'] ?? 0).toDouble(),
                            title:
                                'Female\n${((genderStats['Female'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.grey,
                            value: (genderStats['NotSpecified'] ?? 0).toDouble(),
                            title:
                                'N/A\n${((genderStats['NotSpecified'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 20,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
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
      userTrend.addAll([0, 0, 0, 0, 0, 0, 0]);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
      child: Container(
        color: Styles.cardBackgroundColor,
        padding: EdgeInsets.all(Styles.defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Registration Trend',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063B87), // Explicitly set to #063b87
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
                      color: Colors.grey.withOpacity(0.2),
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
                            fontFamily: 'Poppins',
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
                            fontFamily: 'Poppins',
                            color: Styles.defaultLightWhiteColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      color: Styles.defaultBlueColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Styles.defaultBlueColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: (userTrend.isEmpty
                      ? 10
                      : userTrend.reduce((a, b) => a > b ? a : b) + 5),
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
        ? Center(child: CircularProgressIndicator(color: Styles.defaultBlueColor))
        : users.isEmpty
            ? Center(
                child: Text(
                  'No users found.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Styles.defaultBlueColor,
                        child: Text(
                          user['name']?.toString()[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        user['name']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Joined: ${DateTime.tryParse(user['createdAt'] ?? '')?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: Styles.defaultRedColor, size: 20),
                        onPressed: () =>
                            _deleteUser(user['_id']?.toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildCardsTab() {
    return isLoadingCards
        ? Center(child: CircularProgressIndicator(color: Styles.defaultBlueColor))
        : cards.isEmpty
            ? Center(
                child: Text(
                  'No cards found.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.credit_card,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Card: ${card['cardNumber']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'User: ${card['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: Styles.defaultRedColor, size: 20),
                        onPressed: () =>
                            _deleteCard(card['_id']?.toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildBraceletsTab() {
    return isLoadingBracelets
        ? Center(child: CircularProgressIndicator(color: Styles.defaultBlueColor))
        : bracelets.isEmpty
            ? Center(
                child: Text(
                  'No bracelets found.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.watch,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        bracelet['name']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'User: ${bracelet['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: Styles.defaultRedColor, size: 20),
                        onPressed: () => _deleteBracelet(
                            bracelet['braceletId']?.toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildPaymentsTab() {
    return isLoadingPayments
        ? Center(child: CircularProgressIndicator(color: Styles.defaultBlueColor))
        : payments.isEmpty
            ? Center(
                child: Text(
                  'No payments found.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.payment,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        payment['merchant']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Amount: \$${payment['amount']?.toStringAsFixed(2) ?? '0.00'}\nUser: ${payment['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
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
        ? Center(child: CircularProgressIndicator(color: Styles.defaultBlueColor))
        : locations.isEmpty
            ? Center(
                child: Text(
                  'No locations found.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.location_on,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Bracelet ID: ${location['braceletId']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Lat: ${location['latitude']?.toString() ?? 'N/A'}, Lon: ${location['longitude']?.toString() ?? 'N/A'}\nUser: ${location['userId']?['name']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
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
    final genderStats = stats['genderStats'] as Map<String, dynamic>? ?? {};
    final countryStats = stats['countryStats'] as Map<String, dynamic>? ?? {};

    return isLoadingStats
        ? Center(child: CircularProgressIndicator(color: Styles.defaultBlueColor))
        : Padding(
            padding: EdgeInsets.all(Styles.defaultPadding / 2),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Statistics',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063B87), 
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding / 2),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.people,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Total Users',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        stats['totalUsers']?.toString() ?? '0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.credit_card,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Total Cards',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        stats['totalCards']?.toString() ?? '0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.watch,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Total Bracelets',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        stats['totalBracelets']?.toString() ?? '0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.payment,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Total Payments',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        stats['totalPayments']?.toString() ?? '0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: ListTile(
                      leading: Icon(Icons.location_on,
                          color: Styles.defaultBlueColor, size: 20),
                      title: Text(
                        'Total Locations',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        stats['totalLocations']?.toString() ?? '0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Styles.defaultLightWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding / 2),
                  Text(
                    'Gender Distribution',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063B87), // Explicitly set to #063b87
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding / 4),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.male,
                              color: Styles.defaultBlueColor, size: 20),
                          title: Text(
                            'Male',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultBlueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            genderStats['Male']?.toString() ?? '0',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultLightWhiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.female,
                              color: Styles.defaultBlueColor, size: 20),
                          title: Text(
                            'Female',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultBlueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            genderStats['Female']?.toString() ?? '0',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultLightWhiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.help_outline,
                              color: Styles.defaultBlueColor, size: 20),
                          title: Text(
                            'Not Specified',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultBlueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            genderStats['NotSpecified']?.toString() ?? '0',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultLightWhiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding / 2),
                  Text(
                    'Country Distribution',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF063B87), // Explicitly set to #063b87
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding / 4),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: Styles.defaultBorderRadius),
                    child: Column(
                      children: countryStats.entries.map((entry) {
                        return ListTile(
                          leading: Icon(Icons.public,
                              color: Styles.defaultBlueColor, size: 20),
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultBlueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Styles.defaultLightWhiteColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

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