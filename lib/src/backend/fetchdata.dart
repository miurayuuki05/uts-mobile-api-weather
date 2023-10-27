// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: use_key_in_widget_constructors
class WeatherPage extends StatefulWidget {
  final String city;

  const WeatherPage({super.key, required this.city});
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic> _weatherData = {};

  Future<List<Map<String, dynamic>>> fetchLatLong(String city) async {
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$city&limit=5&appid=858dd300a112a11f1233fdde9e291bb8'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> latLongList = [];
      for (final item in data) {
        final Map<String, dynamic> latLong = {
          'latitude': item['lat'],
          'longitude': item['lon'],
        };
        latLongList.add(latLong);
      }
      return latLongList;
    } else {
      throw Exception('Failed to load latitude and longitude data');
    }
  }

  Future<void> _fetchWeatherData(List<Map<String, dynamic>> latLong) async {
    final String lat = latLong[0]['latitude'].toString();
    final String lon = latLong[0]['longitude'].toString();
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=858dd300a112a11f1233fdde9e291bb8'));

    if (response.statusCode == 200) {
      setState(() {
        _weatherData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLatLong(widget.city).then((value) => _fetchWeatherData(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
      ),
      body: Center(
        child: _weatherData.isEmpty
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_weatherData['name']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${_weatherData['weather'][0]['main']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${_weatherData['main']['temp'] - 273.15}°C',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}
