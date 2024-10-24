import 'dart:async';
import 'dart:io';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'detail_page.dart';
import 'program_detail_page.dart';
import 'discounted_price_program.dart';
import 'theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert' show json;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';


import 'dart:convert';

//async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/.env');
    print(".env file loaded");
    await Supabase.initialize(
      // url: 'https://yskweoqjrboywsxsrwap.supabase.co',
      // anonKey:
      //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlza3dlb3FqcmJveXdzeHNyd2FwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3MjY2MjcsImV4cCI6MjA0MjMwMjYyN30.QmMzNRvnqzAcK5sEjnF9jYAiXBuIcvciMdIgYSRo1S8',
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    print("database connect successfull");
  } catch (e) {
    print('!Error .env file loading error =>  $e');
  }

  // Stripe.publishableKey =
  //     'pk_test_51Px58MGj3R37BVZgxcjRb42V2ijPnlRqhv5NK3bGl3zeThiFMRYV6iFvYaW7Gyg52JbAmYe9K0T3Hbp3zhQqWFAj00qJBBjyUI';
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // Stripe.urlScheme = 'flutterstripe';

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  Stripe.merchantIdentifier = dotenv.env['STRIPE_MERCHANT_IDENTIFIER']!;
  Stripe.urlScheme = dotenv.env['STRIPE_URL_SCHEME']!;
  await Stripe.instance.applySettings();

  runApp(
    provider.ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.selectedTheme,
      // title: 'Positive Thinking Meditation',
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
    const Text('Comming Soon'),
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
            icon: Icon(Icons.color_lens),
            label: 'Theme',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support),
            label: 'Support',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.comment),
          //   label: 'Comment',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class Playlist {
  String name;
  List<dynamic> tracks;

  Playlist({required this.name, required this.tracks});
}

class MyFirstScreen extends StatefulWidget {
  const MyFirstScreen({super.key});

  @override
  _MyFirstScreenState createState() => _MyFirstScreenState();
}

class _MyFirstScreenState extends State<MyFirstScreen> {
  late File _file;
  late AudioPlayer _audioPlayer;
  String? currentAudioUrl;

  List<Playlist> playlists = []; // List to store created playlists
  String newPlaylistName = '';

  Future<List<dynamic>> _getAvailableAudioTrack() async {
    try {
   
        // For emulator
        final directory = await getApplicationDocumentsDirectory();
        _file = File('${directory.path}/available_audio.txt');
        if (!(await _file.exists())) {
          final data = await rootBundle.load('lib/assets/available_audio.txt');
          final bytes = data.buffer.asUint8List();
          await _file.writeAsBytes(bytes);
          print('File copied to: ${_file.path}');
          String content =
              await _file.readAsString(); // Read the file as a string
          return json.decode(content);
        } else {
          String content =
              await _file.readAsString(); // Read the file as a string
          return json.decode(content);
        }
   
    } catch (e) {
      print('Error reading or parsing file: $e');
      return [];
    }
  }

// create a playlist
  void _createPlaylist(String name) {
    setState(() {
      playlists.add(Playlist(name: name, tracks: []));
      _savePlaylists();
    });
  }

  // add tracks to the selected playlist
  // void _addTrackToPlaylist(Playlist playlist, Map<String, dynamic> track) {
  //   setState(() {
  //     playlist.tracks.add(track);
  //     print(
  //         'Added ${track['title']} to ${playlist.name}. Current tracks: ${playlist.tracks}');
  //     _savePlaylists();
  //   });
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('${track['title']} added to ${playlist.name}')),
  //   );
  // }

  void _addTrackToPlaylist(Playlist playlist, Map<String, dynamic> track) {
  if (!playlist.tracks.any((existingTrack) => existingTrack['title'] == track['title'])) {
    setState(() {
      playlist.tracks.add(track);
      print(
          'Added ${track['title']} to ${playlist.name}. Current tracks: ${playlist.tracks}');
      _savePlaylists();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${track['title']} added to ${playlist.name}')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${track['title']} is already in ${playlist.name}')),
    );
  }
}

// dialog box for creating playlist
  void _showCreatePlaylistDialog() {
    String playlistName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Playlist'),
          content: TextField(
            onChanged: (value) {
              playlistName = value;
            },
            decoration: const InputDecoration(hintText: "Enter playlist name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Create"),
              onPressed: () {
                if (playlistName.isNotEmpty) {
                  _createPlaylist(playlistName);
                  Navigator.of(context).pop();
                }
              },
            ),
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//   // For saving  playlists
Future<void> _savePlaylists() async {
  try {
    // For emulator
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/available_playlist.txt');
    
    // Check if the file exists before reading
    if (!(await file.exists())) {
      await file.create(recursive: true);
      await file.writeAsString(json.encode({'audio_tracks': [], 'playlists': []}));
    }

    String content = await file.readAsString();
    
    // Parse the existing content
    Map<String, dynamic> existingData;
    try {
      existingData = json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      // If parsing fails, initialize with default structure
      existingData = {'audio_tracks': [], 'playlists': []};
    }

    List<Map<String, dynamic>> playlistsData = playlists.map((playlist) {
      return {
        'name': playlist.name,
        'tracks': playlist.tracks,
      };
    }).toList();

    // Combine existing audio tracks with the new playlists
    Map<String, dynamic> combinedData = {
      'audio_tracks': existingData['audio_tracks'] ?? [],
      'playlists': playlistsData,
    };

    await file.writeAsString(json.encode(combinedData));
    print('Playlists saved successfully!');
  } catch (e) {
    print('Error saving playlists: $e');
  }
}

// For load playlists
  Future<void> _loadPlaylists() async {
    try {
        //for emulator
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/available_playlist.txt');

        if (await file.exists()) {
          // Read the content from the file
          String content = await file.readAsString();
          Map<String, dynamic> combinedData = json.decode(content);

          // Load the playlists from the 'playlists' section of the file
          List<dynamic> jsonPlaylists = combinedData['playlists'] ?? [];

          // Update the playlists in the state
          setState(() {
            playlists = jsonPlaylists.map((jsonPlaylist) {
              return Playlist(
                name: jsonPlaylist['name'],
                tracks: List<dynamic>.from(jsonPlaylist['tracks']),
              );
            }).toList();
          });
          print('Playlists loaded successfully!');
        }
      
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }

// for list of playlists dialog box while adding the tracks to playlist
  void _showPlaylistSelectionDialog(Map<String, dynamic> track) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Playlist'),
          content: playlists.isEmpty
              ? const Text('No playlists available. Create one first.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: playlists.map((playlist) {
                    return ListTile(
                      title: Text(playlist.name),
                      onTap: () {
                        _addTrackToPlaylist(playlist, track);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    );
                  }).toList(),
                ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
    _loadPlaylists();
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        if (state.processingState == ProcessingState.completed) {
          currentAudioUrl = null; // Reset when playback completes
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose(); // Dispose of the audio player when not needed
    super.dispose();
  }

  void _playAudio(String audioUrl) async {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      if (currentAudioUrl == audioUrl) {
        await _audioPlayer.stop();
        setState(() {
          currentAudioUrl = null;
        });
      } else {
        await _audioPlayer.play();
        // await _audioPlayer.setUrl(audioUrl);
        setState(() {
          currentAudioUrl = audioUrl; // Update the currently playing audio
        });
      }
      print('Audio started successfully');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2, // Define the number of tabs
        child: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/main-banner.jpg',
                    width: 100,  // Width of the image
                    height: 100, // Height of the image
                    fit: BoxFit.cover, 
                    ),
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
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: _showCreatePlaylistDialog,
                                  child: const Text('Create New Playlist'),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: playlists.length,
                                  itemBuilder: (context, index) {
                                    final playlist = playlists[index];
                                    return ListTile(
                                      title: Text(playlist.name),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PlaylistTracksPage(
                                                    playlist: playlist),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          FutureBuilder<List<dynamic>>(
                            future:
                                _getAvailableAudioTrack(), // Pass the future that fetches the data
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Show loading spinner
                              } else if (snapshot.hasError) {
                                return Text(
                                    'Error: ${snapshot.error}'); // Show error if any
                              } else if (snapshot.hasData) {
                                print("snapshot.data");
                                print(snapshot.data);
                                var audioList = snapshot.data;
                                return ListView.builder(
                                  itemCount: audioList?.length,
                                  itemBuilder: (context, index) {
                                    final audio = audioList?[index];
                                    String? currentPlaying =  currentAudioUrl?.split("/").last;
                                    return ListTile(
                                      title: Text(audio['title']),
                                      leading: const Icon(Icons.music_note),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children:[
                                          IconButton(
                                            icon: Icon((currentPlaying == '${audio['file']}')
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                            ),
                                            onPressed: () async {
                                              Directory appDocDir = await getApplicationDocumentsDirectory();
                                              String appDocPath = appDocDir.path;
                                              String filename = audio['file'];
                                              String audioUrl = '$appDocPath/$filename';
                                              _playAudio(audioUrl); // Play the audio
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () { 
                                              _showPlaylistSelectionDialog(audio);
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        String audioUrl;
                                        // For non-web platforms (mobile/desktop)
                                        Directory appDocDir = await getApplicationDocumentsDirectory();
                                        String appDocPath = appDocDir.path;
                                        String filename = audio['file'];
                                        audioUrl = '$appDocPath/$filename';
                                        _playAudio(audioUrl); // Play the audio
                                        print(audioUrl);
                                        if (currentPlaying == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Start playing your favorite ${audio['title']} (Audio)'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Stop playing your favorite ${audio['title']} (Audio)'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const Text(
                                    'No data available'); // Handle empty state
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

class PlaylistTracksPage extends StatefulWidget {
  final Playlist playlist;
  const PlaylistTracksPage({super.key, required this.playlist});
  @override
  _PlaylistTracksPageState createState() => _PlaylistTracksPageState();
}

class _PlaylistTracksPageState extends State<PlaylistTracksPage> {
  late AudioPlayer _audioPlayer;
  String? currentAudioUrl;
  // late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
    // _loadPlaylists();
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        if (state.processingState == ProcessingState.completed) {
          currentAudioUrl = null; // Reset when playback completes
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose(); // Dispose of the audio player when not needed
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    try {
      print("currentAudioUrl =========================>>>>> ");
      print(currentAudioUrl);
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      if (currentAudioUrl == url) {
        await _audioPlayer.stop();
        setState(() {
          currentAudioUrl = null;
        });
      } else {
        await _audioPlayer.play();
        setState(() {
          currentAudioUrl = url;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentPlaying =  currentAudioUrl?.split("/").last;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name), // Display the playlist name as the title
      ),
      body: widget.playlist.tracks.isEmpty
          ? const Center(
              child: Text('No tracks added to this playlist'),
            )
          : ListView.builder(
              itemCount: widget.playlist.tracks.length,
              itemBuilder: (context, index) {
                final track = widget.playlist.tracks[index];
                return ListTile(
                  title: Text(track['title']),
                  leading: const Icon(Icons.music_note),


                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      IconButton(
                        icon: Icon((currentPlaying == '${track['file']}')
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () async {
                          Directory appDocDir = await getApplicationDocumentsDirectory();
                          String appDocPath = appDocDir.path;
                          String filename = track['file'];
                          String audioUrl = '$appDocPath/$filename';
                          _playAudio(audioUrl); // Play the audio
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.add),
                      //   onPressed: () { 
                      //     _showPlaylistSelectionDialog(audio);
                      //   },
                      // ),
                    ],
                  ),


                  onTap: () async {
                    String audioUrl;                
                      // For non-web platforms (mobile/desktop)
                      Directory appDocDir =
                          await getApplicationDocumentsDirectory();
                      String appDocPath = appDocDir.path;
                      String filename = track['file'];
                      audioUrl = '$appDocPath/$filename';
                      _playAudio(audioUrl); // Play the audio
                      print(audioUrl);
                      print("currentPlaying ====> ");
                      print(currentPlaying);
                      if (currentPlaying == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Start playing your favorite ${track['title']} (Audio)'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Stop playing your favorite ${track['title']} (Audio)'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
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
    String PROGRAM = dotenv.env['PROGRAM'] ?? 'No Program Available';
    final List<dynamic> programList = json.decode(PROGRAM.toString());
    String discountedProgram = dotenv.env['SINGLE_DISCOUNTED_PROGRAM'] ?? 'No Program Available';
    Map<String, dynamic> discountedProgramMap = json.decode(discountedProgram.toString());
    print("=======================> discountedProgramMap <=======================");
    print(discountedProgramMap['url']);
    // String discounted_program = dotenv.env['SINGLE_DISCOUNTED_PROGRAM'] ?? 'No Program Available';
    return Scaffold(
      // appBar: AppBar(
      //   title: const Center(child: Text('All programs')),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            // // First ListView.builder
            ElevatedButton(
              onPressed: () {
                // Handle button press
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscountProgramDetailPage(
                        singerLogo:discountedProgramMap['logo'] ?? "",
                        programName: discountedProgramMap['name'] ?? "",
                        fullDescription: discountedProgramMap['description'] ?? "",
                        price: double.parse(discountedProgramMap['price']),
                        audioFileUrl: discountedProgramMap['url'] ?? ""
                      ),
                  ),
                );
              },
              child: const Text('Download All Audio on Discounted Price'),
            ),
            const SizedBox(height: 16), // Add space between the two ListViews
            // // Second ListView.builder
            Expanded(
              child: ListView.builder(
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
                  String shortDescription =
                      program['shortDescription'] + ' ' + sprice;
                  String fullDescription =
                      program['description'] ?? 'Full Description';
                  String audioFileUrl = program['url'] ?? '';
                  // ignore: prefer_interpolation_to_compose_strings
                  String singerLogo = "assets/singers/"+program['logo'];
                  print(singerLogo);
                  return Column(
                    children: [
                      ListTile(
                        // leading: const FlutterLogo(),
                        leading: Image.asset(
                            singerLogo,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        title: Text(programName),
                        subtitle: Text(shortDescription),
                        // trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          // Ensure onTap is correctly placed and functional
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProgramDetailPage(
                                  singerLogo:singerLogo,
                                  programName: programName,
                                  fullDescription: fullDescription,
                                  price: price,
                                  audioFileUrl: audioFileUrl),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportPage extends StatelessWidget {
  // Define a list of items
  final List<String> items = const [
    "FAQ",
    "Contact",
    "Download Your Audio Files"
  ];

  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Support'),
      //   centerTitle: true,
      // ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.ac_unit),
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
                        builder: (context) =>
                            const DownloadPurchasedAudioFiles()),
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
        child: Text("Names: MiraiInfotach. \nOffice: Indistrial Area"),
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
        child: ElevatedButton(
          onPressed: () {
            print("Download audio file");
          },
          child: const Text('Comming Soon'),
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
            // trailing: const Icon(Icons.more_vert),
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
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final selectedTheme = themeProvider.selectedTheme;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Select Your Favourite Theme"),
      //   centerTitle: true,
      // ),
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
