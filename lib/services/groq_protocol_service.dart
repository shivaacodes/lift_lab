import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lift_lab/models/user_model.dart';

import 'package:lift_lab/config/secrets.dart';

class GroqProtocolService {
  static const String _apiKey = Secrets.groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';


  /// Pre-defined high-quality training blocks to reduce AI tokens/latency.
  static final Map<String, List<Map<String, dynamic>>> _workoutTemplates = {
    'hypertrophy_ppl': [
      {'day': 1, 'label': 'Push (Chest/Shoulders/Triceps)', 'exercises': [
        {'name': 'Barbell Bench Press', 'sets': 3, 'reps': '8-10', 'burnKcal': 45},
        {'name': 'Overhead Press', 'sets': 3, 'reps': '10-12', 'burnKcal': 35},
        {'name': 'Dumbbell Incline Flys', 'sets': 3, 'reps': '12-15', 'burnKcal': 30},
        {'name': 'Tricep Rope Pushdowns', 'sets': 3, 'reps': '12-15', 'burnKcal': 25},
        {'name': 'Lateral Raises', 'sets': 4, 'reps': '15-20', 'burnKcal': 25},
      ]},
      {'day': 2, 'label': 'Pull (Back/Biceps)', 'exercises': [
        {'name': 'Lat Pulldowns', 'sets': 4, 'reps': '10-12', 'burnKcal': 40},
        {'name': 'Seated Cable Rows', 'sets': 3, 'reps': '10-12', 'burnKcal': 35},
        {'name': 'Face Pulls', 'sets': 3, 'reps': '15-20', 'burnKcal': 20},
        {'name': 'Dumbbell Hammer Curls', 'sets': 3, 'reps': '12-15', 'burnKcal': 25},
        {'name': 'Single Arm DB Rows', 'sets': 3, 'reps': '10-12', 'burnKcal': 30},
      ]},
      {'day': 3, 'label': 'Legs (Quads/Hams/Calves)', 'exercises': [
        {'name': 'Barbell Back Squats', 'sets': 3, 'reps': '8-10', 'burnKcal': 60},
        {'name': 'Leg Extensions', 'sets': 3, 'reps': '12-15', 'burnKcal': 35},
        {'name': 'Leg Curls', 'sets': 3, 'reps': '12-15', 'burnKcal': 30},
        {'name': 'Standing Calf Raises', 'sets': 4, 'reps': '15-20', 'burnKcal': 25},
        {'name': 'Walking Lunges', 'sets': 3, 'reps': '12/side', 'burnKcal': 45},
      ]},
      {'day': 4, 'label': 'Push (Hypertrophy Focus)', 'exercises': [
        {'name': 'Dumbbell Shoulder Press', 'sets': 3, 'reps': '10-12', 'burnKcal': 35},
        {'name': 'Lateral Raises', 'sets': 4, 'reps': '15-20', 'burnKcal': 25},
        {'name': 'Chest Dips', 'sets': 3, 'reps': '8-12', 'burnKcal': 40},
        {'name': 'Skullcrushers', 'sets': 3, 'reps': '12-15', 'burnKcal': 25},
        {'name': 'Incline DB Bench', 'sets': 3, 'reps': '10-12', 'burnKcal': 40},
      ]},
      {'day': 5, 'label': 'Pull (Metabolic Stress)', 'exercises': [
        {'name': 'Pull Ups', 'sets': 3, 'reps': 'Max', 'burnKcal': 45},
        {'name': 'Barbell Curls', 'sets': 3, 'reps': '8-12', 'burnKcal': 25},
        {'name': 'Reverse Pec Deck', 'sets': 3, 'reps': '15-20', 'burnKcal': 20},
        {'name': 'Straight Arm Pulldowns', 'sets': 3, 'reps': '12-15', 'burnKcal': 25},
        {'name': 'Preacher Curls', 'sets': 3, 'reps': '12-15', 'burnKcal': 20},
      ]},
      {'day': 6, 'label': 'Legs (Glute & Posterior)', 'exercises': [
        {'name': 'Leg Press', 'sets': 3, 'reps': '12-15', 'burnKcal': 50},
        {'name': 'RDLs', 'sets': 3, 'reps': '10-12', 'burnKcal': 45},
        {'name': 'Bulgarian Split Squats', 'sets': 3, 'reps': '10/side', 'burnKcal': 50},
        {'name': 'Seated Calf Raises', 'sets': 3, 'reps': '15-20', 'burnKcal': 20},
        {'name': 'Plank', 'sets': 3, 'reps': '60s', 'burnKcal': 15},
      ]},
      {'day': 7, 'label': 'Protocol Rest (Sunday)', 'exercises': []},
    ],
    'strength_upper_lower': [
      {'day': 1, 'label': 'Upper Strength A', 'exercises': [
        {'name': 'Bench Press', 'sets': 5, 'reps': '5', 'burnKcal': 55},
        {'name': 'Bent Over Rows', 'sets': 5, 'reps': '5', 'burnKcal': 50},
        {'name': 'Weighted Dips', 'sets': 3, 'reps': '8', 'burnKcal': 40},
        {'name': 'Pull Ups', 'sets': 3, 'reps': '8', 'burnKcal': 35},
        {'name': 'Overhead Press', 'sets': 3, 'reps': '8', 'burnKcal': 40},
      ]},
      {'day': 2, 'label': 'Lower Strength A', 'exercises': [
        {'name': 'Deadlift', 'sets': 3, 'reps': '5', 'burnKcal': 70},
        {'name': 'Front Squat', 'sets': 4, 'reps': '8', 'burnKcal': 60},
        {'name': 'Hanging Leg Raises', 'sets': 3, 'reps': '15', 'burnKcal': 25},
        {'name': 'Standing Calf Raises', 'sets': 4, 'reps': '12', 'burnKcal': 25},
        {'name': 'Leg Extensions', 'sets': 3, 'reps': '12', 'burnKcal': 30},
      ]},
      {'day': 3, 'label': 'Upper Strength B', 'exercises': [
        {'name': 'Military Press', 'sets': 5, 'reps': '5', 'burnKcal': 50},
        {'name': 'Pendlay Rows', 'sets': 5, 'reps': '5', 'burnKcal': 45},
        {'name': 'Incline Bench Press', 'sets': 3, 'reps': '8', 'burnKcal': 45},
        {'name': 'Chin Ups', 'sets': 3, 'reps': '10', 'burnKcal': 35},
        {'name': 'Lateral Raises', 'sets': 3, 'reps': '15', 'burnKcal': 25},
      ]},
      {'day': 4, 'label': 'Lower Strength B', 'exercises': [
        {'name': 'Back Squat', 'sets': 5, 'reps': '5', 'burnKcal': 65},
        {'name': 'RDLs', 'sets': 4, 'reps': '8', 'burnKcal': 50},
        {'name': 'Split Squats', 'sets': 3, 'reps': '10/side', 'burnKcal': 45},
        {'name': 'Seated Calf Raises', 'sets': 4, 'reps': '15', 'burnKcal': 20},
        {'name': 'Russian Twists', 'sets': 3, 'reps': '20', 'burnKcal': 20},
      ]},
      {'day': 5, 'label': 'Upper Accessory', 'exercises': [
        {'name': 'Incline DB Press', 'sets': 3, 'reps': '10-12', 'burnKcal': 40},
        {'name': 'Lat Pulldowns', 'sets': 3, 'reps': '10-12', 'burnKcal': 35},
        {'name': 'Skullcrushers', 'sets': 3, 'reps': '12', 'burnKcal': 25},
        {'name': 'EZ Bar Curls', 'sets': 3, 'reps': '12', 'burnKcal': 20},
        {'name': 'Face Pulls', 'sets': 3, 'reps': '15', 'burnKcal': 20},
      ]},
      {'day': 6, 'label': 'Lower Accessory', 'exercises': [
        {'name': 'Leg Press', 'sets': 3, 'reps': '12-15', 'burnKcal': 50},
        {'name': 'Hamstring Curls', 'sets': 3, 'reps': '12', 'burnKcal': 30},
        {'name': 'Leg Extensions', 'sets': 3, 'reps': '12', 'burnKcal': 30},
        {'name': 'Donkey Calf Raises', 'sets': 3, 'reps': '15', 'burnKcal': 20},
        {'name': 'Ab Wheel', 'sets': 3, 'reps': '12', 'burnKcal': 25},
      ]},
      {'day': 7, 'label': 'Protocol Rest (Sunday)', 'exercises': []},
    ],
    'fat_loss_circuit': [
      {'day': 1, 'label': 'Full Body Metcon A', 'exercises': [
        {'name': 'Goblet Squats', 'sets': 3, 'reps': '15', 'burnKcal': 50},
        {'name': 'KB Swings', 'sets': 3, 'reps': '20', 'burnKcal': 45},
        {'name': 'Burpees', 'sets': 3, 'reps': '10', 'burnKcal': 60},
        {'name': 'Mountain Climbers', 'sets': 3, 'reps': '30s', 'burnKcal': 30},
        {'name': 'Push Ups', 'sets': 3, 'reps': 'Max', 'burnKcal': 35},
      ]},
      {'day': 2, 'label': 'HIIT Cardio + Core', 'exercises': [
        {'name': 'Jump Rope', 'sets': 5, 'reps': '1 min', 'burnKcal': 50},
        {'name': 'Plank', 'sets': 3, 'reps': '45s', 'burnKcal': 15},
        {'name': 'Russian Twists', 'sets': 3, 'reps': '20', 'burnKcal': 20},
        {'name': 'Bicycle Crunches', 'sets': 3, 'reps': '30', 'burnKcal': 20},
        {'name': 'Leg Raises', 'sets': 3, 'reps': '15', 'burnKcal': 25},
      ]},
      {'day': 3, 'label': 'Upper Body Metcon', 'exercises': [
        {'name': 'DB Thrusters', 'sets': 3, 'reps': '15', 'burnKcal': 50},
        {'name': 'Inverted Rows', 'sets': 3, 'reps': '15', 'burnKcal': 35},
        {'name': 'Battle Ropes', 'sets': 4, 'reps': '30s', 'burnKcal': 40},
        {'name': 'DB Snatch', 'sets': 3, 'reps': '10/side', 'burnKcal': 45},
        {'name': 'Medicine Ball Slams', 'sets': 3, 'reps': '15', 'burnKcal': 35},
      ]},
      {'day': 4, 'label': 'Lower Body Metcon', 'exercises': [
        {'name': 'Box Jumps', 'sets': 3, 'reps': '12', 'burnKcal': 45},
        {'name': 'Walking Lunges', 'sets': 3, 'reps': '20 steps', 'burnKcal': 40},
        {'name': 'Wall Sits', 'sets': 3, 'reps': '45s', 'burnKcal': 30},
        {'name': 'Step Ups', 'sets': 3, 'reps': '12/side', 'burnKcal': 35},
        {'name': 'Glute Bridges', 'sets': 4, 'reps': '20', 'burnKcal': 30},
      ]},
      {'day': 5, 'label': 'Full Body Metcon B', 'exercises': [
        {'name': 'Clean & Press (DB)', 'sets': 3, 'reps': '10', 'burnKcal': 55},
        {'name': 'Jumping Squats', 'sets': 3, 'reps': '15', 'burnKcal': 50},
        {'name': 'Plank Jacks', 'sets': 3, 'reps': '20', 'burnKcal': 30},
        {'name': 'Renegade Rows', 'sets': 3, 'reps': '10/side', 'burnKcal': 40},
        {'name': 'Flutter Kicks', 'sets': 3, 'reps': '45s', 'burnKcal': 25},
      ]},
      {'day': 6, 'label': 'Aerobic Threshold', 'exercises': [
        {'name': 'Rower', 'sets': 1, 'reps': '10 min', 'burnKcal': 120},
        {'name': 'Assault Bike', 'sets': 1, 'reps': '5 min', 'burnKcal': 80},
        {'name': 'Elliptical (Fast)', 'sets': 1, 'reps': '10 min', 'burnKcal': 100},
        {'name': 'Box Step Ups', 'sets': 3, 'reps': '15/side', 'burnKcal': 45},
        {'name': 'Dead Bug (Core Recovery)', 'sets': 3, 'reps': '15', 'burnKcal': 15},
      ]},
      {'day': 7, 'label': 'Protocol Rest (Sunday)', 'exercises': []},
    ],
    'longevity_functional': [
      {'day': 1, 'label': 'Balance & Posture', 'exercises': [
        {'name': 'Single Leg Stance', 'sets': 3, 'reps': '45s/side', 'burnKcal': 15},
        {'name': 'Bird-Dogs', 'sets': 4, 'reps': '12/side', 'burnKcal': 20},
        {'name': 'Trap Bar Deadlifts', 'sets': 3, 'reps': '10', 'burnKcal': 50},
        {'name': 'Wall Slides', 'sets': 3, 'reps': '15', 'burnKcal': 15},
        {'name': 'Walking Lunges', 'sets': 3, 'reps': '12/side', 'burnKcal': 35},
      ]},
      {'day': 2, 'label': 'Functional Strength A', 'exercises': [
        {'name': 'Turkish Get-Ups', 'sets': 3, 'reps': '4/side', 'burnKcal': 45},
        {'name': 'Farmers Walk', 'sets': 4, 'reps': '40m', 'burnKcal': 40},
        {'name': 'Pull-Ups (Assisted)', 'sets': 3, 'reps': '10', 'burnKcal': 35},
        {'name': 'Push Ups (controlled)', 'sets': 3, 'reps': '15', 'burnKcal': 30},
        {'name': 'Suitcase Carry', 'sets': 3, 'reps': '20m/side', 'burnKcal': 25},
      ]},
      {'day': 3, 'label': 'Mobility Flow', 'exercises': [
        {'name': 'Cat-Cow Stretch', 'sets': 3, 'reps': '15', 'burnKcal': 15},
        {'name': 'Worlds Greatest Stretch', 'sets': 3, 'reps': '8/side', 'burnKcal': 25},
        {'name': 'Thoracic Rotation', 'sets': 3, 'reps': '12/side', 'burnKcal': 15},
        {'name': '90/90 Hip Switch', 'sets': 3, 'reps': '10/side', 'burnKcal': 20},
        {'name': 'Childs Pose into Cobra', 'sets': 3, 'reps': '10', 'burnKcal': 15},
      ]},
      {'day': 4, 'label': 'Functional Strength B', 'exercises': [
        {'name': 'Split Squats (DB)', 'sets': 3, 'reps': '12/side', 'burnKcal': 45},
        {'name': 'Inverted Rows (Ring/Bar)', 'sets': 3, 'reps': '12', 'burnKcal': 30},
        {'name': 'Kettlebell Swings', 'sets': 4, 'reps': '15', 'burnKcal': 40},
        {'name': 'Plank to Downward Dog', 'sets': 3, 'reps': '12', 'burnKcal': 25},
        {'name': 'Dead Bug', 'sets': 3, 'reps': '15', 'burnKcal': 15},
      ]},
      {'day': 5, 'label': 'Conditioning (Zone 2)', 'exercises': [
        {'name': 'Stationary Bike', 'sets': 1, 'reps': '15 min', 'burnKcal': 120},
        {'name': 'Brisk Walk', 'sets': 1, 'reps': '15 min', 'burnKcal': 100},
        {'name': 'Stair Climber (Easy)', 'sets': 1, 'reps': '10 min', 'burnKcal': 110},
        {'name': 'Goblet Squats (Slow)', 'sets': 3, 'reps': '15', 'burnKcal': 40},
        {'name': 'Glute Bridge Hold', 'sets': 3, 'reps': '45s', 'burnKcal': 20},
      ]},
      {'day': 6, 'label': 'Core & Stability', 'exercises': [
        {'name': 'Side Plank', 'sets': 3, 'reps': '30s/side', 'burnKcal': 20},
        {'name': 'Pallof Press', 'sets': 3, 'reps': '15/side', 'burnKcal': 20},
        {'name': 'Bear Crawls', 'sets': 3, 'reps': '20m', 'burnKcal': 35},
        {'name': 'Hollow Body Hold', 'sets': 3, 'reps': '30s', 'burnKcal': 20},
        {'name': 'Calf Raises (Balance)', 'sets': 3, 'reps': '15', 'burnKcal': 20},
      ]},
      {'day': 7, 'label': 'Protocol Rest (Sunday)', 'exercises': []},
    ],
    'hypertrophy_female': [
      {'day': 1, 'label': 'Glute & Leg Priority', 'exercises': [
        {'name': 'Hip Thrusts', 'sets': 4, 'reps': '10-12', 'burnKcal': 50},
        {'name': 'RDLs', 'sets': 3, 'reps': '12', 'burnKcal': 45},
        {'name': 'Bulgarian Split Squats', 'sets': 3, 'reps': '10/side', 'burnKcal': 50},
        {'name': 'Kickbacks (Cable)', 'sets': 3, 'reps': '15/side', 'burnKcal': 25},
        {'name': 'Abductors', 'sets': 3, 'reps': '15-20', 'burnKcal': 20},
      ]},
      {'day': 2, 'label': 'Upper Body (Sculpt Focus)', 'exercises': [
        {'name': 'Lat Pulldowns', 'sets': 3, 'reps': '12', 'burnKcal': 35},
        {'name': 'DB Shoulder Press', 'sets': 3, 'reps': '10-12', 'burnKcal': 30},
        {'name': 'Incline DB Bench', 'sets': 3, 'reps': '12', 'burnKcal': 35},
        {'name': 'Lateral Raises', 'sets': 3, 'reps': '15-20', 'burnKcal': 25},
        {'name': 'Tricep Extensions', 'sets': 3, 'reps': '15', 'burnKcal': 20},
      ]},
      {'day': 3, 'label': 'Lower Body Volume', 'exercises': [
        {'name': 'Goblet Squats', 'sets': 4, 'reps': '12-15', 'burnKcal': 45},
        {'name': 'Lunges', 'sets': 3, 'reps': '12/side', 'burnKcal': 40},
        {'name': 'Leg Press', 'sets': 3, 'reps': '15', 'burnKcal': 50},
        {'name': 'Hamstring Curls', 'sets': 3, 'reps': '15', 'burnKcal': 30},
        {'name': 'Calf Raises', 'sets': 3, 'reps': '20', 'burnKcal': 20},
      ]},
      {'day': 4, 'label': 'Active Recovery / Core', 'exercises': [
        {'name': 'Yoga / Mobility', 'sets': 1, 'reps': '20 min', 'burnKcal': 60},
        {'name': 'Plank', 'sets': 3, 'reps': '60s', 'burnKcal': 15},
        {'name': 'Bicycle Crunches', 'sets': 3, 'reps': '20', 'burnKcal': 20},
        {'name': 'Dead Bug', 'sets': 3, 'reps': '15', 'burnKcal': 15},
      ]},
      {'day': 5, 'label': 'Full Body Tone', 'exercises': [
        {'name': 'Single Leg DL', 'sets': 3, 'reps': '12/side', 'burnKcal': 40},
        {'name': 'Push Ups (Knee opt)', 'sets': 3, 'reps': 'Max', 'burnKcal': 30},
        {'name': 'Seated Rows', 'sets': 3, 'reps': '12', 'burnKcal': 35},
        {'name': 'Sumo Squats', 'sets': 3, 'reps': '15', 'burnKcal': 45},
        {'name': 'Curtsy Lunges', 'sets': 3, 'reps': '12/side', 'burnKcal': 35},
      ]},
      {'day': 6, 'label': 'Glute Finisher & HIIT', 'exercises': [
        {'name': 'Frog Pumps', 'sets': 3, 'reps': '30', 'burnKcal': 25},
        {'name': 'Mountain Climbers', 'sets': 3, 'reps': '45s', 'burnKcal': 35},
        {'name': 'Jump Squats', 'sets': 3, 'reps': '15', 'burnKcal': 45},
        {'name': 'Stair Climber', 'sets': 1, 'reps': '5 min', 'burnKcal': 80},
      ]},
      {'day': 7, 'label': 'Rest Day', 'exercises': []},
    ],
    'longevity_master': [
      {'day': 1, 'label': 'Functional Mobility A', 'exercises': [
        {'name': 'Wall Slides', 'sets': 3, 'reps': '12', 'burnKcal': 15},
        {'name': 'Cat-Cow', 'sets': 3, 'reps': '15', 'burnKcal': 10},
        {'name': 'Bird-Dogs', 'sets': 3, 'reps': '10/side', 'burnKcal': 20},
        {'name': 'Single Leg Stance', 'sets': 3, 'reps': '30s/side', 'burnKcal': 15},
        {'name': 'Brisk Walk', 'sets': 1, 'reps': '15 min', 'burnKcal': 100},
      ]},
      {'day': 2, 'label': 'Joint Stability (Strength)', 'exercises': [
        {'name': 'Goblet Squats (Slow)', 'sets': 3, 'reps': '10', 'burnKcal': 40},
        {'name': 'Resistance Band Rows', 'sets': 3, 'reps': '15', 'burnKcal': 30},
        {'name': 'Step Ups', 'sets': 3, 'reps': '10/side', 'burnKcal': 35},
        {'name': 'Dead Bug (Core)', 'sets': 3, 'reps': '12', 'burnKcal': 15},
        {'name': 'Glute Bridge', 'sets': 3, 'reps': '15', 'burnKcal': 20},
      ]},
      {'day': 3, 'label': 'Active Recovery', 'exercises': [
        {'name': 'Stretching Flow', 'sets': 1, 'reps': '20 min', 'burnKcal': 50},
        {'name': 'Stationary Bike (Easy)', 'sets': 1, 'reps': '10 min', 'burnKcal': 70},
      ]},
      {'day': 4, 'label': 'Functional Mobility B', 'exercises': [
        {'name': 'Thoracic Rotation', 'sets': 3, 'reps': '10/side', 'burnKcal': 15},
        {'name': 'Wall Push Ups', 'sets': 3, 'reps': '12', 'burnKcal': 25},
        {'name': 'Farmer’s Walk', 'sets': 3, 'reps': '30m', 'burnKcal': 30},
        {'name': 'Hip Circles', 'sets': 3, 'reps': '10/side', 'burnKcal': 15},
      ]},
      {'day': 5, 'label': 'Resistance (Master Focus)', 'exercises': [
        {'name': 'Trap Bar Deadlift (Light)', 'sets': 3, 'reps': '8', 'burnKcal': 45},
        {'name': 'Incline Push Ups', 'sets': 3, 'reps': '10', 'burnKcal': 30},
        {'name': 'Dumbbell Rows', 'sets': 3, 'reps': '12', 'burnKcal': 35},
        {'name': 'Pallof Press', 'sets': 3, 'reps': '12/side', 'burnKcal': 20},
      ]},
      {'day': 6, 'label': 'LISS Cardio', 'exercises': [
        {'name': 'Swimming or Walking', 'sets': 1, 'reps': '30 min', 'burnKcal': 200},
      ]},
      {'day': 7, 'label': 'Rest Day', 'exercises': []},
    ],

  };

  /// Generates a comprehensive health protocol (Nutrition + Workout Strategy)
  static Future<Map<String, dynamic>> generateProtocol(UserModel profile) async {
    try {
      final prompt = 'Name: ${profile.name}, Goal: ${profile.goal}, Age: ${profile.metrics['age']}, Gender: ${profile.metrics['gender']}';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'JSON ONLY. NO CONVERSATION. Available template_id list: [hypertrophy_ppl, strength_upper_lower, fat_loss_circuit, longevity_functional, hypertrophy_female, longevity_master]. Select ONE based on Goal, Age, and Gender. 6-day split (Mon-Sat are work days, Sun is rest). Format: {"nutrition":{"calories":2500,"protein":180,"carbs":300,"fats":80},"workout":{"focus":"Hypertrophy","priority":"Heavy Compounding","template_id":"hypertrophy_ppl"}}'
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens': 300,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) throw 'Status ${response.statusCode}';

      final body = jsonDecode(response.body);
      final text = body['choices'][0]['message']['content'] as String;
      
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
      if (match == null) throw 'No JSON';
      
      final aiResponse = jsonDecode(match.group(0)!);

      // Hybrid Merge: AI Strategy + Local Template
      final templateId = aiResponse['workout']?['template_id'] ?? 'hypertrophy_ppl';
      final List<Map<String, dynamic>> weeklyPlan = _workoutTemplates[templateId] ?? _workoutTemplates['hypertrophy_ppl']!;
      
      // Dynamic Personalization Layer: Adjust volume based on age
      final personalizedPlan = _personalizeVolume(weeklyPlan, profile.metrics['age'] ?? 25);

      return {
        'nutrition': aiResponse['nutrition'],
        'workout': {
          'focus': aiResponse['workout']?['focus'] ?? 'General',
          'priority': aiResponse['workout']?['priority'] ?? 'Foundation',
          'weekly_plan': personalizedPlan,
        }
      };
    } catch (e) {
      debugPrint('Protocol Generation Failed: $e. Using fallback.');
      final List<Map<String, dynamic>> weeklyPlan = _workoutTemplates['hypertrophy_ppl']!;
      return {
        'nutrition': {"calories": 2500, "protein": 180, "carbs": 300, "fats": 80},
        'workout': {
          'focus': 'Hypertrophy',
          'priority': 'Heavy Compounding',
          'weekly_plan': weeklyPlan,
        }
      };
    }
  }

  /// Adjusts workout volume (reps/intensity) based on biological age for longevity/safety.
  static List<Map<String, dynamic>> _personalizeVolume(List<Map<String, dynamic>> plan, int age) {
    if (age < 45) return plan; // No adjustments for younger adults

    return plan.map((day) {
      final exercises = List<Map<String, dynamic>>.from(day['exercises'] ?? []);
      final personalizedExercises = exercises.map((ex) {
        final Map<String, dynamic> personalized = Map.from(ex);
        
        // Strategy: Higher Reps, Lower Stress for Masters (45+)
        if (age >= 45 && age < 60) {
          personalized['reps'] = '${personalized['reps']} (+2)'; 
        } else if (age >= 60) {
          personalized['reps'] = '${personalized['reps']} (+4)';
          personalized['sets'] = (personalized['sets'] as int) > 2 ? personalized['sets'] - 1 : personalized['sets'];
        }
        
        return personalized;
      }).toList();
      
      return {...day, 'exercises': personalizedExercises};
    }).toList();
  }

  /// Generates a hype-inducing tweet for a completed workout session.
  static Future<String> generateShareTweet({
    required String sessionName,
    required int totalBurned,
    required int completedSets,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),

        headers: {
          'Authorization': 'Bearer ${Secrets.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a hype-man for a fitness app called Lift Lab. Generate a short, high-energy tweet (max 200 chars) for a user who just finished a workout. Include the stats provided. Use emojis. ONLY return the tweet text, no quotes or conversation.'
            },
            {
              'role': 'user',
              'content': 'Session: $sessionName, Burned: $totalBurned kcal, Sets: $completedSets'
            },
          ],
          'temperature': 0.7,
          'max_tokens': 100,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['choices'][0]['message']['content']?.toString().trim() ?? "Just crushed another workout at Lift Lab! 🔥";
      }
      return "Just crushed a $sessionName session! $totalBurned kcal down. 💪 #LiftLab";
    } catch (e) {
      return "Workout complete! $totalBurned kcal burned. #LiftLab";
    }
  }
}


