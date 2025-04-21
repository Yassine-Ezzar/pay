import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Politique de Confidentialité',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Styles.defaultPadding),
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Politique de Confidentialité',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'La sécurité de vos données est une priorité. Cette politique de confidentialité explique les informations que nous collectons, comment nous les utilisons et comment nous les protégeons.\n\n'
                '📍 Données collectées\n'
                'Nous collectons les données suivantes :\n'
                '- Informations personnelles (nom, adresse email)\n'
                '- Données GPS (pour la localisation du bracelet)\n'
                '- Historique des paiements (liés à l’utilisation du bracelet RFID)\n\n'
                '🔐 Utilisation des données\n'
                'Les données servent uniquement à :\n'
                '- Gérer vos transactions\n'
                '- Suivre la position de votre bracelet\n'
                '- Améliorer nos services et notre support client\n\n'
                '🔒 Sécurité\n'
                'Nous utilisons un chiffrement avancé pour stocker vos données et empêchons tout accès non autorisé. Nos serveurs sont hébergés dans des centres certifiés et conformes au RGPD.\n\n'
                '📤 Partage de données\n'
                'Aucune donnée n’est vendue. Certaines informations peuvent être partagées avec des prestataires de services (paiement, maintenance), mais toujours sous accord de confidentialité strict.\n\n'
                '🗑️ Suppression de vos données\n'
                'Vous pouvez demander à tout moment la suppression de vos données personnelles via les paramètres de votre compte.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
         
            ],
          ),
        ),
      ),
    );
  }
}