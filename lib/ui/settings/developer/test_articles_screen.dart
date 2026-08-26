import 'package:flutter/material.dart';

class TestArticlesScreen extends StatefulWidget {
  const TestArticlesScreen({super.key});

  @override
  State<TestArticlesScreen> createState() => _TestArticlesScreenState();
}

class _TestArticlesScreenState extends State<TestArticlesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TestArticlesScreen')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('BV19SZfBKEEg'),
            subtitle: Text('需要滚动合集组的视频'),
          ),
        ],
      ),
    );
  }
}
