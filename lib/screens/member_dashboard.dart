import 'package:flutter/material.dart';
import '../theme_provider.dart';
import '../widgets/chat_interface.dart';

class MemberDashboard extends StatelessWidget {
  final String userName;
  const MemberDashboard({Key? key, this.userName = 'Alex'}) : super(key: key);

  final List<Map<String, dynamic>> _workouts = const [
    {'name': 'Full Body Blast', 'sets': 3, 'reps': 12},
    {'name': 'Upper Strength', 'sets': 4, 'reps': 8},
    {'name': 'Leg Power', 'sets': 3, 'reps': 10},
  ];

  final List<String> _diet = const [
    'Breakfast: Oats + Berries',
    'Snack: Banana + Almonds',
    'Lunch: Grilled Chicken + Quinoa',
    'Snack: Yogurt',
    'Dinner: Salmon + Veggies',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(child: Text('Hi, $userName', style: Theme.of(context).textTheme.titleLarge)),
            CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customized Workouts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _workouts.length,
                itemBuilder: (context, i) {
                  final w = _workouts[i];
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w['name'], style: Theme.of(context).textTheme.bodyLarge),
                            const Spacer(),
                            Text('Sets: ${w['sets']}', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Reps: ${w['reps']}', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: () {}, child: const Text('Start')),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text("Today's Diet Plan", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _diet.length,
                itemBuilder: (context, i) => Card(
                  child: ListTile(
                    title: Text(_diet[i], style: Theme.of(context).textTheme.bodyMedium),
                    trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const ChatInterface(isTypingIndicator: true),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.android),
        );
      }),
    );
  }
}
