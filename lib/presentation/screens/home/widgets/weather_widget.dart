// lib/presentation/screens/home/widgets/weather_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadWeatherData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _loadWeatherData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // يمكن استبدال هذا بـ Provider.of<WeatherProvider>(context, listen: false).loadWeather();
      // إذا كان لديك WeatherProvider
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: _buildWeatherCard(),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    // يمكنك استبدال هذه البيانات الثابتة ببيانات من WeatherProvider
    final weatherData = _getMockWeatherData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(weatherData['condition']),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColor(weatherData['condition']).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeatherHeader(weatherData),
          const SizedBox(height: 16),
          _buildWeatherDetails(weatherData),
          const SizedBox(height: 16),
          _buildWeatherRecommendation(weatherData),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(Map<String, dynamic> weatherData) {
    return Row(
      children: [
        _buildWeatherIcon(weatherData['condition']),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الطقس الآن',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${weatherData['temperature']}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    weatherData['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildLocationBadge(),
      ],
    );
  }

  Widget _buildWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (condition.toLowerCase()) {
      case 'sunny':
        iconData = PhosphorIcons.sun;
        iconColor = Colors.orange.shade300;
        break;
      case 'cloudy':
        iconData = PhosphorIcons.cloud;
        break;
      case 'rainy':
        iconData = PhosphorIcons.cloud_rain;
        iconColor = Colors.blue.shade200;
        break;
      case 'windy':
        iconData = PhosphorIcons.wind;
        break;
      default:
        iconData = PhosphorIcons.sun;
        iconColor = Colors.orange.shade300;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32,
      ),
    );
  }

  Widget _buildLocationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.map_pin,
            color: Colors.white.withOpacity(0.9),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'رام الله',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(Map<String, dynamic> weatherData) {
    return Row(
      children: [
        Expanded(
          child: _buildWeatherDetailItem(
            PhosphorIcons.drop,
            'الرطوبة',
            '${weatherData['humidity']}%',
          ),
        ),
        Expanded(
          child: _buildWeatherDetailItem(
            PhosphorIcons.wind,
            'الرياح',
            '${weatherData['windSpeed']} كم/س',
          ),
        ),
        Expanded(
          child: _buildWeatherDetailItem(
            PhosphorIcons.eye,
            'الرؤية',
            '${weatherData['visibility']} كم',
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherRecommendation(Map<String, dynamic> weatherData) {
    final recommendation = _getWeatherRecommendation(weatherData['condition']);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            recommendation['icon'],
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation['text'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
            Colors.red.shade400,
          ],
        );
      case 'cloudy':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade600,
            Colors.blueGrey.shade500,
          ],
        );
      case 'rainy':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.indigo.shade500,
          ],
        );
      case 'windy':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade400,
            Colors.teal.shade600,
            Colors.cyan.shade500,
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.indigo.shade500,
          ],
        );
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Colors.orange;
      case 'cloudy':
        return Colors.grey;
      case 'rainy':
        return Colors.blue;
      case 'windy':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  Map<String, dynamic> _getWeatherRecommendation(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return {
          'icon': PhosphorIcons.sun_horizon,
          'text': 'الطقس مثالي للمشي والاستكشاف! لا تنس القبعة وواقي الشمس',
        };
      case 'cloudy':
        return {
          'icon': PhosphorIcons.cloud,
          'text': 'طقس معتدل، مناسب للنشاطات الخارجية بدون قلق من الشمس',
        };
      case 'rainy':
        return {
          'icon': PhosphorIcons.umbrella,
          'text': 'احمل مظلة! ربما يكون الوقت مناسب لزيارة الأماكن المغطاة',
        };
      case 'windy':
        return {
          'icon': PhosphorIcons.wind,
          'text': 'رياح نشطة اليوم، احرص على تثبيت أغراضك جيداً',
        };
      default:
        return {
          'icon': PhosphorIcons.info,
          'text': 'تحقق من الطقس قبل الخروج للاستمتاع بأفضل تجربة',
        };
    }
  }

  Map<String, dynamic> _getMockWeatherData() {
    // بيانات وهمية - يمكن استبدالها ببيانات حقيقية من API
    return {
      'temperature': 24,
      'condition': 'sunny',
      'description': 'مشمس',
      'humidity': 65,
      'windSpeed': 12,
      'visibility': 10,
      'location': 'رام الله',
    };
  }
}