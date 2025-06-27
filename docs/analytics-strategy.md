# Analytics Strategy - Artifex

## Overview
Comprehensive analytics strategy for Artifex AI photo transformation app, focusing on user behavior insights, feature optimization, and business metrics.

## Analytics Architecture

### 1. Centralized Analytics Interface
```dart
abstract class AnalyticsClient {
  Future<void> initialize();
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters);
  Future<void> trackScreen(String screenName);
  Future<void> setAnalyticsEnabled(bool enabled);
}
```

### 2. Multi-Provider Facade Pattern
```dart
class AnalyticsFacade implements AnalyticsClient {
  final List<AnalyticsClient> _clients;
  
  AnalyticsFacade(this._clients);
  
  @override
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    for (final client in _clients) {
      unawaited(client.trackEvent(eventName, parameters));
    }
  }
}
```

### 3. Provider Implementations
- **Firebase Analytics**: Primary analytics platform
- **PostHog**: Open-source alternative for self-hosted analytics
- **Debug Analytics**: Console logging for development

## Key Events to Track

### User Journey Events
```dart
class AnalyticsEvents {
  // Onboarding
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';
  
  // Photo Capture
  static const String photoCaptured = 'photo_captured';
  static const String photoUploaded = 'photo_uploaded';
  static const String photoSelected = 'photo_selected';
  
  // AI Transformation
  static const String transformationStarted = 'transformation_started';
  static const String transformationCompleted = 'transformation_completed';
  static const String transformationFailed = 'transformation_failed';
  static const String filterSelected = 'filter_selected';
  
  // Social & Export
  static const String photoShared = 'photo_shared';
  static const String photoExported = 'photo_exported';
  static const String photoSaved = 'photo_saved';
  
  // Engagement
  static const String appOpened = 'app_opened';
  static const String sessionStarted = 'session_started';
  static const String featureDiscovered = 'feature_discovered';
  
  // Business Metrics
  static const String premiumViewed = 'premium_viewed';
  static const String subscriptionStarted = 'subscription_started';
  static const String purchaseCompleted = 'purchase_completed';
}
```

### Event Parameters
```dart
class AnalyticsParameters {
  // Photo events
  static const String photoSource = 'photo_source'; // camera, gallery
  static const String photoSize = 'photo_size';
  static const String processingTime = 'processing_time';
  
  // Transformation events  
  static const String filterType = 'filter_type';
  static const String transformationStyle = 'transformation_style';
  static const String apiProvider = 'api_provider'; // dalle, midjourney
  static const String success = 'success';
  static const String errorType = 'error_type';
  
  // Sharing events
  static const String shareMethod = 'share_method'; // instagram, twitter, save
  static const String exportFormat = 'export_format'; // jpg, png
  
  // User properties
  static const String userType = 'user_type'; // free, premium
  static const String appVersion = 'app_version';
  static const String platform = 'platform';
}
```

## Privacy & Compliance

### 1. User Consent Management
```dart
class AnalyticsConsent {
  static const String _consentKey = 'analytics_consent';
  
  static Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }
  
  static Future<void> setConsent(bool hasConsent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, hasConsent);
    
    // Update analytics clients
    await AnalyticsService.instance.setAnalyticsEnabled(hasConsent);
  }
}
```

### 2. GDPR Compliance
- Opt-in analytics consent during onboarding
- Clear privacy policy explaining data collection
- Ability to disable analytics in settings
- Data retention policies

### 3. Data Anonymization
- No personally identifiable information in events
- Hash user identifiers
- Aggregate metrics only

## Implementation Plan

### Phase 1: Foundation
1. Create analytics client interface
2. Implement Firebase Analytics client
3. Add debug analytics client
4. Create analytics facade
5. Implement consent management

### Phase 2: Core Events
1. Track onboarding flow completion
2. Track photo capture/upload events
3. Track transformation events
4. Track basic app usage metrics

### Phase 3: Advanced Analytics
1. Add PostHog for detailed user journeys
2. Implement custom dashboards
3. Add A/B testing framework
4. Performance and error analytics

### Phase 4: Business Intelligence
1. Revenue analytics for premium features
2. Conversion funnel analysis
3. User lifetime value tracking
4. Churn prediction metrics

## Analytics Service Integration

### Riverpod Provider Setup
```dart
@riverpod
AnalyticsClient analyticsClient(Ref ref) {
  final clients = <AnalyticsClient>[
    FirebaseAnalyticsClient(),
    if (AppConstants.isDebug) DebugAnalyticsClient(),
  ];
  
  return AnalyticsFacade(clients);
}

@riverpod
class AnalyticsService extends _$AnalyticsService {
  @override
  AnalyticsState build() => const AnalyticsState.initial();
  
  Future<void> initialize() async {
    final client = ref.read(analyticsClientProvider);
    await client.initialize();
    
    if (await AnalyticsConsent.hasConsent()) {
      await client.setAnalyticsEnabled(true);
    }
  }
  
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    if (!await AnalyticsConsent.hasConsent()) return;
    
    final client = ref.read(analyticsClientProvider);
    await client.trackEvent(eventName, parameters ?? {});
  }
}
```

## Key Metrics Dashboard

### User Engagement
- Daily/Monthly Active Users
- Session duration
- Feature adoption rates
- Onboarding completion rate

### Product Performance
- Photo transformation success rate
- Average processing time
- Most popular filters
- User retention by feature usage

### Business Metrics
- Conversion to premium
- Revenue per user
- Customer acquisition cost
- Lifetime value

### Technical Metrics
- App crash rate
- API response times
- Error rates by feature
- Performance bottlenecks

## Dependencies Required

```yaml
dependencies:
  # Analytics
  firebase_analytics: ^10.7.0
  posthog_flutter: ^4.0.0
  
  # Privacy
  app_tracking_transparency: ^2.0.4
  
dev_dependencies:
  # Analytics testing
  fake_analytics: ^1.0.0
```

## Testing Strategy

### Unit Tests
- Analytics client implementations
- Event parameter validation
- Consent management logic

### Integration Tests
- End-to-end event tracking
- Multi-provider facade behavior
- Privacy compliance flows

### Manual Testing
- Verify events in Firebase Console
- Test consent flow on real devices
- Validate event parameters

## Migration Plan

### Current State
- Basic feature flag for analytics in AppConstants
- No analytics implementation

### Implementation Steps
1. Add analytics dependencies to pubspec.yaml
2. Create analytics client interface and implementations
3. Integrate with existing app initialization
4. Add consent management to onboarding flow
5. Instrument key user flows with events
6. Set up analytics dashboards
7. Implement privacy controls in settings

This strategy ensures we build a robust, privacy-compliant analytics system that provides valuable insights for optimizing the Artifex user experience.