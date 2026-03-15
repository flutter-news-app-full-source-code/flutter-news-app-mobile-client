import 'dart:io' as io;

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_ui/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:veritai_mobile/app/bloc/app_bloc.dart';
import 'package:veritai_mobile/app/models/app_life_cycle_status.dart';
import 'package:veritai_mobile/headlines_feed/bloc/headlines_feed_bloc.dart';
import 'package:veritai_mobile/headlines_feed/view/headlines_feed_page.dart';
import 'package:veritai_mobile/l10n/app_localizations.dart';

class MockHeadlinesFeedBloc
    extends MockBloc<HeadlinesFeedEvent, HeadlinesFeedState>
    implements HeadlinesFeedBloc {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class TestHttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Mock implements io.HttpClient {
  _MockHttpClient() {
    when(
      () => getUrl(any<Uri>()),
    ).thenAnswer((_) async => _MockHttpClientRequest());
  }
}

class _MockHttpClientRequest extends Mock implements io.HttpClientRequest {
  _MockHttpClientRequest() {
    when(() => headers).thenReturn(_MockHttpHeaders());
    when(close).thenAnswer((_) async => _MockHttpClientResponse());
  }
}

class _MockHttpHeaders extends Mock implements io.HttpHeaders {}

class _MockHttpClientResponse extends Mock implements io.HttpClientResponse {
  _MockHttpClientResponse() {
    when(() => statusCode).thenReturn(200);
    when(() => contentLength).thenReturn(kTransparentImage.length);
    when(
      () => compressionState,
    ).thenReturn(io.HttpClientResponseCompressionState.notCompressed);
    when(
      () => listen(
        any(),
        onError: any(named: 'onError'),
        onDone: any(named: 'onDone'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      onData(kTransparentImage);
      onDone?.call();
      return Stream<List<int>>.fromIterable([kTransparentImage]).listen(null);
    });
  }
}

const List<int> kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

void main() {
  late HeadlinesFeedBloc headlinesFeedBloc;
  late AppBloc appBloc;

  final user = User(
    id: 'user-id',
    email: 'test@test.com',
    role: UserRole.user,
    tier: AccessTier.standard,
    createdAt: DateTime.now(),
  );

  final headline1 = Headline(
    id: 'h1',
    title: const {SupportedLanguage.en: 'Title 1'},
    url: 'url1',
    imageUrl: 'imageUrl1',
    source: Source(
      id: 's1',
      name: const {SupportedLanguage.en: 'Source 1'},
      description: const {SupportedLanguage.en: 'Desc'},
      url: '',
      logoUrl: '',
      sourceType: SourceType.newsAgency,
      language: SupportedLanguage.en,
      headquarters: const Country(
        isoCode: 'US',
        name: {SupportedLanguage.en: 'USA'},
        flagUrl: 'f',
        id: 'c',
      ),
      createdAt: DateTime(2023),
      updatedAt: DateTime(2023),
      status: ContentStatus.active,
    ),
    mentionedCountries: const [
      Country(
        isoCode: 'US',
        name: {SupportedLanguage.en: 'USA'},
        flagUrl: 'f',
        id: 'c',
      ),
    ],
    topic: Topic(
      id: 't1',
      name: const {SupportedLanguage.en: 'Topic 1'},
      description: const {SupportedLanguage.en: 'Desc'},
      iconUrl: '',
      createdAt: DateTime(2023),
      updatedAt: DateTime(2023),
      status: ContentStatus.active,
    ),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    status: ContentStatus.active,
    isBreaking: false,
  );

  final remoteConfig = RemoteConfig(
    id: 'config',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    app: const AppConfig(
      maintenance: MaintenanceConfig(isUnderMaintenance: false),
      update: UpdateConfig(
        latestAppVersion: '1.0.0',
        isLatestVersionOnly: false,
        iosUpdateUrl: '',
        androidUpdateUrl: '',
      ),
      general: GeneralAppConfig(termsOfServiceUrl: '', privacyPolicyUrl: ''),
      localization: LocalizationConfig(
        enabledLanguages: [SupportedLanguage.en],
        defaultLanguage: SupportedLanguage.en,
      ),
    ),
    features: const FeaturesConfig(
      onboarding: OnboardingConfig(
        isEnabled: true,
        appTour: AppTourConfig(isEnabled: true, isSkippable: true),
        initialPersonalization: InitialPersonalizationConfig(
          isEnabled: true,
          isSkippable: true,
          isCountrySelectionEnabled: true,
          isTopicSelectionEnabled: true,
          isSourceSelectionEnabled: true,
        ),
      ),
      analytics: AnalyticsConfig(
        enabled: true,
        activeProvider: AnalyticsProviders.firebase,
        disabledEvents: {},
        eventSamplingRates: {},
      ),
      ads: AdConfig(
        enabled: false,
        primaryAdPlatform: AdPlatformType.admob,
        platformAdIdentifiers: {},
        feedAdConfiguration: FeedAdConfiguration(
          enabled: false,
          adType: AdType.native,
          visibleTo: {},
        ),
        navigationAdConfiguration: NavigationAdConfiguration(
          enabled: false,
          visibleTo: {},
        ),
      ),
      pushNotifications: PushNotificationConfig(
        enabled: false,
        primaryProvider: PushNotificationProviders.firebase,
        deliveryConfigs: {},
      ),
      feed: FeedConfig(
        itemClickBehavior: FeedItemClickBehavior.defaultBehavior,
        decorators: {},
      ),
      community: CommunityConfig(
        enabled: true,
        engagement: EngagementConfig(
          enabled: true,
          engagementMode: EngagementMode.reactionsAndComments,
        ),
        reporting: ReportingConfig(
          headlineReportingEnabled: true,
          sourceReportingEnabled: true,
          commentReportingEnabled: true,
          enabled: true,
        ),
        appReview: AppReviewConfig(
          enabled: false,
          interactionCycleThreshold: 10,
          initialPromptCooldownDays: 30,
          eligiblePositiveInteractions: [],
          isNegativeFeedbackFollowUpEnabled: false,
          isPositiveFeedbackFollowUpEnabled: false,
        ),
      ),
      rewards: RewardsConfig(enabled: true, rewards: {}),
    ),
    user: const UserConfig(
      limits: UserLimitsConfig(
        followedItems: {},
        savedHeadlines: {},
        savedHeadlineFilters: {},
        commentsPerDay: {},
        reactionsPerDay: {},
        reportsPerDay: {},
      ),
    ),
  );

  setUpAll(() {
    registerFallbackValue(NavigationHandled());
    registerFallbackValue(Uri());
  });

  setUp(() {
    io.HttpOverrides.global = TestHttpOverrides();
    headlinesFeedBloc = MockHeadlinesFeedBloc();
    appBloc = MockAppBloc();

    when(() => appBloc.state).thenReturn(
      AppState(
        status: AppLifeCycleStatus.authenticated,
        user: user,
        remoteConfig: remoteConfig,
        userContentPreferences: const UserContentPreferences(
          id: 'prefs',
          followedCountries: [],
          followedSources: [],
          followedTopics: [],
          followedPersons: [],
          savedHeadlines: [],
          savedHeadlineFilters: [],
        ),
        settings: const AppSettings(
          id: 'settings-id',
          language: SupportedLanguage.en,
          displaySettings: DisplaySettings(
            baseTheme: AppBaseTheme.light,
            accentTheme: AppAccentTheme.defaultBlue,
            fontFamily: 'Roboto',
            textScaleFactor: AppTextScaleFactor.medium,
            fontWeight: AppFontWeight.regular,
          ),
          feedSettings: FeedSettings(
            feedItemDensity: FeedItemDensity.standard,
            feedItemImageStyle: FeedItemImageStyle.smallThumbnail,
            feedItemClickBehavior: FeedItemClickBehavior.internalNavigation,
          ),
        ),
      ),
    );

    when(() => headlinesFeedBloc.stream).thenAnswer(
      (_) => Stream.value(
        const HeadlinesFeedState(status: HeadlinesFeedStatus.initial),
      ),
    );
  });

  tearDown(() {
    io.HttpOverrides.global = null;
  });

  Widget buildTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: headlinesFeedBloc),
        BlocProvider.value(value: appBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...UiKitLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HeadlinesFeedPage(),
      ),
    );
  }

  group('HeadlinesFeedPage', () {
    testWidgets(
      'renders loading indicator when status is loading and feed is empty',
      (tester) async {
        when(() => headlinesFeedBloc.state).thenReturn(
          const HeadlinesFeedState(
            status: HeadlinesFeedStatus.loading,
            feedItems: [],
          ),
        );
        await tester.pumpWidget(buildTestWidget());
        expect(find.byType(LoadingStateWidget), findsOneWidget);
      },
    );

    testWidgets('renders error widget when status is failure', (tester) async {
      when(() => headlinesFeedBloc.state).thenReturn(
        const HeadlinesFeedState(
          status: HeadlinesFeedStatus.failure,
          feedItems: [],
        ),
      );
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(FailureStateWidget), findsOneWidget);
    });

    testWidgets('renders feed items when status is success', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      addTearDown(tester.view.resetPhysicalSize);

      final headlines = List.generate(5, (index) => headline1);
      when(() => headlinesFeedBloc.state).thenReturn(
        HeadlinesFeedState(
          status: HeadlinesFeedStatus.success,
          feedItems: headlines,
        ),
      );
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(CustomScrollView), findsOneWidget); // This is fine
      // Make this finder more specific to the main feed list
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SliverList &&
              widget.delegate is SliverChildBuilderDelegate,
        ),
        findsOneWidget,
      );
      expect(
        find.text(headline1.title[SupportedLanguage.en]!, skipOffstage: false),
        findsNWidgets(5),
      );
    });

    testWidgets('adds HeadlinesFeedFetchRequested when scrolled to bottom', (
      tester,
    ) async {
      when(() => headlinesFeedBloc.state).thenReturn(
        HeadlinesFeedState(
          status: HeadlinesFeedStatus.success,
          feedItems: List.generate(10, (index) => headline1),
          hasMore: true,
        ),
      );
      await tester.pumpWidget(buildTestWidget());
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
      await tester.pump();
      verify(
        () => headlinesFeedBloc.add(
          any(that: isA<HeadlinesFeedFetchRequested>()),
        ),
      ).called(1);
    });
  });
}
