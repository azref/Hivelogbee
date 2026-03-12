import 'package:flutter/material.dart';

/// SectionHolder: ويدجت عام وقابل لإعادة الاستخدام.
/// مهمته هي عرض مجموعة من الصفحات الفرعية (tabs) وإدارتها.
/// يتم التحكم فيه بالكامل من الخارج (من MainScreenHolder).

class SectionHolder extends StatefulWidget {
  /// المعرّف الفريد للتبويب الفرعي النشط حاليًا (e.g., 'all', 'active').
  final String activeSubSectionId;

  /// قائمة مرتبة بمعرّفات الصفحات. يجب أن يتطابق ترتيبها مع ترتيب الويدجتس في [pages].
  final List<String> pageOrder;

  /// قائمة الويدجتس (الشاشات) التي سيتم عرضها.
  final List<Widget> pages;

  const SectionHolder({
    super.key,
    required this.activeSubSectionId,
    required this.pageOrder,
    required this.pages,
  });

  @override
  State<SectionHolder> createState() => _SectionHolderState();
}

class _SectionHolderState extends State<SectionHolder> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }

  @override
  void didUpdateWidget(covariant SectionHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubSectionId != oldWidget.activeSubSectionId) {
      _animateToPage();
    }
  }

  void _initializePageController() {
    final initialPage = widget.pageOrder.indexOf(widget.activeSubSectionId);
    _pageController = PageController(
      initialPage: initialPage >= 0 ? initialPage : 0,
    );
  }

  void _animateToPage() {
    final newIndex = widget.pageOrder.indexOf(widget.activeSubSectionId);
    if (newIndex >= 0 && _pageController.hasClients) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.pages,
    );
  }
}