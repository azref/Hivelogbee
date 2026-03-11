import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdAwareScaffold(
      screen: AdScreen.settings,
      appBar: const CustomAppBar(
        title: 'حول التطبيق',
        showBackButton: true,
        // تم إزالة showShareButton و showSettingsButton
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfoCard(),
          const SizedBox(height: 16),
          _buildFeaturesCard(),
          const SizedBox(height: 16),
          _buildDeveloperCard(),
          const SizedBox(height: 16),
          _buildVersionCard(),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.hive,
                size: 50,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'HiveLog Bee',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تطبيق شامل لإدارة المناحل وتربية النحل',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBrown.withAlpha(178),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryYellow.withAlpha(76),
                ),
              ),
              child: const Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'مميزات التطبيق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.hive,
              'إدارة شاملة للخلايا',
              'تتبع حالة كل خلية وطرد بالتفصيل',
            ),
            _buildFeatureItem(
              Icons.assignment,
              'سجل الفحوصات',
              'تسجيل نتائج الفحوصات والملاحظات',
            ),
            _buildFeatureItem(
              Icons.medical_services,
              'إدارة العلاجات',
              'متابعة العلاجات والأدوية المستخدمة',
            ),
            _buildFeatureItem(
              Icons.production_quantity_limits,
              'تتبع الإنتاج',
              'حساب كميات العسل والأرباح',
            ),
            _buildFeatureItem(
              Icons.notifications_active,
              'تذكيرات ذكية',
              'تنبيهات تلقائية للمهام المهمة',
            ),
            _buildFeatureItem(
              Icons.map,
              'ربط بالموقع والطقس',
              'معلومات الطقس حسب موقع المنحل',
            ),
            _buildFeatureItem(
              Icons.library_books,
              'مكتبة المعرفة',
              'دليل شامل لتربية النحل',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.darkBrown,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.darkBrown.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'فريق التطوير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'تم تطوير هذا التطبيق بعناية فائقة لخدمة مجتمع النحالين العرب. نحن ملتزمون بتقديم أفضل الأدوات والتقنيات لمساعدة النحالين في إدارة مناحلهم بكفاءة عالية.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.email,
                  color: AppTheme.darkBrown.withAlpha(153),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'support@hivelogbee.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'معلومات الإصدار',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('رقم الإصدار', '1.0.0'),
            _buildInfoRow('تاريخ الإصدار', '2024/11/14'),
            _buildInfoRow('حجم التطبيق', '25.4 MB'),
            _buildInfoRow('الحد الأدنى لنظام Android', '6.0'),
            _buildInfoRow('آخر تحديث', '2024/11/14'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkBrown.withAlpha(153),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}