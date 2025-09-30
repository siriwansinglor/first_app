import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: ApiAssignment()),
);

class ApiAssignment extends StatefulWidget {
  const ApiAssignment({super.key});
  @override
  State<ApiAssignment> createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<ApiAssignment> {
  late Future<AirData> _future;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _future = fetchAQI();
  }

  Future<AirData> fetchAQI() async {
    const token = '725c0237a7e911bbafbf24702e8361bfb015b61e';
    final url = Uri.parse('https://api.waqi.info/feed/here/?token=$token');

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> root = jsonDecode(res.body);
    if ((root['status'] as String?) != 'ok') {
      throw Exception('API status: ${root['status']}');
    }

    final data = root['data'] as Map<String, dynamic>;
    final int aqi = (data['aqi'] as num?)?.toInt() ?? -1;

    String city = 'Unknown';
    final cityMap = data['city'];
    if (cityMap is Map && cityMap['name'] is String) {
      city = cityMap['name'] as String;
    }

    double? tempC;
    final iaqi = data['iaqi'];
    if (iaqi is Map && iaqi['t'] is Map && (iaqi['t'] as Map)['v'] != null) {
      tempC = ((iaqi['t'] as Map)['v'] as num).toDouble();
    }

    return AirData(aqi: aqi, city: city, temperatureC: tempC);
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _future = fetchAQI();
    });

    try {
      await _future;
    } catch (e) {
      print('Refresh error: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    final weekday = weekdays[now.weekday - 1];

    final hour = now.hour;
    final minute = now.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    return '$weekday, $hour12:${minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<AirData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.green.shade600,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (snap.hasError) {
            return Container(
              color: Colors.red.shade600,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'เกิดข้อผิดพลาด',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snap.error}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snap.data!;
          final level = aqiLevel(data.aqi);

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: level.bgColor),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อเมืองและเวลา
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.city.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCurrentDateTime(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // อุณหภูมิตรงกลาง
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.temperatureC != null
                                ? data.temperatureC!.toInt().toString()
                                : '--',
                            style: const TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 0.8,
                            ),
                          ),
                          const Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // AQI ด้านล่าง
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AQI: ${data.aqi}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ปุ่ม Refresh
                    Center(
                      child: ElevatedButton(
                        onPressed: _isRefreshing ? null : _refresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRefreshing
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: _isRefreshing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AirData {
  final int aqi;
  final String city;
  final double? temperatureC;
  const AirData({required this.aqi, required this.city, this.temperatureC});
}

class AqiLevel {
  final String label;
  final Color bgColor;
  final Color textColor;
  const AqiLevel(this.label, this.bgColor, this.textColor);
}

// ระดับ AQI และสี (อิง US EPA)
AqiLevel aqiLevel(int aqi) {
  if (aqi <= 50) {
    return AqiLevel('Good', Colors.green.shade600, Colors.green.shade900);
  } else if (aqi <= 100) {
    return AqiLevel('Moderate', Colors.yellow.shade700, Colors.orange.shade900);
  } else if (aqi <= 150) {
    return AqiLevel(
      'Unhealthy for Sensitive',
      Colors.orange.shade700,
      Colors.orange.shade900,
    );
  } else if (aqi <= 200) {
    return AqiLevel('Unhealthy', Colors.red.shade600, Colors.red.shade900);
  } else if (aqi <= 300) {
    return AqiLevel(
      'Very Unhealthy',
      Colors.purple.shade600,
      Colors.purple.shade900,
    );
  } else {
    return AqiLevel('Hazardous', Colors.brown.shade700, Colors.brown.shade900);
  }
}
