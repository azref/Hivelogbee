// تم حذف 'package:cloud_firestore/cloud_firestore.dart'

enum ProductType {
  honey,
  wax,
  propolis,
  pollen,
  royalJelly,
  other,
}

enum ProductQuality {
  excellent,
  good,
  fair,
  poor,
}

enum HarvestSeason {
  spring,
  summer,
  autumn,
  winter,
}

class ProductionModel {
  final String id;
  final String userId;
  final String hiveId;
  final DateTime date;
  final ProductType productType;
  final double quantity;
  final String unit; // e.g., 'kg', 'g', 'litre'
  final ProductQuality quality;
  final HarvestSeason season;
  final bool isSold;
  final double? price;
  final String? buyer;
  final String? notes;
  final Map<String, dynamic>? customFields;

  ProductionModel({
    required this.id,
    required this.userId,
    required this.hiveId,
    required this.date,
    required this.productType,
    required this.quantity,
    this.unit = 'kg',
    required this.quality,
    required this.season,
    this.isSold = false,
    this.price,
    this.buyer,
    this.notes,
    this.customFields,
  });

  // تحويل النموذج إلى Map للتوافق مع Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'hive_id': hiveId,
      'date': date.toIso8601String(),
      'product_type': productType.name,
      'quantity': quantity,
      'unit': unit,
      'quality': quality.name,
      'season': season.name,
      'is_sold': isSold,
      'price': price,
      'buyer': buyer,
      'notes': notes,
      'custom_fields': customFields,
    };
  }

  // إنشاء نموذج من Map قادم من Supabase
  factory ProductionModel.fromMap(Map<String, dynamic> map) {
    return ProductionModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      hiveId: map['hive_id'] ?? '',
      date: DateTime.parse(map['date']),
      productType: ProductType.values.firstWhere(
            (e) => e.name == map['product_type'],
        orElse: () => ProductType.other,
      ),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'kg',
      quality: ProductQuality.values.firstWhere(
            (e) => e.name == map['quality'],
        orElse: () => ProductQuality.good,
      ),
      season: HarvestSeason.values.firstWhere(
            (e) => e.name == map['season'],
        orElse: () => HarvestSeason.summer,
      ),
      isSold: map['is_sold'] ?? false,
      price: (map['price'])?.toDouble(),
      buyer: map['buyer'],
      notes: map['notes'],
      customFields: map['custom_fields'] != null ? Map<String, dynamic>.from(map['custom_fields']) : null,
    );
  }

  // دالة بديلة، للتوافق مع الاصطلاح الجديد
  factory ProductionModel.fromSupabase(Map<String, dynamic> data) {
    return ProductionModel.fromMap(data);
  }

  ProductionModel copyWith({
    String? id,
    String? userId,
    String? hiveId,
    DateTime? date,
    ProductType? productType,
    double? quantity,
    String? unit,
    ProductQuality? quality,
    HarvestSeason? season,
    bool? isSold,
    double? price,
    String? buyer,
    String? notes,
    Map<String, dynamic>? customFields,
  }) {
    return ProductionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hiveId: hiveId ?? this.hiveId,
      date: date ?? this.date,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      quality: quality ?? this.quality,
      season: season ?? this.season,
      isSold: isSold ?? this.isSold,
      price: price ?? this.price,
      buyer: buyer ?? this.buyer,
      notes: notes ?? this.notes,
      customFields: customFields ?? this.customFields,
    );
  }
}
