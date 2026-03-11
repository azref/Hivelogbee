import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ... (Enum AdScreen and InterstitialTrigger remain the same) ...
enum AdScreen {
  home,
  hiveList,
  hiveDetails,
  inspection,
  treatment,
  production,
  reminders,
  knowledge,
  settings,
  profile,
  statistics,
  weather,
  addHive,
  addInspection,
  addTreatment,
  addProduction,
  division,
  inspectionList,
  treatmentList,
}

enum InterstitialTrigger {
  addHive,
  addInspection,
  addTreatment,
  appExit,
  completeTask,
}


class AdService extends ChangeNotifier {
  // ... (All properties remain the same) ...
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final Map<AdScreen, BannerAd?> _bannerAds = {};
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  DateTime? _lastInterstitialShow;
  final int _interstitialCooldownMinutes = 3;
  int _actionsSinceLastAd = 0;
  final int _actionsBeforeAd = 2;

  static final Map<AdScreen, String> _bannerAdUnitIds = {
    AdScreen.home: _homeBannerAdUnitId,
    AdScreen.hiveList: _hiveListBannerAdUnitId,
    AdScreen.hiveDetails: _hiveDetailsBannerAdUnitId,
    AdScreen.inspection: _inspectionBannerAdUnitId,
    AdScreen.treatment: _treatmentBannerAdUnitId,
    AdScreen.production: _productionBannerAdUnitId,
    AdScreen.reminders: _remindersBannerAdUnitId,
    AdScreen.knowledge: _knowledgeBannerAdUnitId,
    AdScreen.settings: _settingsBannerAdUnitId,
    AdScreen.profile: _profileBannerAdUnitId,
    AdScreen.statistics: _statisticsBannerAdUnitId,
    AdScreen.weather: _weatherBannerAdUnitId,
    AdScreen.addHive: _genericBannerAdUnitId,
    AdScreen.addInspection: _genericBannerAdUnitId,
    AdScreen.addTreatment: _genericBannerAdUnitId,
    AdScreen.addProduction: _genericBannerAdUnitId,
    AdScreen.division: _genericBannerAdUnitId,
    AdScreen.inspectionList: _genericBannerAdUnitId,
    AdScreen.treatmentList: _genericBannerAdUnitId,
  };

  static final String _genericBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
      : 'ca-app-pub-3940256099942544/2934735716'; // Test ID

  static final String _homeBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _hiveListBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _hiveDetailsBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _inspectionBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _treatmentBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _productionBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _remindersBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _knowledgeBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _settingsBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _profileBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _statisticsBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _weatherBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  // ... (All other methods in AdService remain the same) ...
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _setupAppLifecycleListener();
  }

  void _setupAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.paused.toString()) {
        await showInterstitialForTrigger(InterstitialTrigger.appExit);
      }
      return null;
    });
  }

  BannerAd? getBannerAd(AdScreen screen) {
    return _bannerAds[screen];
  }

  Future<void> loadBannerAd(AdScreen screen) async {
    final adUnitId = _bannerAdUnitIds[screen];
    if (adUnitId == null) return;

    _disposeBannerAd(screen);

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: _createAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAds[screen] = ad as BannerAd;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAds[screen] = null;
          notifyListeners();
        },
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
      ),
    );

    await bannerAd.load();
  }

  void _disposeBannerAd(AdScreen screen) {
    _bannerAds[screen]?.dispose();
    _bannerAds[screen] = null;
  }

  Future<void> preloadBannerAds(List<AdScreen> screens) async {
    for (final screen in screens) {
      await loadBannerAd(screen);
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: _createAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _lastInterstitialShow = DateTime.now();
              _actionsSinceLastAd = 0;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _loadInterstitialAd();
            },
            onAdShowedFullScreenContent: (ad) {
              _lastInterstitialShow = DateTime.now();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialReady = false;
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  bool _canShowInterstitial() {
    if (!_isInterstitialReady) return false;
    if (_lastInterstitialShow == null) return true;

    final timeSinceLastShow = DateTime.now().difference(_lastInterstitialShow!);
    return timeSinceLastShow.inMinutes >= _interstitialCooldownMinutes;
  }

  bool _shouldShowInterstitialForAction() {
    _actionsSinceLastAd++;
    return _actionsSinceLastAd >= _actionsBeforeAd;
  }

  Future<void> showInterstitialForTrigger(InterstitialTrigger trigger) async {
    if (!_canShowInterstitial()) return;

    bool shouldShow = false;

    switch (trigger) {
      case InterstitialTrigger.addHive:
      case InterstitialTrigger.addInspection:
      case InterstitialTrigger.addTreatment:
      case InterstitialTrigger.completeTask:
        shouldShow = _shouldShowInterstitialForAction();
        break;
      case InterstitialTrigger.appExit:
        shouldShow = true;
        break;
    }

    if (shouldShow) {
      await _interstitialAd?.show();
    }
  }

  Future<void> showInterstitialAd() async {
    if (!_canShowInterstitial()) return;
    await _interstitialAd?.show();
  }

  AdRequest _createAdRequest() {
    return const AdRequest(
      keywords: ['beekeeping', 'honey', 'agriculture', 'farming', 'nature'],
      contentUrl: 'https://hivelogbee.app',
      nonPersonalizedAds: false,
    );
  }

  void switchScreen(AdScreen newScreen, AdScreen? previousScreen) {
    if (previousScreen != null && previousScreen != newScreen) {
      _disposeBannerAd(previousScreen);
    }

    if (_bannerAds[newScreen] == null) {
      loadBannerAd(newScreen);
    }
  }

  void disposeAllBannerAds() {
    for (final screen in AdScreen.values) {
      _disposeBannerAd(screen);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    disposeAllBannerAds();
    _interstitialAd?.dispose();
    super.dispose();
  }
}

class DynamicBannerAdWidget extends StatefulWidget {
  // ... (Properties remain the same) ...
  final AdScreen screen;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const DynamicBannerAdWidget({
    super.key,
    required this.screen,
    this.margin,
    this.backgroundColor,
  });

  @override
  State<DynamicBannerAdWidget> createState() => _DynamicBannerAdWidgetState();
}

class _DynamicBannerAdWidgetState extends State<DynamicBannerAdWidget> {
  // ... (State remains the same) ...
  late final AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = AdService();
    _adService.addListener(_onAdServiceUpdate);
    _loadAdIfNeeded();
  }

  @override
  void dispose() {
    _adService.removeListener(_onAdServiceUpdate);
    super.dispose();
  }

  void _onAdServiceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _loadAdIfNeeded() {
    final bannerAd = _adService.getBannerAd(widget.screen);
    if (bannerAd == null) {
      _adService.loadBannerAd(widget.screen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _adService.getBannerAd(widget.screen);

    if (bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      ),
    );
  }
}

class AdAwareScaffold extends StatefulWidget {
  // ... (Properties remain the same) ...
  final AdScreen screen;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool showBannerAd;

  const AdAwareScaffold({
    super.key,
    required this.screen,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.showBannerAd = true,
  });

  @override
  State<AdAwareScaffold> createState() => _AdAwareScaffoldState();
}

class _AdAwareScaffoldState extends State<AdAwareScaffold> {
  late final AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = AdService();
    if (widget.showBannerAd) {
      _adService.loadBannerAd(widget.screen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // --- تم تعديل هذا الجزء ---
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          return;
        }
        await _adService.showInterstitialForTrigger(InterstitialTrigger.appExit);
      },
      // -------------------------
      child: Scaffold(
        appBar: widget.appBar,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        backgroundColor: widget.backgroundColor,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
        body: Column(
          children: [
            Expanded(child: widget.body),
            if (widget.showBannerAd)
              DynamicBannerAdWidget(
                screen: widget.screen,
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              ),
          ],
        ),
      ),
    );
  }
}

class AdManager {
  // ... (All methods remain the same) ...
  static final AdService _adService = AdService();

  static Future<void> initialize() async {
    await _adService.initialize();
  }

  static void preloadCommonAds() {
    _adService.preloadBannerAds([
      AdScreen.home,
      AdScreen.hiveList,
      AdScreen.hiveDetails,
      AdScreen.inspection,
    ]);
  }

  static void onScreenChange(AdScreen newScreen, AdScreen? previousScreen) {
    _adService.switchScreen(newScreen, previousScreen);
  }

  static Future<void> showInterstitialOnAction(InterstitialTrigger trigger) async {
    await _adService.showInterstitialForTrigger(trigger);
  }

  static Future<void> showInterstitialOnExit() async {
    await _adService.showInterstitialForTrigger(InterstitialTrigger.appExit);
  }

  static Widget createBannerAd(AdScreen screen, {EdgeInsets? margin}) {
    return DynamicBannerAdWidget(
      screen: screen,
      margin: margin,
    );
  }

  static bool canShowInterstitial() {
    return _adService._canShowInterstitial();
  }

  static Future<void> onHiveAdded() async {
    await _adService.showInterstitialForTrigger(InterstitialTrigger.addHive);
  }

  static Future<void> onInspectionAdded() async {
    await _adService.showInterstitialForTrigger(InterstitialTrigger.addInspection);
  }

  static Future<void> onTreatmentAdded() async {
    await _adService.showInterstitialForTrigger(InterstitialTrigger.addTreatment);
  }

  static Future<void> onTaskCompleted() async {
    await _adService.showInterstitialForTrigger(InterstitialTrigger.completeTask);
  }
}
