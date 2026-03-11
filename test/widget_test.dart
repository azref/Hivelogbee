import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivelog_bee/main.dart';

void main() {
  // ملاحظة: الاختبارات لا تقوم بتحميل ملفات .env الحقيقية عادةً
  // لذا يفضل اختبار الـ Widgets داخل بيئة محددة

  testWidgets('تحقق من ظهور شاشة التحميل عند بدء التطبيق', (WidgetTester tester) async {
    // بناء التطبيق داخل بيئة الاختبار
    await tester.pumpWidget(const HiveLogBeeApp());

    // التحقق من وجود مؤشر التحميل (CircularProgressIndicator)
    // الذي وضعته في main.dart لحالة auth.isLoading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('التحقق من نصوص الواجهة الأساسية', (WidgetTester tester) async {
    await tester.pumpWidget(const HiveLogBeeApp());

    // الانتظار حتى تنتهي عمليات الـ Provider إذا لزم الأمر
    await tester.pump();

    // البحث عن اسم التطبيق الذي وضعته في MaterialApp
    expect(find.text('HiveLog Bee'), findsOneWidget);
  });
}