import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  static Future<WeatherData?> getCurrentWeather({
    double? latitude,
    double? longitude,
    String? cityName,
  }) async {
    try {
      String url;
      
      if (latitude != null && longitude != null) {
        url = '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=ar';
      } else if (cityName != null) {
        url = '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=ar';
      } else {
        final position = await _getCurrentPosition();
        if (position == null) return null;
        url = '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=ar';
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    
    return null;
  }

  static Future<List<WeatherForecast>?> getWeatherForecast({
    double? latitude,
    double? longitude,
    String? cityName,
    int days = 5,
  }) async {
    try {
      String url;
      
      if (latitude != null && longitude != null) {
        url = '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=ar';
      } else if (cityName != null) {
        url = '$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric&lang=ar';
      } else {
        final position = await _getCurrentPosition();
        if (position == null) return null;
        url = '$_baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=ar';
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        return forecastList
            .take(days * 8)
            .map((item) => WeatherForecast.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error fetching forecast: $e');
    }
    
    return null;
  }

  static Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<String?> getCityNameFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return placemark.locality ?? placemark.administrativeArea ?? placemark.country;
      }
    } catch (e) {
      print('Error getting city name: $e');
    }
    return null;
  }

  static BeekeepingAdvice getBeekeepingAdvice(WeatherData weather) {
    final temp = weather.temperature;
    final humidity = weather.humidity;
    final windSpeed = weather.windSpeed;
    final condition = weather.condition.toLowerCase();

    String advice = '';
    BeekeepingActivityLevel activityLevel = BeekeepingActivityLevel.moderate;
    List<String> recommendations = [];

    if (temp < 10) {
      advice = 'الطقس بارد جداً - تجنب فتح الخلايا';
      activityLevel = BeekeepingActivityLevel.low;
      recommendations.addAll([
        'تأكد من حماية الخلايا من البرد',
        'قلل من التدخل في الخلايا',
        'تحقق من مخازن الطعام',
      ]);
    } else if (temp >= 10 && temp <= 15) {
      advice = 'الطقس بارد - محدود النشاط';
      activityLevel = BeekeepingActivityLevel.low;
      recommendations.addAll([
        'فحص سريع فقط إذا ضروري',
        'تجنب الفحوصات الطويلة',
        'احرص على سرعة العمل',
      ]);
    } else if (temp > 15 && temp <= 25) {
      advice = 'الطقس مثالي للعمل مع النحل';
      activityLevel = BeekeepingActivityLevel.high;
      recommendations.addAll([
        'وقت ممتاز للفحوصات الشاملة',
        'يمكن إجراء التقسيمات',
        'مناسب لإدخال الملكات',
      ]);
    } else if (temp > 25 && temp <= 35) {
      advice = 'الطقس دافئ - مناسب للعمل';
      activityLevel = BeekeepingActivityLevel.moderate;
      recommendations.addAll([
        'اعمل في الصباح الباكر أو المساء',
        'تجنب ساعات الذروة الحارة',
        'تأكد من توفر الماء للنحل',
      ]);
    } else {
      advice = 'الطقس حار جداً - تجنب العمل';
      activityLevel = BeekeepingActivityLevel.low;
      recommendations.addAll([
        'تجنب فتح الخلايا في الحر',
        'تأكد من التهوية الجيدة',
        'وفر مصادر مياه إضافية',
      ]);
    }

    if (humidity > 80) {
      recommendations.add('الرطوبة عالية - راقب العفن والأمراض');
    } else if (humidity < 30) {
      recommendations.add('الرطوبة منخفضة - وفر مصادر مياه');
    }

    if (windSpeed > 20) {
      advice += ' - رياح قوية';
      activityLevel = BeekeepingActivityLevel.low;
      recommendations.add('تجنب العمل في الرياح القوية');
    }

    if (condition.contains('rain') || condition.contains('storm')) {
      advice = 'طقس ممطر - تجنب العمل مع النحل';
      activityLevel = BeekeepingActivityLevel.none;
      recommendations.clear();
      recommendations.addAll([
        'لا تفتح الخلايا في المطر',
        'تأكد من حماية الخلايا من المياه',
        'انتظر حتى يتحسن الطقس',
      ]);
    }

    return BeekeepingAdvice(
      advice: advice,
      activityLevel: activityLevel,
      recommendations: recommendations,
      isGoodForInspection: activityLevel == BeekeepingActivityLevel.high || 
                          activityLevel == BeekeepingActivityLevel.moderate,
      isGoodForHarvest: activityLevel == BeekeepingActivityLevel.high && 
                       humidity < 70 && 
                       !condition.contains('rain'),
    );
  }

  static String getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    
    if (conditionLower.contains('clear') || conditionLower.contains('sunny')) {
      return '☀️';
    } else if (conditionLower.contains('cloud')) {
      return '☁️';
    } else if (conditionLower.contains('rain')) {
      return '🌧️';
    } else if (conditionLower.contains('storm') || conditionLower.contains('thunder')) {
      return '⛈️';
    } else if (conditionLower.contains('snow')) {
      return '❄️';
    } else if (conditionLower.contains('fog') || conditionLower.contains('mist')) {
      return '🌫️';
    } else if (conditionLower.contains('wind')) {
      return '💨';
    }
    
    return '🌤️';
  }
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final int windDirection;
  final String condition;
  final String description;
  final String cityName;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.condition,
    required this.description,
    required this.cityName,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      pressure: (json['main']['pressure'] as num).toDouble(),
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind']?['deg'] as num?)?.toInt() ?? 0,
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      cityName: json['name'] as String,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'condition': condition,
      'description': description,
      'cityName': cityName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WeatherForecast {
  final DateTime dateTime;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final int humidity;
  final String condition;
  final String description;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.condition,
    required this.description,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      minTemperature: (json['main']['temp_min'] as num).toDouble(),
      maxTemperature: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
    );
  }
}

class BeekeepingAdvice {
  final String advice;
  final BeekeepingActivityLevel activityLevel;
  final List<String> recommendations;
  final bool isGoodForInspection;
  final bool isGoodForHarvest;

  BeekeepingAdvice({
    required this.advice,
    required this.activityLevel,
    required this.recommendations,
    required this.isGoodForInspection,
    required this.isGoodForHarvest,
  });
}

enum BeekeepingActivityLevel {
  none,
  low,
  moderate,
  high,
}
