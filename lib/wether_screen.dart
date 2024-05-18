import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forcast_items.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secret_key.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'pauri';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      // temp = (data['list'][0]['main']['temp']);
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // InkWell(
          //   onTap: () {
          //     print("Refresh");
          //   },
          // child: const Icon(Icons.refresh),
          // ),
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTempInK = currentWeatherData['main']['temp'];
          final currentTempInC = currentTempInK - 273.85;
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentPressure = currentWeatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main cart
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currentTempInC.toStringAsFixed(2)} ° C',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 32),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? (Icons.cloud)
                                    : (Icons.sunny),
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                currentSky,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // wether forcast cart
                const Text(
                  "Hourly Forcast",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 2; i <= 7; i++)
                //         HourlyForecastItem(
                //           time: data["list"][i]['dt_txt'].toString(),
                //           icon: data["list"][i]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data["list"][i]['weather'][0]['main'] ==
                //                       'Rain'
                //               ? (Icons.cloud)
                //               : (Icons.sunny),
                //           temp: data["list"][i]['main']['temp'].toString(),
                //         )
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyDorcast = data["list"][index + 1];
                      final iconClouds = hourlyDorcast['weather'][0]['main'];
                      final hourlyTempInK = hourlyDorcast['main']['temp'];
                      final hourlyTempInC = hourlyTempInK - 273.85;
                      final time = DateTime.parse(hourlyDorcast['dt_txt']);
                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icon: iconClouds == 'Clouds' || iconClouds == 'Rain'
                            ? (Icons.cloud)
                            : (Icons.sunny),
                        temp: '${hourlyTempInC.toStringAsFixed(2)}',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                // additional info
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalinfoItem(
                      icon: Icons.water_drop,
                      label: "humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionalinfoItem(
                      icon: Icons.air,
                      label: "Wind Speed ",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalinfoItem(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
