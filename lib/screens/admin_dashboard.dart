import 'package:flutter/material.dart';
import '../theme_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<String> _members = ['Alex', 'Sofia', 'Jordan', 'Taylor', 'Riley'];
  final List<Map<String, String>> _trainers = [
    {'name': 'Maya Reed', 'bio': 'HIIT expert', 'specialty': 'HIIT'},
    {'name': 'Liam Hart', 'bio': 'Strength coach', 'specialty': 'Strength'},
  ];

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _specCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Trainers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Members Tab
            ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(
                  _members[i],
                  style: const TextStyle(color: AppTheme.textColor),
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ),
            ),

            // Trainers Tab
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _bioCtrl,
                            decoration: const InputDecoration(labelText: 'Bio'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _specCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Specialty',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Add Trainer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _trainers.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(
                          _trainers[i]['name']!,
                          style: const TextStyle(color: AppTheme.textColor),
                        ),
                        subtitle: Text(
                          _trainers[i]['specialty']!,
                          style: const TextStyle(color: AppTheme.textColor),
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
