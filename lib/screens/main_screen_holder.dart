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
// --- 1. استيراد الشاشات الصحيحة ---
import 'inspection_list_screen.dart';
import 'treatment_list_screen.dart';
import 'hive_list_screen.dart';
import 'add_hive_screen.dart';
import 'hive_details_screen.dart';
import 'add_inspection_screen.dart';
import 'add_treatment_screen.dart';
import 'add_division_screen.dart';


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

  DateTime? _lastPressed;

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
      _onMainTabTapped('home');
      return;
    }
    setState(() {
      _navigationStack.last = _currentState.copyWith(subSectionId: id);
    });
  }

  void _handleHiveAction(String action, HiveModel hive) {
    Future<void> navigateAndRefresh(Widget screen) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
      if (result == true && mounted) {
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          Provider.of<HiveProvider>(context, listen: false).fetchHives();
        }
      }
    }

    switch (action) {
      case 'inspect':
        navigateAndRefresh(AddInspectionScreen(hiveId: hive.id));
        break;
      case 'treat':
        navigateAndRefresh(AddTreatmentScreen(treatmentId: hive.id));
        break;
      case 'split':
        navigateAndRefresh(AddDivisionScreen(divisionId: hive.id));
        break;
      case 'edit':
      // navigateAndRefresh(AddHiveScreen(hiveId: hive.id));
        break;
      default:
        print("Action: $action on Hive: ${hive.hiveNumber}");
    }
  }

  void _showActionsDialog(BuildContext context, HiveModel hive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text('إجراءات الخلية', style: const TextStyle(color: AppTheme.darkBrown, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogActionItem(
              context: context,
              icon: Icons.search,
              text: 'إضافة فحص',
              onTap: () {
                Navigator.pop(context);
                _handleHiveAction('inspect', hive);
              },
            ),
            _buildDialogActionItem(
              context: context,
              icon: Icons.medical_services,
              text: 'إضافة علاج',
              onTap: () {
                Navigator.pop(context);
                _handleHiveAction('treat', hive);
              },
            ),
            _buildDialogActionItem(
              context: context,
              icon: Icons.call_split,
              text: 'تقسيم الخلية',
              onTap: () {
                Navigator.pop(context);
                _handleHiveAction('split', hive);
              },
            ),
            _buildDialogActionItem(
              context: context,
              icon: Icons.edit,
              text: 'تعديل',
              onTap: () {
                Navigator.pop(context);
                _handleHiveAction('edit', hive);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogActionItem({required BuildContext context, required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.darkBrown),
      title: Text(
        text,
        style: const TextStyle(color: AppTheme.darkBrown, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  PreferredSizeWidget _buildCurrentAppBar() {
    String title;
    bool showBack = _navigationStack.length > 1;

    if (_currentState.detailItemId != null) {
      final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
      try {
        final hive = hiveProvider.hives.firstWhere((h) => h.id == _currentState.detailItemId);
        title = '${hive.isNucleus ? 'طرد' : 'خلية'} ${hive.hiveNumber}';
      } catch (e) {
        title = 'تفاصيل الخلية';
      }
    } else {
      title = _mainNavItems.firstWhere(
              (item) => item.id == _currentState.sectionId,
          orElse: () => _mainNavItems.first
      ).label;
    }

    List<Widget>? additionalActions;
    if (_currentState.detailItemId != null) {
      final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
      final hive = hiveProvider.hives.firstWhere((h) => h.id == _currentState.detailItemId);
      additionalActions = [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showActionsDialog(context, hive),
        ),
      ];
    }

    return CustomAppBar(
      title: title,
      showBackButton: showBack,
      onBackButtonPressed: _navigateBack,
      additionalActions: additionalActions,
      centerTitle: true,
    );
  }

  // --- *** هذا هو الجزء الذي تم تعديله *** ---
  Widget _buildCurrentBody() {
    // الحالة 1: عرض تفاصيل عنصر (مثل خلية)
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

    // الحالة 2: عرض قسم رئيسي مع تبويبات فرعية (مثل قسم الخلايا أو الفحوصات)
    if (_currentState.sectionId != 'home' && _currentState.sectionId != 'knowledge') {
      switch (_currentState.sectionId) {
        case 'hives':
          return HiveListScreen(filter: _currentState.subSectionId ?? 'all', onHiveTap: (hiveId, hiveNumber, isNucleus) {
            _navigateTo(NavigationState(
              sectionId: 'hives',
              subSectionId: 'overview',
              detailItemId: hiveId,
              detailTitle: '${isNucleus ? 'طرد' : 'خلية'} $hiveNumber',
            ));
          });
      // 2. إضافة حالة الفحوصات
        case 'inspections':
          return const InspectionListScreen(); // لا تحتاج فلتر لأنها الشاشة العامة
        case 'treatments':
          return TreatmentListScreen(filter: _currentState.subSectionId ?? 'all');
        default:
          return Center(child: Text('قسم قيد التطوير: ${_currentState.sectionId}'));
      }
    }

    // الحالة 3: عرض الشاشة الرئيسية أو شاشة المعرفة (لا تحتوي على تبويبات فرعية)
    switch (_currentState.sectionId) {
      case 'knowledge':
      // return const KnowledgeScreen(); // افترض أن لديك شاشة المعرفة
        return const Center(child: Text('شاشة المعرفة'));
      default: // 'home'
        return const HomeScreen();
    }
  }
  // --- *** نهاية الجزء المعدل *** ---

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

    // لا نعرض شريط التبويبات الفرعية للأقسام التي لا تحتوي عليها
    if (_currentState.sectionId == 'hives' || _currentState.sectionId == 'treatments') {
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHiveScreen()),
          );

          if (result == true && mounted) {
            final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
            if (userId != null) {
              Provider.of<HiveProvider>(context, listen: false).fetchHives();
            }
          }
        },
        backgroundColor: AppTheme.primaryYellow,
        child: const Icon(Icons.add, color: AppTheme.darkBrown),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentState.sectionId == 'home' && _navigationStack.length == 1) {
          if (_lastPressed == null ||
              DateTime.now().difference(_lastPressed!) > const Duration(seconds: 2)) {
            _lastPressed = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اضغط مرتين للخروج'),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.primaryYellow,
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        } else {
          _navigateBack();
        }
      },
      child: Scaffold(
        appBar: _buildCurrentAppBar(),
        body: _buildCurrentBody(),
        bottomNavigationBar: _buildCurrentBottomNavBar(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }
}
