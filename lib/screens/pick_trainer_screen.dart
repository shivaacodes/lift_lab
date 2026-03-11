import 'package:flutter/material.dart';
import '../theme_provider.dart';

class Trainer {
  final String name;
  final String specialty;
  final String imageUrl;
  Trainer({
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });
}

class PickTrainerScreen extends StatefulWidget {
  const PickTrainerScreen({super.key});

  @override
  State<PickTrainerScreen> createState() => _PickTrainerScreenState();
}

class _PickTrainerScreenState extends State<PickTrainerScreen> {
  final List<Trainer> _trainers = [
    Trainer(
      name: 'Maya Reed',
      specialty: 'HIIT',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Trainer(
      name: 'Liam Hart',
      specialty: 'Strength',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Trainer(
      name: 'Noah Kim',
      specialty: 'Mobility',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Trainer(
      name: 'Ava Stone',
      specialty: 'Yoga',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Trainer(
      name: 'Ethan Cole',
      specialty: 'Conditioning',
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Your Trainer')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _trainers.length,
          itemBuilder: (context, i) {
            final t = _trainers[i];
            final selected = _selectedIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: selected
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(t.imageUrl),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.specialty,
                        style: const TextStyle(color: AppTheme.textColor),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
