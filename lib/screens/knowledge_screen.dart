import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
// import '../utils/responsive_helper.dart'; // Commented out
import '../l10n/app_localizations.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key}); // Corrected to use super-parameters

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<KnowledgeItem> _knowledgeItems = [
    KnowledgeItem(
      id: '1',
      title: 'دورة حياة النحل',
      description: 'تعرف على مراحل نمو النحل من البيضة إلى النحلة البالغة',
      category: 'biology',
      type: 'article',
      content: '''
# دورة حياة النحل

## المراحل الأربع لنمو النحل:

### 1. البيضة (3 أيام)
- تضع الملكة البيضة في العين السداسية
- البيضة بيضاء صغيرة بحجم حبة الأرز
- تفقس بعد 3 أيام لتصبح يرقة

### 2. اليرقة (6 أيام للعاملة)
- تتغذى على الغذاء الملكي أول 3 أيام
- ثم تتغذى على العسل وحبوب اللقاح
- تنمو بسرعة وتغير جلدها عدة مرات

### 3. العذراء (12 يوم للعاملة)
- تغطى العين بطبقة شمعية
- تتحول اليرقة إلى نحلة كاملة
- تتكون الأجنحة والأرجل والأعضاء

### 4. النحلة البالغة
- تخرج من العين بعد 21 يوم إجمالي
- تبدأ بأعمال الخلية حسب عمرها
- تعيش 6 أسابيع في الصيف، أشهر في الشتاء

## الفروق في مدة النمو:
- **العاملة**: 21 يوم (3+6+12)
- **الذكر**: 24 يوم (3+7+14)  
- **الملكة**: 16 يوم (3+5+8)
''',
      imageUrl: 'assets/images/bee_lifecycle.png',
      readTime: 5,
    ),
    KnowledgeItem(
      id: '2',
      title: 'أمراض النحل الشائعة',
      description: 'دليل شامل لتشخيص وعلاج أمراض النحل',
      category: 'diseases',
      type: 'article',
      content: '''
# أمراض النحل الشائعة

## 1. الفاروا (Varroa Mites)

### الأعراض:
- نحل مشوه الأجنحة
- نحل ضعيف وصغير الحجم
- انتشار الفيروسات
- موت الحضنة

### العلاج:
- شرائح الأبيستان
- حمض الفورميك
- الثيمول الطبيعي
- العلاج الحراري

## 2. النوزيما (Nosema)

### الأعراض:
- إسهال النحل
- ضعف عام في الخلية
- موت النحل أمام الخلية
- رائحة كريهة

### العلاج:
- فوماجيلين
- تحسين التهوية
- تغيير الملكة
- تقوية التغذية

## 3. تعفن الحضنة الأمريكي

### الأعراض:
- حضنة ميتة لزجة
- رائحة كريهة مميزة
- عيون مثقوبة
- خيوط لزجة عند الفحص

### العلاج:
- حرق الخلية المصابة
- المضادات الحيوية (بحذر)
- تغيير الأقراص
- الحجر الصحي

## 4. تعفن الحضنة الأوروبي

### الأعراض:
- يرقات ميتة صفراء
- رائحة حامضة
- موت اليرقات قبل التغطية
- انتشار سريع

### العلاج:
- تقوية الخلية
- تحسين التغذية
- تغيير الملكة
- المضادات الحيوية

## الوقاية:
- فحص دوري منتظم
- نظافة الأدوات
- تقوية الخلايا
- التغذية المناسبة
- العزل عند الإصابة
''',
      imageUrl: 'assets/images/bee_diseases.png',
      readTime: 8,
    ),
    KnowledgeItem(
      id: '3',
      title: 'تربية الملكات',
      description: 'طرق تربية الملكات وإنتاج ملكات عالية الجودة',
      category: 'queens',
      type: 'video',
      content: '''
# تربية الملكات

## الطرق الطبيعية:

### 1. طريقة التقسيم
- اختيار خلية قوية (10+ إطارات)
- نقل إطارات بها بيض وحضنة صغيرة
- ترك الخلية بدون ملكة
- النحل ينتج خلايا ملكية طبيعية

### 2. طريقة الطوارئ
- إزالة الملكة من خلية قوية
- النحل ينتج خلايا ملكية طارئة
- اختيار أفضل الخلايا الملكية
- توزيعها على الطرود الجديدة

## الطرق الاصطناعية:

### 1. طريقة دوليتل
- تحضير كؤوس شمعية
- نقل يرقات عمر يوم واحد
- وضعها في خلية منتجة
- رعاية الخلايا الملكية

### 2. طريقة ميلر
- قطع مثلثات في الأقراص
- ترك النحل ينتج خلايا ملكية
- أسهل للمبتدئين
- نتائج جيدة

## شروط النجاح:
- خلية أم قوية وصحية
- توقيت مناسب (ربيع/صيف)
- تغذية جيدة
- طقس مناسب
- خبرة في التعامل

## علامات الملكة الجيدة:
- حجم كبير ومتناسق
- حركة نشطة
- بطن ممتلئ
- أجنحة سليمة
- قبول من النحل
''',
      imageUrl: 'assets/images/queen_rearing.png',
      readTime: 10,
    ),
    KnowledgeItem(
      id: '4',
      title: 'قطف العسل',
      description: 'أفضل الطرق لقطف العسل والحفاظ على جودته',
      category: 'harvesting',
      type: 'article',
      content: '''
# قطف العسل

## التوقيت المناسب:

### علامات نضج العسل:
- تغطية 80% من العيون بالشمع
- رطوبة أقل من 18.5%
- طعم ورائحة مميزة
- لزوجة مناسبة

### أفضل الأوقات:
- الصباح الباكر
- بعد انتهاء موسم الرحيق
- طقس جاف ومشمس
- قبل بداية الشتاء

## طرق القطف:

### 1. الطريقة التقليدية
- استخدام المدخن
- إزالة الإطارات يدوياً
- كشط الشمع بالسكين
- عصر الأقراص

### 2. الطريقة الحديثة
- استخدام طارد النحل
- فراز العسل الكهربائي
- فلترة وتنقية
- تعبئة مباشرة

## خطوات القطف:

### 1. التحضير
- تنظيف الأدوات
- تحضير المدخن
- لبس الملابس الواقية
- تحضير صناديق فارغة

### 2. إزالة الإطارات
- تدخين الخلية برفق
- فحص نضج العسل
- إزالة الإطارات الناضجة
- ترك إطارات للنحل

### 3. الاستخلاص
- كشط طبقة الشمع
- وضع الأقراص في الفراز
- تشغيل الفراز تدريجياً
- جمع العسل في خزان

### 4. التنقية
- تصفية العسل من الشوائب
- إزالة فقاعات الهواء
- فحص الرطوبة
- تعبئة في عبوات نظيفة

## نصائح مهمة:
- لا تقطف كل العسل
- اترك 15-20 كغ للشتاء
- تجنب القطف في الطقس السيء
- احرص على النظافة
- فحص الجودة قبل التعبئة
''',
      imageUrl: 'assets/images/honey_harvest.png',
      readTime: 7,
    ),
    KnowledgeItem(
      id: '5',
      title: 'تغذية النحل',
      description: 'أنواع التغذية ومتى وكيف تغذي النحل',
      category: 'feeding',
      type: 'article',
      content: '''
# تغذية النحل

## أنواع التغذية:

### 1. التغذية السكرية
**متى:** عند نقص الرحيق
**النسبة:** 1:1 (ربيع) أو 2:1 (شتاء)
**الكمية:** 1-2 لتر أسبوعياً

### 2. التغذية البروتينية
**متى:** عند نقص حبوب اللقاح
**المكونات:** دقيق الصويا، خميرة، عسل
**الطريقة:** عجينة أو كعك بروتيني

### 3. التغذية المائية
**متى:** في الطقس الجاف
**الطريقة:** مشارب قريبة من الخلايا
**النظافة:** تغيير الماء يومياً

## وصفات التغذية:

### محلول سكري 1:1
- 1 كغ سكر
- 1 لتر ماء
- تسخين حتى الذوبان
- تبريد قبل التقديم

### محلول سكري 2:1
- 2 كغ سكر  
- 1 لتر ماء
- للتغذية الشتوية
- أكثر تركيزاً

### عجينة بروتينية
- 500غ دقيق صويا
- 200غ خميرة غذائية
- 300غ عسل
- خلط جيد وتشكيل كرات

## طرق التقديم:

### 1. الغذايات العلوية
- توضع فوق الإطارات
- سهولة في التعبئة
- حماية من النحل الغريب

### 2. الغذايات الجانبية
- توضع بجانب الإطارات
- سعة أكبر
- تحتاج مراقبة أكثر

### 3. الغذايات الخارجية
- خارج الخلية
- للتغذية الجماعية
- خطر السرقة

## توقيت التغذية:

### الربيع (مارس-مايو)
- تحفيز وضع البيض
- محلول خفيف 1:1
- تغذية بروتينية

### الصيف (يونيو-أغسطس)
- عند الجفاف فقط
- تركيز على الماء
- تجنب التغذية السكرية

### الخريف (سبتمبر-نوفمبر)
- تحضير للشتاء
- محلول مركز 2:1
- تخزين للشتاء

### الشتاء (ديسمبر-فبراير)
- تغذية طوارئ فقط
- كعك سكري صلب
- تجنب المحاليل السائلة

## نصائح مهمة:
- تغذية مساءً لتجنب السرقة
- نظافة الغذايات
- مراقبة استهلاك الغذاء
- تجنب الإفراط في التغذية
- استخدام سكر أبيض نقي
''',
      imageUrl: 'assets/images/bee_feeding.png',
      readTime: 6,
    ),
  ];

  List<KnowledgeItem> get _filteredItems {
    var items = _knowledgeItems;

    if (_selectedCategory != 'all') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
      item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!; // Added null-check operator

    return Scaffold(
      appBar: CustomAppBar(title: localizations.knowledge),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildKnowledgeList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'البحث في المعرفة...',
          hintStyle: const TextStyle(fontSize: 10),
          prefixIcon: const Icon(Icons.search, size: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.amber[700]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('الكل', 'all', Icons.all_inclusive),
          _buildCategoryChip('علم الأحياء', 'biology', Icons.science),
          _buildCategoryChip('الأمراض', 'diseases', Icons.healing),
          _buildCategoryChip('الملكات', 'queens', Icons.star),
          // _buildCategoryChip('القطف', 'harvesting', Icons.honey_pot), // Commented out
          _buildCategoryChip('القطف', 'harvesting', Icons.opacity), // Replacement icon
          _buildCategoryChip('التغذية', 'feeding', Icons.restaurant),
          _buildCategoryChip('المعدات', 'equipment', Icons.build),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value, IconData icon) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: FilterChip(
        avatar: Icon(icon, size: 12, color: isSelected ? Colors.white : Colors.grey[600]),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = value);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.amber[700],
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildKnowledgeList() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildKnowledgeCard(item);
      },
    );
  }

  Widget _buildKnowledgeCard(KnowledgeItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () => _openKnowledgeDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildItemIcon(item.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(
                          '${item.readTime} دقائق',
                          style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                        ),
                        const Spacer(),
                        _buildCategoryBadge(item.category),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'video':
        icon = Icons.play_circle_filled;
        color = Colors.red;
        break;
      case 'audio':
        icon = Icons.audiotrack;
        color = Colors.green;
        break;
      default:
        icon = Icons.article;
        color = Colors.blue;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(25), // Adjusted for opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildCategoryBadge(String category) {
    final categoryNames = {
      'biology': 'أحياء',
      'diseases': 'أمراض',
      'queens': 'ملكات',
      'harvesting': 'قطف',
      'feeding': 'تغذية',
      'equipment': 'معدات',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        categoryNames[category] ?? category,
        style: TextStyle(
          fontSize: 7,
          color: Colors.amber[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _openKnowledgeDetail(KnowledgeItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KnowledgeDetailScreen(item: item),
      ),
    );
  }
}

class KnowledgeItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final String content;
  final String imageUrl;
  final int readTime;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.content,
    required this.imageUrl,
    required this.readTime,
  });
}

class KnowledgeDetailScreen extends StatelessWidget {
  final KnowledgeItem item;

  const KnowledgeDetailScreen({super.key, required this.item}); // Corrected to use super-parameters

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: item.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              item.type == 'video' ? Icons.play_circle_filled : Icons.article,
              color: Colors.amber[700],
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              item.type == 'video' ? 'فيديو' : 'مقال',
              style: TextStyle(fontSize: 8, color: Colors.amber[700]),
            ),
            const Spacer(),
            Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
            const SizedBox(width: 2),
            Text(
              '${item.readTime} دقائق',
              style: TextStyle(fontSize: 8, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          item.description,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        item.content,
        style: const TextStyle(fontSize: 10, height: 1.5),
      ),
    );
  }
}
