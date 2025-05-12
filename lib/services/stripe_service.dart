import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static void initStripe() {
    Stripe.publishableKey = 'pk_test_51RMWJwR8TekzknDoO0jr0xG7Faym6GLAeLx3s2GTVgUlHbdvvDSALDNgpMnuI86sxIIuRilEtgRgOzmbltc9zVPI00PzlKScJI';
    Stripe.instance.applySettings();
  }
}