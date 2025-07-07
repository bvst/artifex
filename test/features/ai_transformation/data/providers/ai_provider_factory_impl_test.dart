import 'package:artifex/features/ai_transformation/data/providers/ai_provider_factory_impl.dart';
import 'package:artifex/features/ai_transformation/data/providers/dalle_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_configuration.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'ai_provider_factory_impl_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('AIProviderFactoryImpl', () {
    late AIProviderFactoryImpl factory;
    late MockDio mockDio;
    late AIConfiguration configuration;

    setUp(() {
      mockDio = MockDio();
      configuration = const AIConfiguration(openaiApiKey: 'test-api-key');
      factory = AIProviderFactoryImpl(
        dio: mockDio,
        configuration: configuration,
      );
    });

    group('createProvider', () {
      test('should create DalleProvider for OpenAI type', () {
        // Act
        final provider = factory.createProvider(AIProviderType.openai);

        // Assert
        expect(provider, isA<DalleProvider>());
        expect(provider.providerType, equals(AIProviderType.openai));
      });

      test('should throw ArgumentError for unconfigured Gemini type', () {
        // Act & Assert
        expect(
          () => factory.createProvider(AIProviderType.gemini),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for unconfigured Claude type', () {
        // Act & Assert
        expect(
          () => factory.createProvider(AIProviderType.claude),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for unconfigured Stability type', () {
        // Act & Assert
        expect(
          () => factory.createProvider(AIProviderType.stability),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('defaultProvider', () {
      test('should return OpenAI provider by default', () {
        // Act
        final provider = factory.defaultProvider;

        // Assert
        expect(provider, isA<DalleProvider>());
        expect(provider.providerType, equals(AIProviderType.openai));
      });

      test('should return custom default provider when specified', () {
        // Arrange
        const customConfiguration = AIConfiguration(
          openaiApiKey: 'test-api-key',
        );
        final customFactory = AIProviderFactoryImpl(
          dio: mockDio,
          configuration: customConfiguration,
        );

        // Act
        final provider = customFactory.defaultProvider;

        // Assert
        expect(provider, isA<DalleProvider>());
        expect(provider.providerType, equals(AIProviderType.openai));
      });
    });

    group('availableProviders', () {
      test('should return list of available providers', () {
        // Act
        final providers = factory.availableProviders;

        // Assert
        expect(providers, isA<List<AIProviderType>>());
        expect(providers, contains(AIProviderType.openai));
        expect(providers.length, equals(1)); // Only OpenAI is implemented
      });
    });
  });
}
