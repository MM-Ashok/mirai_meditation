import 'dart:async';
import 'dart:io';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'detail_page.dart';
import 'program_detail_page.dart';
import 'theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert' show json;
import 'package:flutter_stripe/flutter_stripe.dart';

//async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/.env');
    print(".env file loaded");
  } catch (e) {
    print('!Error .env file loading error =>  $e');
  }
  
  Stripe.publishableKey = 'pk_test_51Px58MGj3R37BVZgxcjRb42V2ijPnlRqhv5NK3bGl3zeThiFMRYV6iFvYaW7Gyg52JbAmYe9K0T3Hbp3zhQqWFAj00qJBBjyUI';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.selectedTheme,
      title: 'Positive Thinking Meditation',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MyFirstScreen(),
    const StoreProgram(),
    const DarkLightThemePage(),
    const SupportPage(),
    const Text('comment Page'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Positive Thinking Meditation')),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support),
            label: 'Support',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Comment',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyFirstScreen extends StatefulWidget {
  const MyFirstScreen({super.key});
  
  @override
  _MyFirstScreenState createState() => _MyFirstScreenState();
}

class _MyFirstScreenState extends State<MyFirstScreen> {
  late AudioPlayer _audioPlayer;

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/available_audio.txt');
  }
  
  Future<String> getAvailabletrack() async {
    // return await rootBundle.loadString('lib/assets/.available_audio');
    // final directory = await getApplicationDocumentsDirectory();
    final file = await getFile();
    return file.readAsString();
    // return await rootBundle.loadString('${directory.path}/available_audio.txt');
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
  }
  
  void _playAudio(String url) async {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      _audioPlayer.play();  // No need to assign the result
      print('Audio started successfully');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

    @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the audio player when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2, // Define the number of tabs
        child: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1DsDkojnO6uVctvIY4zoB5fmFO_FztGNLl1HF2CQwCQ&s'),
                ),
              ),
              SliverFillRemaining(
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Play List'), // Define each tab
                        Tab(text: 'Tracks'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Define the content for each tab
                          const Center(child: Text('Content for Tab 1')),
                          // Center(child: Text('Content for Tab 2')),
                          FutureBuilder<String>(
                            future: getAvailabletrack(), // Pass the future that fetches the data
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Show loading spinner
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}'); // Show error if any
                              } else if (snapshot.hasData) {
                                List<dynamic> decodedList = json.decode(snapshot.data!);
                                List<Map<String, dynamic>> videoList = decodedList.map((e) => e as Map<String, dynamic>).toList();
                                // return Text('Data: ${snapshot.data}'); // Show fetched data
                                return ListView.builder(
                                  itemCount: videoList.length,
                                  itemBuilder: (context, index) {
                                    final video = videoList[index];
                                    return ListTile(
                                      title: Text(video['title']),
                                      leading: const Icon(Icons.audio_file),
                                      onTap: () {
                                        Directory directory = Directory('/storage/emulated/0/Download');
                                        String filename = video['file'];
                                        String audioUrl = '${directory.path}/$filename';
                                        print(audioUrl);
                                        // String audioUrl = 'https://www.example.com/audio.mp3'; // Replace with your audio URL
                                        _playAudio(audioUrl);
                                        // Handle video item tap if needed
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Tapped on ${video['title']}')),
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const Text('No data available'); // Handle empty state
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreProgram extends StatefulWidget {
  const StoreProgram({super.key});
  @override
  _StoreProgram createState() => _StoreProgram();
}

class _StoreProgram extends State<StoreProgram> {
  @override
  Widget build(BuildContext context) {
    String PROGRAM =  dotenv.env['PROGRAM']?? 'No Program Available';
    final List<dynamic> programList = json.decode(PROGRAM.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('All programs')),
      ),
      body: ListView.builder(
          itemCount: programList.length,
          itemBuilder: (context, index) {
            var program = programList[index];
            String programName = program['name'] ?? 'sample program';
            double price;
            String sprice;

            if (program['status'] == "free") {
              price = double.parse('00');
              sprice = '\nPrice :- This program is FREE';
            } else {
              price = double.parse(program['price']);
              sprice = '\nPrice :- \$' + program['price'];
            }

            // Now you can safely use sprice here:
            String shortDescription = program['shortDescription'] + ' ' + sprice;
            String fullDescription = program['description'] ?? 'Full Description';
            String audioFileUrl = program['url'] ?? '';

            return Column(
              children: [
                ListTile(
                  leading: const FlutterLogo(),
                  title: Text(programName),
                  subtitle: Text(shortDescription),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // Ensure onTap is correctly placed and functional
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramDetailPage(
                            programName: programName,
                            fullDescription: fullDescription,
                            price: price,
                            audioFileUrl:audioFileUrl),
                      ),
                    );
                  },
                ),
                const Divider(),
              ],
            );
          }),
    );
  }
}

class SupportPage extends StatelessWidget {
  // Define a list of items
  final List<String> items = const ["FAQ", "Contact", "Download Your Latest Audio Files"];

  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () {
              switch (items[index]) {
                case "FAQ":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScreenFaq()),
                  );
                  break;
                case "Contact":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScreenContact()),
                  );
                  break;
                case "Download Your Latest Audio Files":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DownloadPurchasedAudioFiles()),
                  );
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

class ScreenContact extends StatelessWidget {
  const ScreenContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: const Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text("Names: Matrixinfologics. \nOffice: F4 Indistrial Area"),
      ),
    );
  }
}
class DownloadPurchasedAudioFiles extends StatelessWidget {
  const DownloadPurchasedAudioFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Your Latest Audio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: ElevatedButton(onPressed: (){
            print("Download audio file");
          }, 
          child: const Text('Synch My Latest Purchased Audio Files'),
        ),
      ),
    );
  }
}

class ScreenFaq extends StatefulWidget {
  const ScreenFaq({super.key});

  @override
  _ScreenFaqState createState() => _ScreenFaqState();
}

class _ScreenFaqState extends State<ScreenFaq> {
  // Define a list of items for the accordion
  final List<Item> _data = generateItems(5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Frequently Asked Questions')),
      ),
      body: SingleChildScrollView(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
            title: Text(item.expandedValue),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.more_vert),
            onTap: () {
              // Ensure onTap is correctly placed and functional
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(item: item),
                ),
              );
            },
            onLongPress: () {
              setState(() {
                _data.removeWhere((currentItem) => currentItem == item);
              });
            },
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    String header;
    String content;

    switch (index) {
      case 0:
        header = 'What is Lorem Ipsum?';
        content =
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.';
        break;
      case 1:
        header = 'Why do we use it?';
        content =
            'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).';
        break;
      case 2:
        header = 'Third Panel';
        content = 'Content for the third panel';
        break;
      default:
        header = 'Panel $index';
        content = 'This is the detail for item $index';
        break;
    }

    return Item(
      headerValue: header,
      expandedValue: content,
    );
  });
}

class DarkLightThemePage extends StatelessWidget {
  const DarkLightThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedTheme = themeProvider.selectedTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Favourite Theme"),
      ),
      body: ListView.builder(
        itemCount: themeProvider.themes.length,
        itemBuilder: (context, index) {
          final theme = themeProvider.themes[index];
          final isSelected = theme == selectedTheme;

          return ListTile(
            title: Text(
              'Theme ${index + 1}',
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            tileColor: isSelected
                ? theme.colorScheme.secondary.withOpacity(0.2)
                : null,
            onTap: () {
              themeProvider.setTheme(theme);
            },
          );
        },
      ),
    );
  }
}
