
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hive_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'hive_details_screen.dart';

class HiveListScreen extends StatefulWidget {
  final String filter;
  const HiveListScreen({super.key, required this.filter});

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
    return Consumer<HiveProvider>(
      builder: (context, provider, child) {
        final hives = provider.getFilteredHives(widget.filter);
        return Container(
          decoration: AppTheme.gradientDecoration,
          child: Column(
            children: [
              _buildSearchField(l10n, provider),
              Expanded(
                child: _buildHivesList(context, l10n, provider, hives),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '${l10n.search}...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHivesList(BuildContext context, AppLocalizations l10n, HiveProvider provider, List<HiveModel> hives) {
    if (provider.isLoading && hives.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
    }
    if (hives.isEmpty) {
      return _buildEmptyState(context, l10n);
    }
    return RefreshIndicator(
      onRefresh: () => provider.fetchHives(),
      color: AppTheme.primaryYellow,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hives.length,
        itemBuilder: (context, index) {
          final hive = hives[index];
          return _buildHiveCard(context, hive, l10n);
        },
      ),
    );
  }

  Widget _buildHiveCard(BuildContext context, HiveModel hive, AppLocalizations l10n) {
    // هذا الكود صحيح ولا يحتاج تعديل
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToHiveDetails(context, hive),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('خلية رقم: ${hive.hiveNumber}'), // مثال بسيط
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    // هذا الكود صحيح ولا يحتاج تعديل
    return Center(child: Text('لا توجد خلايا'));
  }

  void _navigateToHiveDetails(BuildContext context, HiveModel hive) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HiveDetailsScreen(hiveId: hive.id)));
  }
}
