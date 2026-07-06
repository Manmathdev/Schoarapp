import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/resource.dart';
import '../models/daily_task_item.dart';

class DataService {
  static const _keyTasks = 'boardTasks';
  static const _keyResources = 'boardResources';
  static const _keyDailyTasks = 'dailyTasks';
  static const _keyPlanner = 'boardPlanner';
  static const _keyHabits = 'boardHabits';

  static const _physicsColor = '#1565c0';
  static const _chemistryColor = '#2e7d32';
  static const _mathematicsColor = '#c2185b';
  static const _englishColor = '#00796b';
  static const _itColor = '#7b1fa2';
  static const _sanskritColor = '#ff8f00';

  Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyTasks);
      if (raw == null) return getDefaultTasks();
      final List<dynamic> jsonList = jsonDecode(raw);
      return jsonList.map((j) => Task.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return getDefaultTasks();
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_keyTasks, raw);
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  Future<List<Resource>> getResources() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyResources);
      if (raw == null) return getDefaultResources();
      final List<dynamic> jsonList = jsonDecode(raw);
      return jsonList.map((j) => Resource.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return getDefaultResources();
    }
  }

  Future<void> saveResources(List<Resource> resources) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(resources.map((r) => r.toJson()).toList());
      await prefs.setString(_keyResources, raw);
    } catch (e) {
      throw Exception('Failed to save resources: $e');
    }
  }

  Future<List<DailyTaskItem>> getDailyTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyDailyTasks);
      if (raw == null) return List.generate(5, (_) => const DailyTaskItem());
      final List<dynamic> jsonList = jsonDecode(raw);
      return jsonList.map((j) => DailyTaskItem.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return List.generate(5, (_) => const DailyTaskItem());
    }
  }

  Future<void> saveDailyTasks(List<DailyTaskItem> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_keyDailyTasks, raw);
    } catch (e) {
      throw Exception('Failed to save daily tasks: $e');
    }
  }

  Future<Map<String, String>> getPlanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyPlanner);
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (e) {
      return {};
    }
  }

  Future<void> savePlanner(Map<String, String> plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPlanner, jsonEncode(plan));
    } catch (e) {
      throw Exception('Failed to save planner: $e');
    }
  }

  Future<Map<int, List<bool>>> getHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyHabits);
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) {
        final list = (v as List<dynamic>).map((e) => e as bool).toList();
        return MapEntry(int.parse(k), list);
      });
    } catch (e) {
      return {};
    }
  }

  Future<void> saveHabits(Map<int, List<bool>> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = habits.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_keyHabits, jsonEncode(encoded));
    } catch (e) {
      throw Exception('Failed to save habits: $e');
    }
  }

  Future<void> clearPlannerAndHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPlanner);
      await prefs.remove(_keyHabits);
    } catch (e) {
      throw Exception('Failed to clear planner: $e');
    }
  }

  Future<void> resetCurriculum() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyTasks);
    } catch (e) {
      throw Exception('Failed to reset curriculum: $e');
    }
  }

  static List<Task> getDefaultTasks() {
    return [
      for (final t in _physicsTopics)
        Task(id: 100 + _physicsTopics.indexOf(t), subject: 'Physics', title: t, color: _physicsColor),
      for (final t in _chemistryTopics)
        Task(id: 200 + _chemistryTopics.indexOf(t), subject: 'Chemistry', title: t, color: _chemistryColor),
      for (final t in _mathTopics)
        Task(id: 300 + _mathTopics.indexOf(t), subject: 'Mathematics', title: t, color: _mathematicsColor),
      for (final t in _englishTopics)
        Task(id: 400 + _englishTopics.indexOf(t), subject: 'English', title: t, color: _englishColor),
      for (final t in _itTopics)
        Task(id: 500 + _itTopics.indexOf(t), subject: 'IT', title: t, color: _itColor),
      for (final t in _sanskritTopics)
        Task(id: 600 + _sanskritTopics.indexOf(t), subject: 'Sanskrit', title: t, color: _sanskritColor),
    ];
  }

  static List<Resource> getDefaultResources() {
    return [
      Resource(id: 1, title: 'CHSE Odisha Official Website', url: 'https://chseodisha.nic.in', subject: 'General', type: 'Website'),
      Resource(id: 2, title: 'CHSE Odisha PYQs (PDFs)', url: '/archive.html', subject: 'General', type: 'PDF'),
      Resource(id: 3, title: 'NCERT Official Textbooks (PDFs)', url: 'https://ncert.nic.in/textbook.php', subject: 'General', type: 'PDF'),
    ];
  }

  static const List<String> _physicsTopics = [
    'Electric charges & fields',
    'Electrostatic potential & Capitance',
    'Current electricity',
    'Moving charges & Magnetism',
    'Magnetism & Matter',
    'Electro Magnetic Induction',
    'Alternating Currents',
    'EM waves',
    'Ray optics',
    'Wave optics',
    'Dual nature',
    'Atoms',
    'Nuclei',
    'Semiconductors',
  ];

  static const List<String> _chemistryTopics = [
    'Solutions',
    'Electrochemistry',
    'Chemical kinetics',
    'd & f block',
    'Coordination compounds',
    'Haloalkanes & Haloarens',
    'Alcohols Phenols & Ethers',
    'Aldehydes ketones & carboxylic acids',
    'Amines',
    'Biomolecules',
  ];

  static const List<String> _mathTopics = [
    'Relations & functions',
    'Inverse trigonometric functions',
    'Matrices',
    'Determinants',
    'Continuity & differentiability',
    'Application of derivatives',
    'Integrals',
    'Application of integrals',
    'Differential equations',
    'Vectors',
    '3D-Geometry',
    'Linear programming',
    'Probability',
  ];

  static const List<String> _englishTopics = [
    'My greatest olympic prize',
    'On examinations',
    'The portrait of a lady',
    'The magic of teamwork',
    'Price of pollution',
    'Daffodils',
    'The ballad of Father Gilligan',
    'A psalm of life',
    'Television',
    'Money Madness',
    "The Doctor's word",
    'The nightangle & the rose',
    'Mystery of missing cap',
    "The monkey's paw",
    'My Mother',
    'Stay Hungry Stay Foolish',
    'Graphical reports',
    'Reports',
    'Passages',
    'Note-making',
    'Grammar',
  ];

  static const List<String> _itTopics = [
    'Computer networking',
    "Internet & it's applications",
    'Network security on internet',
    'Programming fundamentals',
    'HTML based web pages covering basic tags',
    'Database fundamentals',
    'Introduction to MySQL',
    'e-Business',
    'Front-end interface',
    'Back-end interface',
  ];

  static const List<String> _sanskritTopics = [
    'Kapothalubdhakatha',
    'Gunigunahinabibekaha',
    'Ramatapobanabhigamanam',
    'Gitasourabham',
    'Raghubansam',
    'Dhaturup',
    'Sabdarup',
    'Sandhi & Samash',
    'Translation',
  ];
}
