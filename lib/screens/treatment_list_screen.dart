import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/treatment_provider.dart';
import '../providers/auth_provider.dart'; // <-- 1. استيراد AuthProvider
import '../models/treatment_model.dart';
import '../utils/app_theme.dart';

import 'add_treatment_screen.dart';

class TreatmentListScreen extends StatelessWidget {
  final String filter;

  const TreatmentListScreen({
    super.key,
    required this.filter,
  });

  // --- دالة مساعدة لتجنب تكرار الكود ---
  void _fetchData(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      Provider.of<TreatmentProvider>(context, listen: false).fetchTreatments(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TreatmentProvider>(
      builder: (context, provider, child) {
        final treatments = provider.getFilteredTreatments(filter);

        if (provider.isLoading && treatments.isEmpty) {
          return _buildLoadingState();
        }

        if (treatments.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildTreatmentsList(context, treatments);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryYellow),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'لا توجد علاجات تطابق هذا الفلتر',
            style: AppTheme.bodyText.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _addNewTreatment(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة علاج جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: AppTheme.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsList(BuildContext context, List<TreatmentModel> treatments) {
    return RefreshIndicator(
      // --- 2. تصحيح الاستدعاء الأول (في السطر 77 تقريبًا) ---
      onRefresh: () async => _fetchData(context),
      color: AppTheme.primaryYellow,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: treatments.length,
        itemBuilder: (context, index) {
          final treatment = treatments[index];
          return _buildTreatmentCard(context, treatment);
        },
      ),
    );
  }

  Widget _buildTreatmentCard(BuildContext context, TreatmentModel treatment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(treatment.treatmentName, style: AppTheme.titleText),
            const SizedBox(height: 8),
            Text('خلية رقم: ${treatment.hiveId}', style: AppTheme.smallText.copyWith(color: Colors.grey.shade600)),
            const Divider(height: 24),
            Text('الحالة: ${treatment.status.name}'),
          ],
        ),
      ),
    );
  }

  void _addNewTreatment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTreatmentScreen()),
    );
    if (result == true) {
      // --- 3. تصحيح الاستدعاء الثاني (في السطر 122 تقريبًا) ---
      _fetchData(context);
    }
  }
}
