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
    // عند إنشاء الويدجت لأول مرة، قم بتهيئته ليبدأ من الصفحة الصحيحة.
    _initializePageController();
  }

  @override
  void didUpdateWidget(covariant SectionHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // هذه الدالة مهمة جدًا:
    // عندما يقوم المستخدم بالضغط على تبويب فرعي جديد في الشريط السفلي،
    // سيتغير `activeSubSectionId` القادم من `MainScreenHolder`.
    // هذا الشرط يكتشف التغيير ويأمر `PageController` بالانتقال إلى الصفحة الجديدة.
    if (widget.activeSubSectionId != oldWidget.activeSubSectionId) {
      _animateToPage();
    }
  }

  void _initializePageController() {
    final initialPage = widget.pageOrder.indexOf(widget.activeSubSectionId);
    _pageController = PageController(
      // تأكد من أن الفهرس صالح قبل استخدامه
      initialPage: initialPage >= 0 ? initialPage : 0,
    );
  }

  void _animateToPage() {
    final newIndex = widget.pageOrder.indexOf(widget.activeSubSectionId);
    if (newIndex >= 0 && _pageController.hasClients) {
      // الانتقال إلى الصفحة الجديدة مع تأثير حركة ناعم.
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
    // PageView هو قلب هذا الويدجت.
    return PageView(
      controller: _pageController,
      // نمنع المستخدم من التمرير بين الصفحات بإصبعه.
      // التحكم يتم فقط عبر شريط التنقل السفلي لضمان التناسق.
      physics: const NeverScrollableScrollPhysics(),
      children: widget.pages,
    );
  }
}
