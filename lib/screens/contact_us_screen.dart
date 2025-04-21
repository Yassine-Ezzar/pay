import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text(
          'Contactez-Nous',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notre équipe est à votre écoute',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000080), 
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'pour répondre à vos demandes, suggestions ou signalements de bugs.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              _buildContactItem(
                icon: Icons.email,
                title: ' Email',
                subtitle: '',  
              ),
              _buildContactItem(
                icon: Icons.phone,
                title: ' Téléphone',
                subtitle: '',
              ),
              _buildContactItem(
                icon: Icons.chat,
                title: ' Chat en direct',
                subtitle: 'Disponible dans l’application du lundi au vendredi de 9h à 18h.',
              ),
              _buildContactItem(
                icon: Icons.location_on,
                title: ' Adresse postale',
                subtitle: 'SmartBracelet Technologies\n12, Rue de l’Innovation\n75008 Paris, France',
              ),
              _buildContactItem(
                icon: Icons.timer,
                title: ' Temps de réponse estimé',
                subtitle: 'Entre 24h et 48h maximum.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF000080), size: 24), 
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, 
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.black54, 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}