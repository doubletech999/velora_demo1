// lib/presentation/screens/home/widgets/weather_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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

  Map<String, dynamic>? weatherData;
  bool loading = true;
  bool error = false;

  static const String apiKey = "82dc1fade471967ebaa5843b8a08c620";
  static const String lang = "ar";
  static const String units = "metric";

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _loadWeatherData() async {
    try {
      final pos = await _determinePosition();
      final data = await _fetchWeather(pos.latitude, pos.longitude);

      setState(() {
        weatherData = data;
        loading = false;
        error = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("تم رفض إذن الموقع");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, dynamic>> _fetchWeather(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=$units&lang=$lang&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      String normalizedCondition = _normalizeCondition(
        jsonData["weather"][0]["main"] ?? "",
      );

      return {
        "temperature": jsonData["main"]["temp"]?.round(),
        "condition": normalizedCondition,
        "description": jsonData["weather"][0]["description"] ?? "",
        "humidity": jsonData["main"]["humidity"],
        "windSpeed": jsonData["wind"]["speed"]?.round(),
        "visibility": (jsonData["visibility"] / 1000).round(),
        "location": jsonData["name"],
      };
    } else {
      throw Exception("فشل في الحصول على الطقس");
    }
  }

  String _normalizeCondition(String input) {
    input = input.toLowerCase();
    if (input.contains("rain")) return "rainy";
    if (input.contains("cloud")) return "cloudy";
    if (input.contains("wind")) return "windy";
    return "sunny";
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
          child:
              loading
                  ? Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : (error || weatherData == null)
                  ? _buildError()
                  : _buildWeatherCard(weatherData!),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "⚠️ فشل في جلب بيانات الطقس",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> weatherData) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherIcon(weatherData['condition']),
            const SizedBox(width: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final descriptionMaxWidth = (constraints.maxWidth - 72).clamp(
                    120.0,
                    constraints.maxWidth,
                  );

                  return Column(
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
                      Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${weatherData['temperature']}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: descriptionMaxWidth,
                            ),
                            child: Text(
                              weatherData['description'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _buildLocationBadge(weatherData['location']),
        ),
      ],
    );
  }

  Widget _buildLocationBadge(String location) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              location,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (condition) {
      case "sunny":
        iconData = PhosphorIcons.sun;
        iconColor = Colors.orange.shade300;
        break;
      case "cloudy":
        iconData = PhosphorIcons.cloud;
        break;
      case "rainy":
        iconData = PhosphorIcons.cloud_rain;
        iconColor = Colors.blue.shade200;
        break;
      case "windy":
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
      child: Icon(iconData, color: iconColor, size: 32),
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
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
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
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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

  Map<String, dynamic> _getWeatherRecommendation(String condition) {
    switch (condition) {
      case 'sunny':
        return {
          'icon': PhosphorIcons.sun_horizon,
          'text': 'جو مثالي للنشاطات الخارجية ☀️',
        };
      case 'cloudy':
        return {
          'icon': PhosphorIcons.cloud,
          'text': 'طقس معتدل مناسب للمشي ☁️',
        };
      case 'rainy':
        return {'icon': PhosphorIcons.umbrella, 'text': 'احمل مظلتك! 🌧️'};
      case 'windy':
        return {'icon': PhosphorIcons.wind, 'text': 'الهواء قوي، كن حذراً 💨'};
      default:
        return {
          'icon': PhosphorIcons.info,
          'text': 'تحقق من الطقس قبل الخروج ✅',
        };
    }
  }

  LinearGradient _getWeatherGradient(String condition) {
    switch (condition) {
      case 'sunny':
        return LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
            Colors.red.shade400,
          ],
        );
      case 'cloudy':
        return LinearGradient(
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade600,
            Colors.blueGrey.shade500,
          ],
        );
      case 'rainy':
        return LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.indigo.shade500,
          ],
        );
      case 'windy':
        return LinearGradient(
          colors: [
            Colors.teal.shade400,
            Colors.teal.shade600,
            Colors.cyan.shade500,
          ],
        );
      default:
        return LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.indigo.shade500,
          ],
        );
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition) {
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
}
