import 'package:catgram/provider/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/pages/home/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Catgram',
      themeMode: ThemeMode.dark,
      scaffoldMessengerKey: ref.watch(scaffoldKeyProvider),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: DisableGlowEffect(),
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}

class DisableGlowEffect extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
