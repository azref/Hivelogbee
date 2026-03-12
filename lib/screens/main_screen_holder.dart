import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/auth_provider.dart';
import '../providers/treatment_provider.dart';
import '../providers/hive_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/section_holder.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'treatment_list_screen.dart';
import 'hive_list_screen.dart';
import 'add_hive_screen.dart';
import 'hive_details_screen.dart';

@immutable
class NavigationState {
  final String sectionId;
  final String? subSectionId;
  final String? detailItemId;
  final String? detailTitle;

  const NavigationState({
    required this.sectionId,
    this.subSectionId,
    this.detailItemId,
    this.detailTitle,
  });

  NavigationState copyWith({
    String? sectionId,
    String? subSectionId,
    String? detailItemId,
    String? detailTitle,
  }) {
    return NavigationState(
      sectionId: sectionId ?? this.sectionId,
      subSectionId: subSectionId ?? this.subSectionId,
      detailItemId: detailItemId ?? this.detailItemId,
      detailTitle: detailTitle ?? this.detailTitle,
    );
  }
}

class MainScreenHolder extends StatefulWidget {
  const MainScreenHolder({super.key});
  @override
  State<MainScreenHolder> createState() => _MainScreenHolderState();
}

class _MainScreenHolderState extends State<MainScreenHolder> {
  List<NavigationState> _navigationStack = [const NavigationState(sectionId: 'home')];
  NavigationState get _currentState => _navigationStack.last;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId != null) {
        Provider.of<HiveProvider>(context, listen: false).initialize(userId);
        Provider.of<TreatmentProvider>(context, listen: false).fetchTreatments(userId);
      }
    });
  }

  final List<NavItem> _mainNavItems = [
    NavItem(id: 'home', label: 'الرئيسية', icon: Icons.home_outlined, activeIcon: Icons.home),
    NavItem(id: 'hives', label: 'الخلايا', icon: Icons.hive_outlined, activeIcon: Icons.hive),
    NavItem(id: 'inspections', label: 'الفحوصات', icon: Icons.search_outlined, activeIcon: Icons.search),
    NavItem(id: 'treatments', label: 'العلاجات', icon: Icons.medical_services_outlined, activeIcon: Icons.medical_services),
    NavItem(id: 'production', label: 'الإنتاج', icon: Icons.opacity_outlined, activeIcon: Icons.opacity),
    NavItem(id: 'knowledge', label: 'المعرفة', icon: Icons.school_outlined, activeIcon: Icons.school),
  ];

  Map<String, List<NavItem>> get _subNavItems => {
    'hives': [
      NavItem(id: 'home', label: 'الرئيسية', icon: Icons.arrow_back_ios),
      NavItem(id: 'all', label: 'الكل', icon: Icons.list),
      NavItem(id: 'active', label: 'نشطة', icon: Icons.check_circle_outline),
      NavItem(id: 'nuclei', label: 'طرود', icon: Icons.baby_changing_station),
      NavItem(id: 'issues', label: 'مشاكل', icon: Icons.warning_amber_outlined),
    ],
    'hive_details': [
      NavItem(id: 'overview', label: 'نظرة عامة', icon: Icons.info_outline),
      NavItem(id: 'inspections', label: 'الفحوصات', icon: Icons.search),
      NavItem(id: 'treatments', label: 'العلاجات', icon: Icons.medical_services),
      NavItem(id: 'production', label: 'الإنتاج', icon: Icons.opacity),
    ],
  };

  void _navigateTo(NavigationState newState) {
    setState(() {
      _navigationStack.add(newState);
    });
  }

  void _navigateBack() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
      });
    }
  }

  void _onMainTabTapped(String id) {
    setState(() {
      _navigationStack = [
        NavigationState(
          sectionId: id,
          subSectionId: (_subNavItems[id]?.isNotEmpty ?? false) ? 'all' : null,
        )
      ];
    });
  }

  void _onSubTabTapped(String id) {
    if (id == 'home') {
      _onMainTabTapped(_currentState.sectionId);
      return;
    }
    setState(() {
      _navigationStack.last = _currentState.copyWith(subSectionId: id);
    });
  }

  void _handleHiveAction(String action, HiveModel hive) {
    print("Action: $action on Hive: ${hive.hiveNumber}");
  }

  List<Widget>? _buildHiveDetailsActions() {
    if (_currentState.detailItemId == null) return null;

    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    try {
      final hive = hiveProvider.hives.firstWhere((h) => h.id == _currentState.detailItemId);

      return [
        PopupMenuButton<String>(
          onSelected: (action) => _handleHiveAction(action, hive),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'inspect',
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20),
                  const SizedBox(width: 8),
                  const Text('إضافة فحص'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'treat',
              child: Row(
                children: [
                  const Icon(Icons.medical_services, size: 20),
                  const SizedBox(width: 8),
                  const Text('إضافة علاج'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'split',
              child: const Row(
                children: [
                  Icon(Icons.call_split, size: 20),
                  SizedBox(width: 8),
                  Text('تقسيم الخلية'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  const Text('تعديل'),
                ],
              ),
            ),
          ],
        ),
      ];
    } catch (e) {
      return null;
    }
  }

  PreferredSizeWidget _buildCurrentAppBar() {
    String title;
    bool showBack = _navigationStack.length > 1;

    if (_currentState.detailItemId != null) {
      title = _currentState.detailTitle ?? 'تفاصيل الخلية';
    } else {
      title = _mainNavItems.firstWhere(
              (item) => item.id == _currentState.sectionId,
          orElse: () => _mainNavItems.first
      ).label;
    }

    List<Widget>? additionalActions;
    if (_currentState.detailItemId != null) {
      additionalActions = _buildHiveDetailsActions();
    }

    return CustomAppBar(
      title: title,
      showBackButton: showBack,
      onBackButtonPressed: _navigateBack,
      additionalActions: additionalActions,
      centerTitle: true,
    );
  }

  Widget _buildCurrentBody() {
    if (_currentState.detailItemId != null) {
      switch (_currentState.sectionId) {
        case 'hives':
          return HiveDetailsScreen(
            hiveId: _currentState.detailItemId!,
            activeTabId: _currentState.subSectionId ?? 'overview',
            onActionSelected: _handleHiveAction,
          );
      }
    }

    if (_currentState.subSectionId != null) {
      List<Widget> subScreens = [];
      List<String> subScreenOrder = [];
      final subNavs = _subNavItems[_currentState.sectionId]?.where((item) => item.id != 'home').toList() ?? [];

      for (var navItem in subNavs) {
        subScreenOrder.add(navItem.id);
        switch (_currentState.sectionId) {
          case 'hives':
            subScreens.add(HiveListScreen(
              filter: navItem.id,
              onHiveTap: (hiveId, hiveNumber, isNucleus) {
                _navigateTo(NavigationState(
                  sectionId: 'hives',
                  subSectionId: 'overview',
                  detailItemId: hiveId,
                  detailTitle: '${isNucleus ? 'طرد' : 'خلية'} $hiveNumber',
                ));
              },
            ));
            break;
          case 'treatments':
            subScreens.add(TreatmentListScreen(filter: navItem.id));
            break;
          default:
            subScreens.add(Center(child: Text('قسم قيد التطوير: ${navItem.label}')));
        }
      }
      return SectionHolder(
        activeSubSectionId: _currentState.subSectionId!,
        pageOrder: subScreenOrder,
        pages: subScreens,
      );
    }

    return const HomeScreen();
  }

  Widget _buildCurrentBottomNavBar() {
    if (_currentState.detailItemId != null) {
      final items = _subNavItems['hive_details'] ?? [];
      return CustomBottomNavBar(
        items: items,
        activeItemId: _currentState.subSectionId ?? 'overview',
        onTabTapped: (id) {
          setState(() {
            _navigationStack.last = _currentState.copyWith(subSectionId: id);
          });
        },
      );
    }

    if (_currentState.subSectionId != null) {
      final items = _subNavItems[_currentState.sectionId] ?? [];
      return CustomBottomNavBar(
        items: items,
        activeItemId: _currentState.subSectionId!,
        onTabTapped: _onSubTabTapped,
      );
    }

    return CustomBottomNavBar(
      items: _mainNavItems,
      activeItemId: _currentState.sectionId,
      onTabTapped: _onMainTabTapped,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentState.sectionId == 'hives' && _currentState.detailItemId == null) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddHiveScreen())),
        backgroundColor: AppTheme.primaryYellow,
        child: const Icon(Icons.add, color: AppTheme.darkBrown),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCurrentAppBar(),
      body: _buildCurrentBody(),
      bottomNavigationBar: _buildCurrentBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}