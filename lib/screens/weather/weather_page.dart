import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/colors.dart';
import '../../widgets/navbar.dart';
import 'weather_service.dart';


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _cityController = TextEditingController(text: "Faisalabad");
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchWeather(_cityController.text);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.getWeatherByCity(city);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather for $city. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const NavBar(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 8,
      shadowColor: AppColors.shadowColorDark,
      title: Text(
        "Weather Forecast",
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 9,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _isLoading
              ? _buildLoadingIndicator()
              : _errorMessage.isNotEmpty
              ? _buildErrorMessage()
              : _buildWeatherContent(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _cityController,
        style: TextStyle(color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: 'Enter city name',
          hintStyle: TextStyle(color: AppColors.placeholder),
          prefixIcon: Icon(Icons.location_city, color: AppColors.secondary),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: AppColors.secondary),
            onPressed: () => _fetchWeather(_cityController.text),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: _fetchWeather,
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          const SizedBox(height: 16),
          Text(
            'Fetching weather data...',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: AppColors.redColor),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _fetchWeather(_cityController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(color: AppColors.whiteColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_weather == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildLocationHeader(),
          _buildDateTimeInfo(),
          _buildWeatherIcon(),
          _buildCurrentTemp(),
          _buildExtraInfo(),
          _buildWeatherDetails(),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: AppColors.whiteColor),
          const SizedBox(width: 8),
          Text(
            _weather?.areaName ?? "",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildDateTimeInfo() {
    DateTime now = _weather!.date!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(
            DateFormat("h:mm a").format(now),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${DateFormat("EEEE").format(now)}, ${DateFormat("d MMM y").format(now)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 100.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildWeatherIcon() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.20,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png",
                ),
                fit: BoxFit.contain,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _weather?.weatherDescription?.toUpperCase() ?? "",
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale( begin: Offset(0.8, 0.8),
        end: Offset(1.0, 1.0), duration: 400.ms, delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildCurrentTemp() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 90,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildExtraInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorDark,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildExtraInfoItem(
                icon: Icons.thermostat,
                label: "Max",
                value: "${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C",
              ),
              _buildDivider(),
              _buildExtraInfoItem(
                icon: Icons.ac_unit,
                label: "Min",
                value: "${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C",
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: AppColors.whiteColor.withOpacity(0.3),
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildExtraInfoItem(
                icon: Icons.air,
                label: "Wind",
                value: "${_weather?.windSpeed?.toStringAsFixed(1)} m/s",
              ),
              _buildDivider(),
              _buildExtraInfoItem(
                icon: Icons.water_drop,
                label: "Humidity",
                value: "${_weather?.humidity?.toStringAsFixed(0)}%",
              ),
            ],
          ),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 500.ms, delay: 400.ms);
  }

  Widget _buildExtraInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.whiteColor, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.whiteColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.whiteColor.withOpacity(0.3),
    );
  }

  Widget _buildWeatherDetails() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weather Details",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Feels Like", "${_weather?.tempFeelsLike?.celsius?.toStringAsFixed(1)}°C"),
          _buildDetailRow("Pressure", "${_weather?.pressure?.toStringAsFixed(0)} hPa"),
          _buildDetailRow("Sunrise", _formatTime(_weather?.sunrise)),
          _buildDetailRow("Sunset", _formatTime(_weather?.sunset)),
          _buildDetailRow("Wind Direction", "${_weather?.windDegree?.toStringAsFixed(0)}°"),
          if (_weather?.rainLastHour != null)
            _buildDetailRow("Rain (1h)", "${_weather?.rainLastHour} mm"),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat("h:mm a").format(dateTime);
  }
}