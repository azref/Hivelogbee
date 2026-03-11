import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();

  File? _selectedImage;
  ExperienceLevel _selectedExperienceLevel = ExperienceLevel.beginner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user; // Corrected from currentUserModel

    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phoneNumber ?? '';
      // Assuming location is part of UserModel, if not, this needs adjustment
      // _locationController.text = user.location ?? '';
      _experienceController.text = user.yearsOfExperience.toString();
      _selectedExperienceLevel = user.experienceLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdAwareScaffold(
      screen: AdScreen.profile,
      appBar: const CustomAppBar(
        title: 'الملف الشخصي',
        showBackButton: true,

      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user; // Corrected from currentUserModel

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileImageSection(user),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildExperienceSection(),
                const SizedBox(height: 24),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildStatisticsSection(user),
                const SizedBox(height: 32),
                _buildSaveButton(authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection(UserModel? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryYellow,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                        ? NetworkImage(user.photoURL!)
                        : null as ImageProvider?, // Corrected type
                    backgroundColor: AppTheme.primaryYellow.withAlpha(50), // Replacement for lightYellow
                    child: _selectedImage == null && (user?.photoURL == null || user!.photoURL!.isEmpty)
                        ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.darkBrown,
                    )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.darkBrown,
                        size: 20,
                      ),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'المستخدم',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBrown.withAlpha(153), // Adjusted for opacity
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'المعلومات الشخصية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.school,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'الخبرة في تربية النحل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExperienceLevel>(
              // initialValue: _selectedExperienceLevel, // Corrected from value
              initialValue: _selectedExperienceLevel,
              decoration: const InputDecoration(
                labelText: 'مستوى الخبرة',
                prefixIcon: Icon(Icons.trending_up),
              ),
              items: ExperienceLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(_getExperienceLevelText(level)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedExperienceLevel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'سنوات الخبرة',
                prefixIcon: Icon(Icons.calendar_today),
                suffixText: 'سنة',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final years = int.tryParse(value);
                  if (years == null || years < 0 || years > 100) {
                    return 'يرجى إدخال عدد صحيح من 0 إلى 100';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'الموقع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'المدينة أو المنطقة',
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('تحديد الموقع الحالي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'إحصائياتي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'الخلايا',
                    user.totalHives.toString(),
                    Icons.hive,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الطرود',
                    user.totalNuclei.toString(),
                    Icons.scatter_plot,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الإنتاج',
                    '${user.totalProduction.toStringAsFixed(1)} كغ',
                    Icons.opacity, // Replacement icon
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow.withAlpha(50), // Replacement for lightYellow
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryYellow.withAlpha(76), // Adjusted for opacity
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.darkBrown,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.darkBrown.withAlpha(153), // Adjusted for opacity
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _saveProfile(authProvider),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'حفظ التغييرات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getExperienceLevelText(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'مبتدئ';
      case ExperienceLevel.intermediate:
        return 'متوسط';
      case ExperienceLevel.advanced:
        return 'متقدم';
      case ExperienceLevel.expert:
        return 'خبير';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تحديد الموقع...'),
        backgroundColor: AppTheme.primaryYellow,
      ),
    );
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updates = <String, dynamic>{
        'displayName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        // 'location': _locationController.text.trim().isEmpty
        //     ? null
        //     : _locationController.text.trim(),
        'experienceLevel': _selectedExperienceLevel.name,
        'yearsOfExperience': int.tryParse(_experienceController.text) ?? 0,
      };

      if (_selectedImage != null) {
        // TODO: Upload image and get URL
        // updates['photoURL'] = uploadedImageUrl;
      }

      await authProvider.updateUserProfile(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
