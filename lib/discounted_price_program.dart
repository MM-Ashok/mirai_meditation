import 'package:flutter/material.dart';
import 'webhook_payment_screen.dart';
// Ensure you import the main.dart file where Item is defined

class DiscountProgramDetailPage extends StatelessWidget {
  final String singerLogo;
  final String programName;
  final String fullDescription;
  final String audioFileUrl;
  final double price;

  const DiscountProgramDetailPage(
      {super.key,
      required this.singerLogo,
      required this.programName,
      required this.fullDescription,
      required this.price,
      required this.audioFileUrl});

  @override
  Widget build(BuildContext context) {
    String discountLogo = "assets/singers/$singerLogo";
    return Scaffold(
      appBar: AppBar(
        title: Text(programName),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: <Widget>[
            Image.asset(
              discountLogo,  // Path to your image
              width: 100,  // Width of the image
              height: 100, // Height of the image
              fit: BoxFit.cover, // How the image should fit
            ),
            Text(
              fullDescription,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Price: \$${price.toStringAsFixed(2)}', // Displaying the price with the $ symbol
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StripeButton(price:price,audioFileUrl:audioFileUrl,
              onPressed: () {
                print("we on stripe button");
              },
            ),
          ])),
    );
  }
}

class StripeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double price;
  final String audioFileUrl;

  const StripeButton({super.key, required this.price,required this.audioFileUrl,required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    print(audioFileUrl);
    String buttonLabel = "\$$price will be charged on your card";
    return ElevatedButton(
          child: Text(buttonLabel),
          style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                 foregroundColor: Colors.white, // Set the background color to green
              ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WebhookPaymentScreen(price:price,audioFileUrl:audioFileUrl)),
            );
          },
        );
  }
}