import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugPrefsPage extends StatefulWidget {
  const DebugPrefsPage({super.key});

  @override
  State<DebugPrefsPage> createState() => _DebugPrefsPageState();
}

class _DebugPrefsPageState extends State<DebugPrefsPage> {
  Map<String, dynamic> prefsData = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    Map<String, dynamic> all = {};
    for (var key in keys) {
      final value = prefs.get(key);
      all[key] = value;
    }

    setState(() {
      prefsData = all;
    });
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      prefsData = {};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All SharedPreferences cleared!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debug SharedPreferences"),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearPrefs),
        ],
      ),
      body: prefsData.isEmpty
          ? const Center(child: Text("No SharedPreferences found"))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: prefsData.entries.map((entry) {
                String displayValue = entry.value.toString();

                // Pretty print if it's JSON
                if (entry.value is String &&
                    (entry.value.toString().startsWith("{") ||
                        entry.value.toString().startsWith("["))) {
                  try {
                    final decoded = jsonDecode(entry.value);
                    displayValue = const JsonEncoder.withIndent(
                      "  ",
                    ).convert(decoded);
                  } catch (_) {}
                }

                if (entry.value is List) {
                  displayValue = (entry.value as List)
                      .map((e) => e.toString())
                      .join("\n");
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(displayValue),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
