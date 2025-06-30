import 'package:flutter/material.dart';

/// Entity representing a transformation filter
class TransformationFilter {
  const TransformationFilter({
    required this.id,
    required this.name,
    required this.description,
    required this.prompt,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final String prompt;
  final IconData icon;
  final Color color;

  /// Available transformation filters
  static const List<TransformationFilter> availableFilters = [
    TransformationFilter(
      id: 'kids_drawing_real',
      name: 'Make Kids Drawing Real',
      description: 'Transform sketches into realistic images',
      prompt:
          'Transform this children\'s drawing into a photorealistic image, '
          'maintaining the original composition but with realistic textures, '
          'lighting, and proportions',
      icon: Icons.draw,
      color: Color(0xFF4CAF50), // Green
    ),
    TransformationFilter(
      id: 'send_to_mars',
      name: 'Send to Mars',
      description: 'Place subjects in Martian landscapes',
      prompt:
          'Place the subject of this image on the surface of Mars with '
          'realistic Martian landscape, red sky, rocky terrain, and appropriate '
          'lighting as if they were actually on Mars',
      icon: Icons.rocket_launch,
      color: Color(0xFFFF5722), // Deep Orange
    ),
    TransformationFilter(
      id: 'renaissance_portrait',
      name: 'Renaissance Portrait',
      description: 'Classical art style transformation',
      prompt:
          'Transform this image into a Renaissance-style oil painting '
          'portrait with classical composition, dramatic lighting, rich colors, '
          'and the artistic style of masters like Leonardo da Vinci or Rembrandt',
      icon: Icons.portrait,
      color: Color(0xFF795548), // Brown
    ),
    TransformationFilter(
      id: 'cyberpunk_city',
      name: 'Cyberpunk City',
      description: 'Futuristic urban environment',
      prompt:
          'Transform this image into a cyberpunk style with neon lights, '
          'futuristic technology, holographic displays, rain-slicked streets, '
          'and a dark dystopian atmosphere',
      icon: Icons.location_city,
      color: Color(0xFF9C27B0), // Purple
    ),
    TransformationFilter(
      id: 'watercolor_dream',
      name: 'Watercolor Dream',
      description: 'Artistic watercolor painting style',
      prompt:
          'Transform this image into a beautiful watercolor painting with '
          'soft edges, flowing colors, artistic brush strokes, and dreamy '
          'atmospheric effects',
      icon: Icons.brush,
      color: Color(0xFF2196F3), // Blue
    ),
  ];
}
