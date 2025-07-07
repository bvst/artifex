import 'package:artifex/features/ai_transformation/domain/entities/ai_configuration.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIConfiguration', () {
    group('basic configuration', () {
      test('should create configuration with required parameters', () {
        // Arrange & Act
        const config = AIConfiguration(openaiApiKey: 'test-key');

        // Assert
        expect(config.openaiApiKey, equals('test-key'));
        expect(config.defaultProvider, equals(AIProviderType.openai));
        expect(config.enableCostEstimation, isTrue);
        expect(config.timeoutDuration, equals(const Duration(seconds: 30)));
        expect(config.retryAttempts, equals(3));
      });

      test('should create configuration with custom defaults', () {
        // Arrange & Act
        const config = AIConfiguration(
          openaiApiKey: 'test-key',
          defaultProvider: AIProviderType.gemini,
          enableCostEstimation: false,
          timeoutDuration: Duration(seconds: 60),
          retryAttempts: 5,
          geminiApiKey: 'gemini-key',
        );

        // Assert
        expect(config.defaultProvider, equals(AIProviderType.gemini));
        expect(config.enableCostEstimation, isFalse);
        expect(config.timeoutDuration, equals(const Duration(seconds: 60)));
        expect(config.retryAttempts, equals(5));
        expect(config.geminiApiKey, equals('gemini-key'));
      });
    });

    group('isProviderConfigured', () {
      test('should return true for OpenAI when key is provided', () {
        // Arrange
        const config = AIConfiguration(openaiApiKey: 'test-key');

        // Act & Assert
        expect(config.isProviderConfigured(AIProviderType.openai), isTrue);
      });

      test('should return false for OpenAI when key is empty', () {
        // Arrange
        const config = AIConfiguration(openaiApiKey: '');

        // Act & Assert
        expect(config.isProviderConfigured(AIProviderType.openai), isFalse);
      });

      test('should return true for Gemini when key is provided', () {
        // Arrange
        const config = AIConfiguration(
          openaiApiKey: 'openai-key',
          geminiApiKey: 'gemini-key',
        );

        // Act & Assert
        expect(config.isProviderConfigured(AIProviderType.gemini), isTrue);
      });

      test('should return false for Gemini when key is null', () {
        // Arrange
        const config = AIConfiguration(openaiApiKey: 'openai-key');

        // Act & Assert
        expect(config.isProviderConfigured(AIProviderType.gemini), isFalse);
      });

      test('should return false for Claude when key is null', () {
        // Arrange
        const config = AIConfiguration(openaiApiKey: 'openai-key');

        // Act & Assert
        expect(config.isProviderConfigured(AIProviderType.claude), isFalse);
      });

      test('should return false for Stability when key is null', () {
        // Arrange
        const config = AIConfiguration(openaiApiKey: 'openai-key');

        // Act & Assert
        expect(config.isProviderConfigured(AIProviderType.stability), isFalse);
      });
    });

    group('configuredProviders', () {
      test('should return only OpenAI when only OpenAI key is provided', () {
        // Arrange
        const config = AIConfiguration(openaiApiKey: 'test-key');

        // Act
        final providers = config.configuredProviders;

        // Assert
        expect(providers, hasLength(1));
        expect(providers, contains(AIProviderType.openai));
      });

      test(
        'should return multiple providers when multiple keys are provided',
        () {
          // Arrange
          const config = AIConfiguration(
            openaiApiKey: 'openai-key',
            geminiApiKey: 'gemini-key',
            claudeApiKey: 'claude-key',
          );

          // Act
          final providers = config.configuredProviders;

          // Assert
          expect(providers, hasLength(3));
          expect(providers, contains(AIProviderType.openai));
          expect(providers, contains(AIProviderType.gemini));
          expect(providers, contains(AIProviderType.claude));
        },
      );

      test('should exclude providers with empty keys', () {
        // Arrange
        const config = AIConfiguration(
          openaiApiKey: 'openai-key',
          geminiApiKey: '', // Empty key should be excluded
          claudeApiKey: 'claude-key',
        );

        // Act
        final providers = config.configuredProviders;

        // Assert
        expect(providers, hasLength(2));
        expect(providers, contains(AIProviderType.openai));
        expect(providers, contains(AIProviderType.claude));
        expect(providers, isNot(contains(AIProviderType.gemini)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        // Arrange
        const original = AIConfiguration(openaiApiKey: 'original-key');

        // Act
        final updated = original.copyWith(
          defaultProvider: AIProviderType.gemini,
          enableCostEstimation: false,
          geminiApiKey: 'new-gemini-key',
        );

        // Assert
        expect(updated.openaiApiKey, equals('original-key')); // Unchanged
        expect(
          updated.defaultProvider,
          equals(AIProviderType.gemini),
        ); // Changed
        expect(updated.enableCostEstimation, isFalse); // Changed
        expect(updated.geminiApiKey, equals('new-gemini-key')); // Changed
      });

      test('should preserve original values when no changes specified', () {
        // Arrange
        const original = AIConfiguration(openaiApiKey: 'test-key');

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.openaiApiKey, equals(original.openaiApiKey));
        expect(copy.defaultProvider, equals(original.defaultProvider));
        expect(
          copy.enableCostEstimation,
          equals(original.enableCostEstimation),
        );
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const config1 = AIConfiguration(openaiApiKey: 'test-key');
        const config2 = AIConfiguration(openaiApiKey: 'test-key');

        // Act & Assert
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const config1 = AIConfiguration(openaiApiKey: 'test-key-1');
        const config2 = AIConfiguration(openaiApiKey: 'test-key-2');

        // Act & Assert
        expect(config1, isNot(equals(config2)));
      });
    });

    group('toString', () {
      test('should provide meaningful string representation', () {
        // Arrange
        const config = AIConfiguration(
          openaiApiKey: 'test-key',
          enableCostEstimation: false,
          geminiApiKey: 'gemini-key',
        );

        // Act
        final string = config.toString();

        // Assert
        expect(string, contains('AIConfiguration'));
        expect(string, contains('defaultProvider: AIProviderType.openai'));
        expect(string, contains('enableCostEstimation: false'));
        expect(string, contains('configuredProviders'));
        expect(string, contains('DALL-E 3')); // Display name
        expect(string, contains('Gemini')); // Display name
      });
    });
  });
}
