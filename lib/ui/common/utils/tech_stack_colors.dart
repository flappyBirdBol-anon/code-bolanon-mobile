import 'package:flutter/material.dart';

class TechStackColors {
  static final Map<String, Color> languageColors = {
    'JavaScript': Colors.yellow[700]!,
    'Python': Colors.blue[700]!,
    'Java': Colors.orange[800]!,
    'Ruby': Colors.red[700]!,
    'C#': Colors.purple[700]!,
    'PHP': Colors.indigo[600]!,
    'Swift': Colors.orange[600]!,
    'Kotlin': Colors.purple[600]!,
    'Go': Colors.cyan[700]!,
    'TypeScript': Colors.blue[600]!,
    'C++': Colors.blue[800]!,
    'Rust': Colors.deepOrange[800]!,
    'Development': Colors.teal[700]!,
    'Design': Colors.pink[600]!,
    'Tech': Colors.indigo[500]!,
    'Marketing': Colors.green[700]!,
    'Business': Colors.amber[800]!,
    'Sports': Colors.lightBlue[700]!,
    'IT Software': Colors.deepPurple[600]!,
    'Flutter': Colors.blue[400]!,
    'Dart': Colors.blue[600]!,
    'Firebase': Colors.orange[600]!,
    'REST API': Colors.green[600]!,
    'Node.js': Colors.green[700]!,
    'React': Colors.blue[400]!,
    'MongoDB': Colors.green[800]!,
  };

  static Color getColorForTech(String tech, ThemeData theme) {
    return languageColors[tech] ?? theme.primaryColor;
  }
}
