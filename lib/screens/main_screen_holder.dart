import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/treatment_provider.dart';
import '../providers/hive_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/section_holder.dart';
import 'home_screen.dart';
import 'treatment_list_screen.dart';
import 'hive_list_screen.dart';
import 'add_hive_screen.dart'; // <-- 1. استيراد شاشة إضافة خلية

enum NavigationLevel { main, sub }

class MainScreenHolder extends StatefulWidget {
  const MainScreenHolder({super.key});
  @override
  State<MainScreenHolder> createState() => _MainScreenHolderState();
}

class _MainScreenHolderState extends State<MainScreenHolder> {
  NavigationLevel _level = NavigationLevel.main;
  String _activeMainSectionId = 'home';
  String _activeSubSectionId = 'all';

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
    'inspections': [
      NavItem(id: 'home', label: 'الرئيسية', icon: Icons.arrow_back_ios),
      NavItem(id: 'all', label: 'الكل', icon: Icons.list_alt),
      NavItem(id: 'this_week', label: 'هذا الأسبوع', icon: Icons.calendar_view_week),
      NavItem(id: 'this_month', label: 'هذا الشهر', icon: Icons.calendar_month),
    ],
    'treatments': [
      NavItem(id: 'home', label: 'الرئيسية', icon: Icons.arrow_back_ios),
      NavItem(id: 'all', label: 'الكل', icon: Icons.list_alt),
      NavItem(id: 'active', label: 'نشط', icon: Icons.autorenew),
      NavItem(id: 'completed', label: 'مكتمل', icon: Icons.check_circle_outline),
      NavItem(id: 'overdue', label: 'متأخر', icon: Icons.error_outline),
    ],
    'production': [
      NavItem(id: 'home', label: 'الرئيسية', icon: Icons.arrow_back_ios),
      NavItem(id: 'all', label: 'الكل', icon: Icons.list_alt),
      NavItem(id: 'honey', label: 'عسل', icon: Icons.opacity),
      NavItem(id: 'wax', label: 'شمع', icon: Icons.square_foot),
      NavItem(id: 'pollen', label: 'حبوب لقاح', icon: Icons.grain),
    ],
    'knowledge': [],
  };

  void _onMainTabTapped(String id) { setState(() { _activeMainSectionId = id; if (_subNavItems.containsKey(id) && _subNavItems[id]!.isNotEmpty) { _level = NavigationLevel.sub; _activeSubSectionId = 'all'; } else { _level = NavigationLevel.main; } }); }
  void _onSubTabTapped(String id) { if (id == 'home') { _navigateBackToMain(); return; } setState(() { _activeSubSectionId = id; }); }
  void _navigateBackToMain() { setState(() { _level = NavigationLevel.main; }); }

  PreferredSizeWidget _buildCurrentAppBar() {
    String title = _mainNavItems.firstWhere((item) => item.id == _activeMainSectionId, orElse: () => _mainNavItems.first).label;
    bool showBack = _level == NavigationLevel.sub;
    return CustomAppBar(title: title, showBackButton: showBack, onBackButtonPressed: _navigateBackToMain);
  }

  Widget _buildCurrentBody() {
    if (_level == NavigationLevel.main) {
      return const HomeScreen();
    }

    List<Widget> subScreens = [];
    List<String> subScreenOrder = [];

    final subNavs = _subNavItems[_activeMainSectionId]?.where((item) => item.id != 'home').toList() ?? [];

    for (var navItem in subNavs) {
      subScreenOrder.add(navItem.id);

      switch (_activeMainSectionId) {
        case 'treatments':
          subScreens.add(TreatmentListScreen(filter: navItem.id));
          break;
        case 'hives':
          subScreens.add(HiveListScreen(filter: navItem.id));
          break;
        default:
          subScreens.add(Center(child: Text('قسم قيد التطوير: ${navItem.label}')));
      }
    }

    if (subScreens.isEmpty) {
      return const Center(child: Text('هذا القسم قيد التطوير'));
    }

    return SectionHolder(
      activeSubSectionId: _activeSubSectionId,
      pageOrder: subScreenOrder,
      pages: subScreens,
    );
  }

  Widget _buildCurrentBottomNavBar() {
    if (_level == NavigationLevel.main) {
      return CustomBottomNavBar(items: _mainNavItems, activeItemId: _activeMainSectionId, onTabTapped: _onMainTabTapped);
    } else {
      final items = _subNavItems[_activeMainSectionId] ?? [];
      return CustomBottomNavBar(items: items, activeItemId: _activeSubSectionId, onTabTapped: _onSubTabTapped);
    }
  }

  // --- 2. دالة بناء زر الإضافة العائم ---
  Widget? _buildFloatingActionButton() {
    // يظهر الزر فقط إذا كنا في قسم الخلايا
    if (_activeMainSectionId == 'hives') {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHiveScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor, // استخدام لون الثيم
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      );
    }
    // يمكنك إضافة منطق للأقسام الأخرى هنا لاحقًا
    // if (_activeMainSectionId == 'treatments') { ... }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCurrentAppBar(),
      body: _buildCurrentBody(),
      bottomNavigationBar: _buildCurrentBottomNavBar(),
      // --- 3. إضافة الزر إلى Scaffold ---
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
