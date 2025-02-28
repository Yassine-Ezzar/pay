import 'package:app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.scaffoldBackgroundColor, // Fond principal (0xFF7098da)
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône de validation avec effet d'ombre
              Container(
                padding: EdgeInsets.all(Styles.defaultPadding * 1.5), // Padding légèrement augmenté
                decoration: BoxDecoration(
                  color: Styles.defaultYellowColor, // Blanc (0xFFFFFFFF)
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Styles.defaultGreyColor.withOpacity(0.3), // Ombre douce (0xFF477bd0)
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  size: 50, // Taille augmentée pour plus d'impact
                  color: Styles.defaultBlueColor, // Bleu clair (0xFF98b5e4)
                ),
              ),
              SizedBox(height: Styles.defaultPadding * 2), // Espacement cohérent
              // Texte principal avec style Rubik Bold
              Text(
                'WELL DONE!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Styles.defaultYellowColor, // Blanc (0xFFFFFFFF) pour contraste
                  letterSpacing: 1.2, // Légère séparation des lettres
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Styles.defaultPadding),
              // Sous-texte pour ajouter un message amical
              Text(
                'Welcome to SmartPay!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18,
                  color: Styles.defaultLightWhiteColor, // Couleur claire (0xFFa1d0ff)
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Styles.defaultPadding * 3), // Plus d'espace avant le bouton
              // Bouton GET STARTED avec animation
              GestureDetector(
                onTap: () => Get.offNamed('/home'), // Navigation avec GetX
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Styles.defaultPadding,
                    horizontal: Styles.defaultPadding * 2.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Styles.defaultGreyColor, // Début (0xFF477bd0)
                        Styles.defaultBlueColor, // Fin (0xFF98b5e4)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: Styles.defaultBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Styles.defaultGreyColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Styles.defaultYellowColor, // Texte blanc (0xFFFFFFFF)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}