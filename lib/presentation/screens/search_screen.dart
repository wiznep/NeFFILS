import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Center(
        child: Text(
          'Search functionality is not implemented yet.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}