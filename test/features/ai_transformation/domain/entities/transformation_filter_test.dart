import 'package:artifex/features/ai_transformation/domain/entities/transformation_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransformationFilter', () {
    test(
      'should create a TransformationFilter with all required properties',
      () {
        // Arrange & Act
        const filter = TransformationFilter(
          id: 'test_filter',
          name: 'Test Filter',
          description: 'Test Description',
          prompt: 'Test prompt for AI',
          icon: Icons.science,
          color: Colors.blue,
        );

        // Assert
        expect(filter.id, equals('test_filter'));
        expect(filter.name, equals('Test Filter'));
        expect(filter.description, equals('Test Description'));
        expect(filter.prompt, equals('Test prompt for AI'));
        expect(filter.icon, equals(Icons.science));
        expect(filter.color, equals(Colors.blue));
      },
    );

    test('should have exactly 5 available filters', () {
      // Act
      const filters = TransformationFilter.availableFilters;

      // Assert
      expect(filters.length, equals(5));
    });

    test('should have all required filter types in availableFilters', () {
      // Act
      const filters = TransformationFilter.availableFilters;
      final filterIds = filters.map((f) => f.id).toSet();

      // Assert
      expect(filterIds, contains('kids_drawing_real'));
      expect(filterIds, contains('send_to_mars'));
      expect(filterIds, contains('renaissance_portrait'));
      expect(filterIds, contains('cyberpunk_city'));
      expect(filterIds, contains('watercolor_dream'));
    });

    test('each available filter should have unique id', () {
      // Act
      const filters = TransformationFilter.availableFilters;
      final filterIds = filters.map((f) => f.id).toList();

      // Assert
      expect(filterIds.length, equals(filterIds.toSet().length));
    });

    test('each available filter should have valid properties', () {
      // Act
      const filters = TransformationFilter.availableFilters;

      // Assert
      for (final filter in filters) {
        expect(filter.id, isNotEmpty);
        expect(filter.name, isNotEmpty);
        expect(filter.description, isNotEmpty);
        expect(filter.prompt, isNotEmpty);
        expect(filter.icon, isNotNull);
        expect(filter.color, isNotNull);
      }
    });

    test('filter prompts should contain transformation instructions', () {
      // Act
      const filters = TransformationFilter.availableFilters;

      // Assert
      for (final filter in filters) {
        // Check that prompt contains either 'transform' or 'place' (for Mars filter)
        expect(
          filter.prompt.toLowerCase().contains('transform') ||
              filter.prompt.toLowerCase().contains('place'),
          isTrue,
          reason:
              'Prompt should contain transformation instruction for ${filter.name}',
        );
        expect(
          filter.prompt.length,
          greaterThan(50),
          reason: 'Prompt should be detailed enough for AI',
        );
      }
    });
  });
}
