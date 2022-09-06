import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/game_page.dart';
import 'services/game_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameServices>(
            create: (context) => GameServices()),
      ],
      child: MaterialApp(
        title: 'Cat something',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const GamePage(),
      ),
    );
  }
}
