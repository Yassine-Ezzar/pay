import 'package:flutter/material.dart';
import 'package:app/styles/styles.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Aide & Support',
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
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
                'Nous sommes là pour vous aider',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Vous avez une question ou vous rencontrez un problème avec votre bracelet ou l\'application ? Nous sommes là pour vous aider à chaque étape.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              // Technical Issues Section
              Row(
                children: [
                  Icon(Icons.build, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Problèmes techniques',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Vous rencontrez un bug ? Votre bracelet ne se connecte pas correctement ou vous avez un souci lors d’un paiement ? Consultez notre FAQ pour des solutions rapides ou contactez notre support technique.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              // Usage Guide Section
              Row(
                children: [
                  Icon(Icons.book, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Guide d’utilisation',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Accédez à nos tutoriels détaillés pour apprendre à activer votre bracelet, ajouter un moyen de paiement, ou encore utiliser la géolocalisation pour retrouver votre bracelet perdu.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
             
              SizedBox(height: 20),
              // Personalized Assistance Section
              Row(
                children: [
                  Icon(Icons.support_agent, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Assistance personnalisée',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Si votre problème persiste ou si vous avez une question spécifique, notre équipe vous répond dans les plus brefs délais par mail ou via le chat intégré à l’application. Notre support est disponible 24h/24, 7j/7 pour vous offrir une assistance rapide et efficace.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              // Contact Section
              Row(
                children: [
                  Icon(Icons.email, color: Color(0xFF000080), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Besoin de plus d’aide ?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Visitez notre site web à www.sbi.com ou contactez-nous à SBI@gmail.com.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Color(0xFF000080),
        ),
      ),
      iconColor: const Color(0xFF000080),
      collapsedIconColor: const Color(0xFF000080),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}