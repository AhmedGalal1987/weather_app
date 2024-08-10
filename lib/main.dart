import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String _cityName = '';
  String _temperature = '';
  String _description = '';
  String _weatherIcon = '';
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getWeather,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) // عرض مؤشر التحميل عند بدء البحث
              const CircularProgressIndicator(),
            if (_temperature.isNotEmpty && !_isLoading)
              Column(
                children: [
                  Image.network(
                      'https://openweathermap.org/img/w/$_weatherIcon.png'),
                  const SizedBox(height: 5),
                  Text(
                    'City: $_cityName',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Temperature: $_temperature°C',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Description: $_description',
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
            if (_errorMessage.isNotEmpty && !_isLoading)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getWeather() async {
    setState(() {
      _isLoading = true;
      _cityName = '';
      _temperature = '';
      _description = '';
      _weatherIcon = '';
      _errorMessage = '';
    });
    final cityName = _cityController.text;
    const apiKey =
        'af4f1b1a07563f218114215ffbf1a801'; // استخدم مفتاح API الخاص بك هنا
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _cityName = data['name'];
          _temperature = data['main']['temp'].toString();
          _description = data['weather'][0]['description'];
          _weatherIcon = data['weather'][0]['icon'];
        });
      } else {
        setState(() {
          _errorMessage = data['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data. Please try again.';
      });
    }
    _isLoading = false;
  }
}
