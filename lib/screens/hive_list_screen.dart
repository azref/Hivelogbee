import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../models/inspection_model.dart';
import '../providers/hive_provider.dart';
import '../providers/inspection_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';

class HiveListScreen extends StatefulWidget {
  final String filter;
  final Function(String id, String hiveNumber, bool isNucleus) onHiveTap;

  const HiveListScreen({
    super.key,
    required this.filter,
    required this.onHiveTap,
  });

  @override
  State<HiveListScreen> createState() => _HiveListScreenState();
}

class _HiveListScreenState extends State<HiveListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<HiveProvider>(context, listen: false).setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<HiveProvider, InspectionProvider>(
      builder: (context, hiveProvider, inspectionProvider, child) {
        final hives = hiveProvider.getFilteredHives(widget.filter);
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/honey_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              _buildSearchField(l10n, hiveProvider),
              Expanded(
                child: _buildHivesList(context, l10n, hiveProvider, inspectionProvider, hives),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, HiveProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withAlpha(100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '${l10n.search}...',
            prefixIcon: const Icon(Icons.search, color: AppTheme.darkBrown),
            suffixIcon: provider.searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () => _searchController.clear(),
            )
                : null,
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white.withAlpha(200),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildHivesList(BuildContext context, AppLocalizations l10n, HiveProvider hiveProvider, InspectionProvider inspectionProvider, List<HiveModel> hives) {
    if (hiveProvider.isLoading && hives.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
    }
    if (hives.isEmpty) {
      return _buildEmptyState(context, l10n);
    }
    return RefreshIndicator(
      onRefresh: () => hiveProvider.fetchHives(),
      color: AppTheme.primaryYellow,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hives.length,
        itemBuilder: (context, index) {
          final hive = hives[index];
          final hiveInspections = inspectionProvider.getInspectionsByHive(hive.id);
          final InspectionModel? latestInspection = hiveInspections.isNotEmpty ? hiveInspections.first : null;

          return _buildHiveCard(context, hive, latestInspection, l10n);
        },
      ),
    );
  }

  Widget _buildHiveCard(BuildContext context, HiveModel hive, InspectionModel? latestInspection, AppLocalizations l10n) {
    // --- 1. تعديل: استخدام دالة اللون الجديدة ---
    final statusColor = _getStatusColor(hive.type, hive.status, hive.nucleusStatus);

    final frameCount = latestInspection != null
        ? latestInspection.broodFrames +
        latestInspection.honeyFrames +
        latestInspection.pollenFrames +
        latestInspection.emptyFrames +
        latestInspection.foundationFrames +
        latestInspection.drawnFrames
        : hive.frameCount;

    final queenStatusText = latestInspection != null
        ? _getTranslatedQueenPresence(latestInspection.queenPresence, l10n)
        : hive.queenStatusDisplayName;

    final lastActivityDate = latestInspection?.date ?? hive.createdDate;

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withAlpha(128),
      color: Colors.white.withAlpha(230),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        // --- 2. تعديل: استخدام getter 'isNucleus' للتوافقية ---
        onTap: () => widget.onHiveTap(hive.id, hive.hiveNumber, hive.isNucleus),
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            // --- 3. تعديل: استخدام hive.type لتحديد الأيقونة ---
                            hive.type == HiveType.nucleus ? Icons.egg_outlined : Icons.hive_outlined,
                            color: AppTheme.darkBrown,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              // --- 4. تعديل: استخدام typeDisplayName ---
                              '${hive.typeDisplayName} رقم: ${hive.hiveNumber}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkBrown,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              // --- 5. تعديل: statusDisplayName أصبحت ذكية الآن ---
                              hive.statusDisplayName,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildInfoChip(
                              icon: Icons.layers,
                              text: '$frameCount إطارات',
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: _buildInfoChip(
                              icon: Icons.female,
                              text: queenStatusText,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildInfoChip(
                                icon: Icons.calendar_today_outlined,
                                text: '${lastActivityDate.day}/${lastActivityDate.month}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade500),
            const SizedBox(height: 24),
            Text(
              'لا توجد خلايا',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإضافة خليتك الأولى للبدء في تتبع منحلك',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. تعديل: دالة اللون لتكون أكثر شمولاً ---
  Color _getStatusColor(HiveType type, HiveStatus status, NucleusStatus? nucleusStatus) {
    if (type == HiveType.nucleus && nucleusStatus != null) {
      switch (nucleusStatus) {
        case NucleusStatus.mated:
        case NucleusStatus.laying:
          return AppTheme.successColor;
        case NucleusStatus.mating:
          return AppTheme.primaryYellow;
        case NucleusStatus.failed:
          return AppTheme.errorColor;
      }
    }
    switch (status) {
      case HiveStatus.active: return AppTheme.successColor;
      case HiveStatus.weak: return Colors.orange;
      case HiveStatus.sick:
      case HiveStatus.queenless: return AppTheme.errorColor;
      case HiveStatus.dead: return Colors.black54;
      default: return Colors.grey;
    }
  }

  String _getTranslatedQueenPresence(QueenPresence status, AppLocalizations l10n) {
    switch (status) {
      case QueenPresence.present: return "موجودة";
      case QueenPresence.absent: return "غائبة";
      case QueenPresence.newQueen: return "جديدة";
      case QueenPresence.unseen: return "لم تَرَ";
    }
  }
}
