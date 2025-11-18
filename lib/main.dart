import 'package:flutter/material.dart';
import 'package:fvm_demo/remote_cards/remote_card_list_view.dart';

void main() {
  runApp(const RemoteWidgetDemoApp());
}

class RemoteWidgetDemoApp extends StatelessWidget {
  const RemoteWidgetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008E7F)),
        useMaterial3: false,
      ),
      home: const RemoteCardListPage(),
    );
  }
}
