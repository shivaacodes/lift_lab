import 'package:flutter/material.dart';
import 'package:lift_lab/theme_provider.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const WorkoutsView(),
    const DietView(),
    const HistoryView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAIChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatbotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.scaffoldBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAIChatbot,
          backgroundColor: AppTheme.fabColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: AppTheme.primaryColor,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: AppTheme.navBarColor,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home_rounded,
                  color: _currentIndex == 0 ? Colors.black : Colors.black.withOpacity(0.5),
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.fitness_center_rounded,
                  color: _currentIndex == 1 ? Colors.black : Colors.black.withOpacity(0.5),
                ),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: Icon(
                  Icons.restaurant_rounded,
                  color: _currentIndex == 2 ? Colors.black : Colors.black.withOpacity(0.5),
                ),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: _currentIndex == 3 ? Colors.black : Colors.black.withOpacity(0.5),
                ),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, Member',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Stay consistent, stay emerald.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('Top Trainers'),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTrainerCard(context, 'Trainer Alpha', 'Focus: Strength'),
                  _buildTrainerCard(context, 'Trainer Beta', 'Focus: HIIT'),
                  _buildTrainerCard(context, 'Trainer Gamma', 'Focus: Yoga'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('Quick Workouts'),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  _buildWorkoutListItem(context, 'Emerald Burn', '45 min • High Intensity'),
                  _buildWorkoutListItem(context, 'Midnight Flow', '30 min • Recovery'),
                  _buildWorkoutListItem(context, 'Core Crush', '20 min • Core Strength'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTrainerCard(BuildContext context, String name, String focus) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainerDetailsScreen(trainerName: name, trainerFocus: focus),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.fabColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(focus, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutListItem(BuildContext context, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => QuickWorkoutSuggestionSheet(title: title),
          );
        },
        leading: const Icon(Icons.bolt, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class WorkoutsView extends StatefulWidget {
  const WorkoutsView({super.key});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> {
  List<Map<String, String>> _customPlan = [];

  void _updateCustomPlan(List<Map<String, String>> newPlan) {
    setState(() {
      _customPlan = List.from(newPlan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Workouts', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => WorkoutCustomizationSheet(
                              initialPlan: _customPlan,
                              onUpdate: _updateCustomPlan,
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Customize'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AIWorkoutGeneratorSheet(
                              onSuggestionAdded: (workout) {
                                _updateCustomPlan([..._customPlan, workout]);
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('AI Custom'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Customised Plan Section
            if (_customPlan.isNotEmpty) ...[
              const Text('Customised Plan',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _customPlan.length,
                  itemBuilder: (context, index) {
                    final workout = _customPlan[index];
                    return Stack(
                      children: [
                        Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.fabColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(workout['name']!, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                              Text('${workout['sets']} Sets x ${workout['reps']} Reps', 
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 15,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _customPlan.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Workout removed'), duration: Duration(seconds: 1)),
                              );
                            },
                            child: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],

            const Text('Popular Routines',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildRoutineCard(context, 'Leg', '3 Exercises'),
                  _buildRoutineCard(context, 'Chest', '3 Exercises'),
                  _buildRoutineCard(context, 'Abs', '3 Exercises'),
                  _buildRoutineCard(context, 'Biceps', '3 Exercises'),
                  _buildRoutineCard(context, 'Triceps', '3 Exercises'),
                  _buildRoutineCard(context, 'Back', '3 Exercises'),
                  _buildRoutineCard(context, 'Thighs', '3 Exercises'),
                  _buildRoutineCard(context, 'Calf', '3 Exercises'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRoutineCard(BuildContext context, String title, String count) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BodyPartDetailScreen(category: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.fabColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, color: AppTheme.primaryColor, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(count, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class DietView extends StatefulWidget {
  const DietView({super.key});

  @override
  State<DietView> createState() => _DietViewState();
}

class _DietViewState extends State<DietView> {
  final List<Map<String, String>> _meals = [];
  bool _isPlanSaved = false;

  final TextEditingController _mealTimeController = TextEditingController();
  final TextEditingController _mealDescController = TextEditingController();
  final TextEditingController _mealKcalController = TextEditingController();

  final TextEditingController _calorieGoalController = TextEditingController(text: '2500');
  final TextEditingController _preferenceController = TextEditingController(text: 'Keto');

  void _addNewMeal() {
    _mealTimeController.clear();
    _mealDescController.clear();
    _mealKcalController.clear();
    _showMealDialog(title: 'Add New Meal');
  }

  void _editMeal(int index) {
    _mealTimeController.text = _meals[index]['time']!;
    _mealDescController.text = _meals[index]['desc']!;
    _mealKcalController.text = _meals[index]['kcal']!;
    _showMealDialog(title: 'Edit Meal', index: index);
  }

  void _showMealDialog({required String title, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.scaffoldBackground,
        title: Text(title, style: const TextStyle(color: AppTheme.primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _mealTimeController, decoration: const InputDecoration(labelText: 'Meal Time (e.g. Snack)')),
            TextField(controller: _mealDescController, decoration: const InputDecoration(labelText: 'Meal Description')),
            TextField(controller: _mealKcalController, decoration: const InputDecoration(labelText: 'Calories')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_mealTimeController.text.isNotEmpty && _mealDescController.text.isNotEmpty) {
                setState(() {
                  final mealData = {
                    'time': _mealTimeController.text,
                    'desc': _mealDescController.text,
                    'kcal': _mealKcalController.text.contains('kcal') ? _mealKcalController.text : '${_mealKcalController.text} kcal',
                  };
                  if (index == null) {
                    _meals.add(mealData);
                  } else {
                    _meals[index] = mealData;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(index == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Diet & Nutrition', style: Theme.of(context).textTheme.titleLarge),
                if (_isPlanSaved)
                  IconButton(
                    onPressed: _addNewMeal,
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 30),
                  ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.fabColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Custom Diet Plan',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _calorieGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Calorie Goal',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _preferenceController,
                    decoration: const InputDecoration(
                      labelText: 'Dietary Preference',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (!_isPlanSaved) {
                            // Populate default meals if list is empty
                            if (_meals.isEmpty) {
                              _meals.addAll([
                                {'time': 'Breakfast', 'desc': 'Select to customize', 'kcal': '--- kcal'},
                                {'time': 'Lunch', 'desc': 'Select to customize', 'kcal': '--- kcal'},
                                {'time': 'Dinner', 'desc': 'Select to customize', 'kcal': '--- kcal'},
                              ]);
                            }
                            _isPlanSaved = true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Plan saved! Meals populated.')),
                            );
                          } else {
                            _isPlanSaved = false;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlanSaved ? Colors.grey[800] : AppTheme.primaryColor,
                      ),
                      child: Text(_isPlanSaved ? 'Edit Plan' : 'Save Plan'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (!_isPlanSaved && _meals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'Set your diet plan above to generate your daily meal schedule.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return _buildMealCard(index, meal['time']!, meal['desc']!, meal['kcal']!);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(int index, String time, String desc, String kcal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: () => _editMeal(index),
        title: Text(time),
        subtitle: Text(desc),
        trailing: Text(kcal, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final List<Map<String, String>> _historyItems = List.generate(10, (index) => {
    'title': 'Workout #${10 - index} Completed',
    'date': 'March ${index + 1}, 2024 • 07:30 PM',
    'points': '+50',
  });

  void _clearHistory() {
    setState(() {
      _historyItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity history cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activity History', style: Theme.of(context).textTheme.titleLarge),
                if (_historyItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: _historyItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[800]),
                          const SizedBox(height: 16),
                          const Text('No recent activity', style: TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _historyItems.length,
                      itemBuilder: (context, index) {
                        final item = _historyItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                              child: const Icon(Icons.check, color: AppTheme.primaryColor),
                            ),
                            title: Text(item['title']!),
                            subtitle: Text(item['date']!),
                            trailing: Text('Points: ${item['points']}', style: const TextStyle(color: AppTheme.primaryColor)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainerDetailsScreen extends StatelessWidget {
  final String trainerName;
  final String trainerFocus;

  const TrainerDetailsScreen({super.key, required this.trainerName, required this.trainerFocus});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(trainerName, style: const TextStyle(color: AppTheme.textColor)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Experience'),
              Tab(text: 'Qualifications'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.fabColor,
              child: Icon(Icons.person, size: 80, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 10),
            Text(trainerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            Text(trainerFocus, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$trainerName selected as your personal trainer!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Select as Personal Trainer'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent('Experience', [
                    '10+ years in fitness industry',
                    'Former professional athlete',
                    'Specialized in muscle gain and body recomposition',
                  ]),
                  _buildTabContent('Qualifications', [
                    'Certified Personal Trainer (NASM)',
                    'B.Sc. in Sports Science',
                    'Advanced Nutrition Certification',
                  ]),
                  _buildTabContent('Achievements', [
                    'Trained 500+ successful clients',
                    'Winner of 2022 Regional Fitness Coach Award',
                    'Author of "The Strength Blueprint"',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(item, style: const TextStyle(color: AppTheme.textColor, fontSize: 16))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class WorkoutCustomizationSheet extends StatefulWidget {
  final List<Map<String, String>> initialPlan;
  final Function(List<Map<String, String>>) onUpdate;

  const WorkoutCustomizationSheet({
    super.key,
    required this.initialPlan,
    required this.onUpdate,
  });

  @override
  State<WorkoutCustomizationSheet> createState() => _WorkoutCustomizationSheetState();
}

class _WorkoutCustomizationSheetState extends State<WorkoutCustomizationSheet> {
  late List<Map<String, String>> _customExercises;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customExercises = List.from(widget.initialPlan);
  }

  void _addExercise() {
    if (_nameController.text.isNotEmpty && _setsController.text.isNotEmpty && _repsController.text.isNotEmpty) {
      setState(() {
        _customExercises.add({
          'name': _nameController.text,
          'sets': _setsController.text,
          'reps': _repsController.text,
        });
      });
      _nameController.clear();
      _setsController.clear();
      _repsController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise added to your plan!'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Customize Your Plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          const SizedBox(height: 10),
          const Text('Add workouts, sets, and reps to your trainer plan.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          
          // Input Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.fabColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Exercise Name (e.g. Bench Press)'),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Sets'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          const Text('My Custom Workouts', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 15),
          
          Expanded(
            child: _customExercises.isEmpty
                ? const Center(child: Text('No exercises added yet.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _customExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _customExercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(ex['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${ex['sets']} sets x ${ex['reps']} reps'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => setState(() => _customExercises.removeAt(index)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onUpdate(_customExercises);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan updated successfully!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
            child: const Text('Update My Plan'),
          ),
        ],
      ),
    );
  }
}
class AIChatbotSheet extends StatelessWidget {
  const AIChatbotSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.fabColor,
                child: Icon(Icons.smart_toy_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Emerald AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Always active', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          Expanded(
            child: ListView(
              children: [
                _buildChatMessage('Hello! How can I help you with your fitness journey today?', false),
                _buildChatMessage('I need a quick workout for my core.', true),
                _buildChatMessage('Sure! I recommend the "Core Crush" routine. It only takes 20 minutes.', false),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.fabColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : AppTheme.fabColor,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: isUser ? Colors.black : AppTheme.textColor),
        ),
      ),
    );
  }
}

class BodyPartDetailScreen extends StatelessWidget {
  final String category;

  const BodyPartDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = _getCategoryData(category);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(category, style: const TextStyle(color: AppTheme.textColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.fabColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Benefits',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...(data['benefits'] as List<String>).map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(benefit, style: const TextStyle(color: AppTheme.textColor))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Potential Exercises',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (data['exercises'] as List).length,
              itemBuilder: (context, index) {
                final exercise = data['exercises'][index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.fabColor,
                      child: Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor),
                    ),
                    title: Text(exercise['name']),
                    subtitle: Text(exercise['sets']),
                    trailing: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryColor),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    switch (category) {
      case 'Leg':
        return {
          'benefits': ['Strengthens lower body', 'Increases overall power', 'Boosts testosterone production', 'Improved athletic performance'],
          'exercises': [
            {'name': 'Barbell Squats', 'sets': '4 sets x 10 reps'},
            {'name': 'Leg Extensions', 'sets': '3 sets x 12 reps'},
            {'name': 'Hamstring Curls', 'sets': '3 sets x 12 reps'},
          ]
        };
      case 'Chest':
        return {
          'benefits': ['Builds upper body mass', 'Improves pushing strength', 'Enhances pectoral definition', 'Better posture control'],
          'exercises': [
            {'name': 'Bench Press', 'sets': '4 sets x 8 reps'},
            {'name': 'Incline DB Press', 'sets': '3 sets x 10 reps'},
            {'name': 'Chest Flys', 'sets': '3 sets x 12 reps'},
          ]
        };
      case 'Abs':
        return {
          'benefits': ['Core stability', 'Improves spinal health', 'Enhanced athletic balance', 'Visible abdominal definition'],
          'exercises': [
            {'name': 'Plank', 'sets': '3 sets x 1 min'},
            {'name': 'Hanging Leg Raises', 'sets': '3 sets x 15 reps'},
            {'name': 'Crunches', 'sets': '4 sets x 20 reps'},
          ]
        };
      case 'Biceps':
        return {
          'benefits': ['Increased arm size', 'Improved grip strength', 'Enhanced arm aesthetics', 'Better pulling support'],
          'exercises': [
            {'name': 'Barbell Curls', 'sets': '3 sets x 10 reps'},
            {'name': 'Hammer Curls', 'sets': '3 sets x 12 reps'},
            {'name': 'Preacher Curls', 'sets': '3 sets x 10 reps'},
          ]
        };
      case 'Triceps':
        return {
          'benefits': ['Enhanced arm thickness', 'Stronger lockout power', 'Defined arm shape', 'Supporting chest movements'],
          'exercises': [
            {'name': 'Tricep Pushdowns', 'sets': '4 sets x 12 reps'},
            {'name': 'Skull Crushers', 'sets': '3 sets x 10 reps'},
            {'name': 'Dips', 'sets': '3 sets x Max reps'},
          ]
        };
      case 'Back':
        return {
          'benefits': ['Wide "V" taper look', 'Improved pulling power', 'Counteracts slouching', 'Strengthens spinal support'],
          'exercises': [
            {'name': 'Deadlifts', 'sets': '3 sets x 5 reps'},
            {'name': 'Lat Pulldowns', 'sets': '4 sets x 10 reps'},
            {'name': 'Bent Over Rows', 'sets': '3 sets x 10 reps'},
          ]
        };
      case 'Thighs':
        return {
          'benefits': ['Powerful lower body', 'Toned leg appearance', 'Increased jumping ability', 'Higher functional mobility'],
          'exercises': [
            {'name': 'Goblet Squats', 'sets': '3 sets x 12 reps'},
            {'name': 'Walking Lunges', 'sets': '3 sets x 20 steps'},
            {'name': 'Sumo Squats', 'sets': '3 sets x 12 reps'},
          ]
        };
      case 'Calf':
        return {
          'benefits': ['Defined lower legs', 'Improved explosive power', 'Better ankle stability', 'Injury prevention for legs'],
          'exercises': [
            {'name': 'Standing Calf Raises', 'sets': '4 sets x 15 reps'},
            {'name': 'Seated Calf Raises', 'sets': '3 sets x 15 reps'},
            {'name': 'Donkey Calf Raises', 'sets': '3 sets x 12 reps'},
          ]
        };
      default:
        return {
          'benefits': ['General fitness improvement'],
          'exercises': [
            {'name': 'General Exercise', 'sets': '3 sets x 10 reps'},
          ]
        };
    }
  }
}
class AIWorkoutGeneratorSheet extends StatefulWidget {
  final Function(Map<String, String>) onSuggestionAdded;

  const AIWorkoutGeneratorSheet({super.key, required this.onSuggestionAdded});

  @override
  State<AIWorkoutGeneratorSheet> createState() => _AIWorkoutGeneratorSheetState();
}

class _AIWorkoutGeneratorSheetState extends State<AIWorkoutGeneratorSheet> {
  String _selectedIntensity = 'Medium';
  String _selectedGoal = 'Muscle Gain';
  String _selectedDuration = '45 min';
  bool _isLoading = false;
  Map<String, String>? _suggestion;

  void _generateAISuggestion() async {
    setState(() => _isLoading = true);
    
    // Simulate Gemini processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      // Simulated "AI" Logic based on inputs
      if (_selectedGoal == 'Weight Loss') {
        _suggestion = {'name': 'HIIT Circuit', 'sets': '5', 'reps': '20'};
      } else if (_selectedGoal == 'Muscle Gain') {
        _suggestion = {'name': 'Heavy Compound Lift', 'sets': '4', 'reps': '8'};
      } else {
        _suggestion = {'name': 'Functional Flow', 'sets': '3', 'reps': '15'};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 10),
              Text('Gemini Workout AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Tell Gemini your goals for a tailored suggestion.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          
          if (_suggestion == null && !_isLoading) ...[
            _buildDropdown('Intensity', ['Low', 'Medium', 'High'], _selectedIntensity, (v) => setState(() => _selectedIntensity = v!)),
            const SizedBox(height: 20),
            _buildDropdown('Goal', ['Muscle Gain', 'Weight Loss', 'Flexibility'], _selectedGoal, (v) => setState(() => _selectedGoal = v!)),
            const SizedBox(height: 20),
            _buildDropdown('Duration', ['15 min', '30 min', '45 min', '60+ min'], _selectedDuration, (v) => setState(() => _selectedDuration = v!)),
            const Spacer(),
            ElevatedButton(
              onPressed: _generateAISuggestion,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: const Text('Ask Gemini'),
            ),
          ] else if (_isLoading) ...[
            const Spacer(),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 20),
                  Text('Gemini is generating your custom workout...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const Spacer(),
          ] else ...[
            const Text('Gemini Suggests:', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.fabColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(_suggestion!['name']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('${_suggestion!['sets']} Sets x ${_suggestion!['reps']} Reps', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _suggestion = null),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSuggestionAdded(_suggestion!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Workout added to your plan!')));
                    },
                    child: const Text('Add to Plan'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String current, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: AppTheme.fabColor, borderRadius: BorderRadius.circular(15)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              isExpanded: true,
              dropdownColor: AppTheme.fabColor,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class QuickWorkoutSuggestionSheet extends StatelessWidget {
  final String title;

  const QuickWorkoutSuggestionSheet({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = _getSuggestionData(title);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Text('Suggested Routine', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          const SizedBox(height: 20),
          const Text('Focus on form and consistency.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              itemCount: (data['exercises'] as List).length,
              itemBuilder: (context, index) {
                final ex = data['exercises'][index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.fabColor, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(ex['sets'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
            child: const Text('Got it!'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Map<String, dynamic> _getSuggestionData(String title) {
    switch (title) {
      case 'Emerald Burn':
        return {
          'exercises': [
            {'name': 'Mountain Climbers', 'sets': '4 sets x 45 sec'},
            {'name': 'Burpees', 'sets': '3 sets x 15 reps'},
            {'name': 'High Knees', 'sets': '4 sets x 30 sec'},
          ]
        };
      case 'Midnight Flow':
        return {
          'exercises': [
            {'name': 'Sun Salutation', 'sets': '5 rounds'},
            {'name': "Child's Pose", 'sets': '2 mins hold'},
            {'name': 'Downward Dog', 'sets': '3 sets x 1 min'},
          ]
        };
      case 'Core Crush':
        return {
          'exercises': [
            {'name': 'Russian Twists', 'sets': '4 sets x 20 reps'},
            {'name': 'Bicycle Crunches', 'sets': '3 sets x 25 reps'},
            {'name': 'Leg Flutters', 'sets': '3 sets x 30 sec'},
          ]
        };
      default:
        return {
          'exercises': [
            {'name': 'Quick Jog', 'sets': '10 mins'},
            {'name': 'Stretch', 'sets': '5 mins'},
          ]
        };
    }
  }
}
