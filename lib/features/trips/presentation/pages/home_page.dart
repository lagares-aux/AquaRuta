import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaRuta 🌊'),
      ),
      body: const Center(
        child: Text('Conectado a Supabase Cloud correctamente'),
      ),
    );
  }
}
