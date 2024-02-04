import 'package:flutter/material.dart';

class Disable extends StatelessWidget {
  const Disable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disabled Page'),
      ),
      body: const Center(
        child: Text('This page is disabled'),
      ),
    );
  }
}
