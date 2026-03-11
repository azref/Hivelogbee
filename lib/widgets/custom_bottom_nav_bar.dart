import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
// نموذج بسيط لتمثيل كل عنصر في شريط التنقل
class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final String activeItemId;
  final List<NavItem> items;
  final ValueChanged<String> onTabTapped;

  const CustomBottomNavBar({
    super.key,
    required this.activeItemId,
    required this.items,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    // --- استخدام ألوان ثابتة ومحايدة مؤقتًا ---
    const Color bottomNavBarColor = AppTheme.primaryYellow; // <-- 2. استخدام اللون الأصفر
    const Color activeColor = AppTheme.darkBrown;         // <-- 3. استخدام البني الداكن للنص النشط
    final Color inactiveColor = AppTheme.darkBrown.withOpacity(0.6); // <-- 4. استخدام البني الداكن الشفاف للنص غير النشط
    // --------------------------------
    return Container(
      decoration: BoxDecoration(
        color: bottomNavBarColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = item.id == activeItemId;

              final Color currentColor = isSelected ? activeColor : inactiveColor;
              final double iconSize = isSelected ? 26.0 : 24.0;

              return InkWell(
                onTap: () => onTabTapped(item.id),
                highlightColor: Colors.transparent,
                splashColor: activeColor.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                        color: currentColor,
                        size: iconSize,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: currentColor,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
