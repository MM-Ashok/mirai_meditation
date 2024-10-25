import 'dart:convert';

import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
// import 'package:maditation/config.dart';
import 'package:maditation/widgets/example_scaffold.dart';
import 'package:maditation/widgets/loading_button.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/services.dart' show rootBundle;

// import '.env.available_audio.dart';
// import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class WebhookPaymentScreen extends StatefulWidget {
  final double price;
  final String audioFileUrl;
  const WebhookPaymentScreen(
      {super.key, required this.price, required this.audioFileUrl});

  @override
  _WebhookPaymentScreenState createState() =>
      _WebhookPaymentScreenState(price: price, audioFileUrl: audioFileUrl);
}

class _WebhookPaymentScreenState extends State<WebhookPaymentScreen> {
  _WebhookPaymentScreenState({required this.price, required this.audioFileUrl});
  CardFieldInputDetails? _card;
  String _email = 'email@stripe.com';
  final bool _saveCard = false;

  final double price;
  final String audioFileUrl;
  bool _isPaymentSuccess = false;

  late Dio dio; // Declare Dio instance

  @override
  void initState() {
    super.initState();
    dio = Dio(); // Initialize Dio

   }

  @override
  Widget build(BuildContext context) {
    if (price == 0) {
      _isPaymentSuccess = true;
    }

MaterialColor buttonColor = (_card?.complete == false && _email.isNotEmpty)
    ? Colors.green // This is fine as Colors.green is a MaterialColor
    : Colors.red; // Change this to a MaterialColor as well
   return ExampleScaffold(
      title: 'Please provide your card details',
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        TextFormField(
          initialValue: _email,
          decoration:
              const InputDecoration(hintText: 'Email', labelText: 'Email'),
          onChanged: (value) {
            setState(() {
              _email = value;
            });
          },
        ),
        const SizedBox(height: 20),
        CardField(
          preferredNetworks: const [CardBrand.Amex],
          enablePostalCode: true,
          countryCode: 'US',
          postalCodeHintText: 'postal code',
          onCardChanged: (card) {
            setState(() {
              _card = card;
            });
          },
        ),
        const SizedBox(height: 20),
        if (!_isPaymentSuccess)
          LoadingButton(
            onPressed: _card?.complete == true ? _handlePayPress : null,
            text: 'Pay',
            // color: Colors.green, // Set background color
            color: buttonColor, // Use the dynamically determined color
            textColor: Colors.white,
          ),
        const SizedBox(height: 20),
        if (_isPaymentSuccess)
          ElevatedButton(
            onPressed: () async {
              await dotenv.load(fileName: 'assets/.env');
              // Fetching program data from the .env file
              String programJson =
                  dotenv.env['PROGRAM'] ?? '[]'; // Fallback to an empty list

              // Parsing the JSON to extract the programs
              List<dynamic> programList = jsonDecode(programJson);
              String baseUrl = dotenv.env['SERVER_BASE_URL'] ?? "";

              if (programList.isNotEmpty) {
                var firstProgram =
                    programList[0];   }
              if (audioFileUrl.contains(",")) {
                List<String> downloadUrls = audioFileUrl.split(",");
                int totalFileToDownload = downloadUrls.length;
                print(
                    "This is multiple url contain =========> $totalFileToDownload");
                print(downloadUrls);
                int inc = 0;
                for (String filePath in downloadUrls) {
                  inc++;
                  String url = filePath;
                  String filename = filePath.replaceAll(baseUrl, "");
                  await downloadMultipleFile(
                      url, filename, inc, totalFileToDownload);
                  await updatePurchasedAudioListing(
                      "available_audio.txt", filePath);
                }
              } else {
                String url = audioFileUrl;
                String filename = audioFileUrl.replaceAll(baseUrl, "");
                await downloadFile(url, filename);
                await updatePurchasedAudioListing(
                    "available_audio.txt", audioFileUrl);
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Success!: Your download completed successfully!')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:Colors.green,
              foregroundColor:Colors.white // Set the background color to green
            ),
            child: const Text('Download File'),
          ),
      ],
    );
  }

  Future<void> _handlePayPress() async {
    if (_card == null) {
      return;
    }

    try {
      // 1. fetch Intent Client Secret from backend
      final clientSecret = await fetchPaymentIntentClientSecret();
      print("clientSecret =================>");
      print(clientSecret);
      if (clientSecret.containsKey('error')) {
        throw Exception("Client secret is null");
      } else {
        // 2. Gather customer billing information (ex. email)
        final billingDetails = BillingDetails(
          email: _email,
          phone: '',
          address: const Address(
            city: '',
            country: 'US',
            line1: '',
            line2: '',
            state: '',
            postalCode: '',
          ),
        ); // mo mocked data for tests

        // 3. Confirm payment with card details
        final paymentIntent = await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret['clientSecret'],
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ),
          options: PaymentMethodOptions(
            setupFutureUsage:
                _saveCard == true ? PaymentIntentsFutureUsage.OffSession : null,
          ),
        );

        setState(() {
          _isPaymentSuccess = true; // Mark payment as successful
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Success!: The payment was confirmed successfully!')));

        final saveRecordsForFuture = await saveRecordsForFutureSave();
        // if(saveRecordsForFuture){ print("===> Payment record inserted in DB successfully<==="); } else { print("===>Payment record NOT inserted in DB successfully<==="); }
      }
    } catch (e) {
      print("!Error:: $e");
    }
  }

  final SupabaseClient supabase = Supabase.instance.client;
  Future<bool> saveRecordsForFutureSave() async {
    const String program = "Testing";
    final double amount = price ?? 00.00;
    final String cstEmail = _email ?? "stripe_test@stripe.com";
    final String audio = audioFileUrl ?? "NULL";
    final response = await supabase
        .from('meditation') // Replace with your table name
        .insert({
          'customer_email':
              cstEmail, // Replace with your column names and values
          'purchased_program': audio,
          'amount_paid': amount,
        })
        .select()
        .maybeSingle();

    if (response.error == null) {
      print('Data inserted: ${response.data}');
      return true;
    } else {
      print('Error: ${response.error.message}');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    int amount = (price * 100).toInt();
    await dotenv.load(fileName: 'assets/.env');
    // final url = Uri.parse('http://192.168.1.8:3000/create-payment-intenty');
    final url = Uri.parse(dotenv.env['PAYMENT_INTENT_URL']!);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'currency': 'usd',
        'amount': amount,
        'payment_method_types': ['card'],
        'request_three_d_secure': 'any',
      }),
    );
    print("response.body");
    print(response.body);
    return json.decode(response.body);
  }

  Future<String> _getFilePath(String fileName) async {
    // Get the app's document directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return '$appDocPath/$fileName';
  }

  double progress = 0.0;
  Future<void> downloadFile(String url, String filename) async {
    try {
      var audioStatus = await Permission.audio.request(); // For audio files
      if (audioStatus.isGranted) {
        // if (await Permission.storage.request().isGranted) { // this will work with less then Android 13
        String filePath = await _getFilePath(filename);
        startDownloadWithProgress(context) async {
          ProgressDialog pd = ProgressDialog(context: context);
          pd.show(
              max: 100,
              msg: 'Audio Downloading...',
              completed: Completed(),
              progressType: ProgressType.valuable,
              backgroundColor: const Color(0xff212121),
              progressValueColor: const Color(0xff3550B4),
              progressBgColor: Colors.white70,
              msgColor: Colors.white,
              valueColor: Colors.white);
          String filePath = await _getFilePath(filename);
          List<String> audioTrackNamePart = filename.split("/");
          String audioTitle = audioTrackNamePart.last.replaceAll(".mp3", "");
          await dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                setState(() {
                  progress = (received / total * 100); // Update progress
                });
                print(
                    "${(received / total * 100).toStringAsFixed(0)}% downloaded");
                print("${progress.toStringAsFixed(0)}% downloaded");
                int progressLevel = (received / total * 100).toInt();
                pd.update(
                    value: progressLevel, msg: "Downloading $audioTitle Audio");
                // (context as Element).markNeedsBuild();
              }
            },
          );
          print('File saved to $filePath');
        }

        await startDownloadWithProgress(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error!: Permission Denied')));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> downloadMultipleFile(
      String url, String filename, int inc, int totalFileToDownload) async {
    try {
      // if (await Permission.storage.request().isGranted) {
      var audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) {
        String filePath = await _getFilePath(filename);
        startDownloadWithProgress(context) async {
          ProgressDialog pd = ProgressDialog(context: context);
          pd.show(
              max: 100,
              msg: 'Audio Downloading...',
              completed: Completed(
                  completedMsg: "$inc/$totalFileToDownload Files Done"),
              progressType: ProgressType.valuable,
              backgroundColor: const Color(0xff212121),
              progressValueColor: const Color(0xff3550B4),
              progressBgColor: Colors.white70,
              msgColor: Colors.white,
              valueColor: Colors.white);
          String filePath = await _getFilePath(filename);
          List<String> audioTrackNamePart = filename.split("/");
          String audioTitle = audioTrackNamePart.last.replaceAll(".mp3", "");
          await dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                setState(() {
                  progress = (received / total * 100); // Update progress
                });
                print(
                    "${(received / total * 100).toStringAsFixed(0)}% downloaded");
                print("${progress.toStringAsFixed(0)}% downloaded");
                int progressLevel = (received / total * 100).toInt();
                pd.update(
                    value: progressLevel,
                    msg: "Downloading $inc/$totalFileToDownload Files");
              }
            },
          );
          print('File saved to $filePath');
          pd.close();
        }

        await startDownloadWithProgress(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error!: Permission Denied')));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /*void _showDownloadProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by clicking outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Downloading...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please wait while the file is being downloaded.'),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 10),
              Text('${(progress * 100).toStringAsFixed(0)}% completed'),
            ],
          ),
        );
      },
    );
  }*/

  Future<void> updatePurchasedAudioListing(
      String filename, String audioFileUrl) async {
    try {
      List<String> audioTrackNamePart = audioFileUrl.split("/");
      String audioTitle = audioTrackNamePart.last.replaceAll(".mp3", "");
      String fileContent = await readFromFile(filename) ?? '';

      List<dynamic> oldAudioTrack = json.decode(fileContent.toString());
      oldAudioTrack.add({"title": audioTitle, "file": audioTrackNamePart.last});
      String updatedAudioTrack = json.encode(oldAudioTrack);
      print(updatedAudioTrack);
      await writeToFile(filename, updatedAudioTrack);
    } catch (e) {
      print("!ERROR:: $e");
    }
  }

  Future<String?> readFromFile(String filename) async {
    // For web, use localStorage

    // For emulator
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/available_audio.txt');
      return await file.readAsString(); // Read the file as a string
    } catch (e) {
      print("Error reading file: $e");
      return "Error loading file";
    }
  }

  Future<void> writeToFile(String filename, String content) async {
    // for emulator
    try {
      final directory = await getApplicationDocumentsDirectory();
      print(
          'write into File located at =================> ${directory.path}/$filename');
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      print('Data written to file: $content');
    } catch (e) {
      print("Error writing file: $e");
    }
  }
}
