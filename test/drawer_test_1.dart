import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: const DrawerTest1()));
}

class DrawerTest1 extends StatefulWidget {
  const DrawerTest1({super.key});

  @override
  State<DrawerTest1> createState() => _DrawerTest1State();
}

class _DrawerTest1State extends State<DrawerTest1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer Test 1'),
      ),
      body: Center(
        child: Container(
          width: 500,
          height: 500,
          color: Colors.red,
          child: Builder(
            builder: (context) {
              return Scaffold(
                drawer: Drawer(
                  child: Text('Drawer'),
                ),
                body: Center(
                  child: TextButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
