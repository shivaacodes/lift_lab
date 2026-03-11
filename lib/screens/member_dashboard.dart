import 'package:flutter/material.dart';
import '../theme_provider.dart';
import '../widgets/chat_interface.dart';
import '../services/database_service.dart';

class MemberDashboard extends StatelessWidget {
  final String userName;
  const MemberDashboard({super.key, this.userName = 'Alex'});

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
            Expanded(
              child: Text(
                'Hi, $userName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customized Workouts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: FutureBuilder<Map<String, dynamic>>(
                future: DatabaseService().getDailyRoutine(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Error loading routine'));
                  }

                  final routine = snapshot.data!;
                  final exercises = routine['exercises'] as List<dynamic>;

                  if (exercises.isEmpty) {
                    return const Card(
                      child: Center(
                        child: Text('Rest Day! Enjoy your recovery.'),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: exercises.length,
                    itemBuilder: (context, i) {
                      final exercise = exercises[i];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise['name'],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  exercise['details'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        exercise['rpe'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Today's Diet Plan",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _diet.length,
                itemBuilder: (context, i) => Card(
                  child: ListTile(
                    title: Text(
                      _diet[i],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
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
        },
      ),
    );
  }
}
