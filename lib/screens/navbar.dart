import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Styles.darkScaffoldBackgroundColor
                  : Styles.scaffoldBackgroundColor,
              Theme.of(context).brightness == Brightness.dark
                  ? Styles.darkScaffoldBackgroundColor
                  : Styles.scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black12
                  : Colors.black54,
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Home', 0, context),
            _buildNavItem(Icons.location_on, 'Location', 1, context),
            _buildNavItem(Icons.wallet, 'Wallet', 2, context),
            _buildNavItem(Icons.person, 'Profile', 3, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, BuildContext context) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Styles.darkDefaultBlueColor.withOpacity(0.2)
                  : Styles.defaultBlueColor.withOpacity(0.2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultBlueColor
                      : Styles.defaultBlueColor)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Styles.darkDefaultBlueColor.withOpacity(0.9)
                      : Styles.defaultBlueColor.withOpacity(0.9)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultBlueColor
                        : Styles.defaultBlueColor)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Styles.darkDefaultBlueColor.withOpacity(0.9)
                        : Styles.defaultBlueColor.withOpacity(0.9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}