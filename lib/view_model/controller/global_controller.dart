import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/data/network/api_services.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/utils/utils.dart';

class GlobalController extends GetxController {
  final RxBool _isLoading = true.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final Rx<WeatherModel?> _weatherData = Rx<WeatherModel?>(null);
  final RxString _weatherMain = ''.obs;

  RxBool checkLoading() => _isLoading;

  RxDouble getLatitude() => latitude;

  RxDouble getLongitude() => longitude;

  Rx<WeatherModel?> getWeatherModel() => _weatherData;

  WeatherModel? weatherDataValue() => _weatherData.value;

  String get weatherMain => _weatherMain.value;

  void setWeatherMain(String value) {
    _weatherMain.value = value;
  }

  //String weatherDescription() =>
  String weatherDescription() {
     final weatherData = weatherDataValue();
    if (weatherData != null && weatherData.weather != null && weatherData.weather!.isNotEmpty) {
      final description = weatherData.weather![0].description;
      if (description != null) {
        return description.toUpperCase().toString();
      }
    }
    return 'N/A'; // Return a default value or handle the case when data is not available.
  }
    //  weatherDataValue()!.weather![0].description!.toUpperCase().toString();

  // String weatherIconCode() => weatherDataValue()!.weather![0].icon.toString();

  // String currentTemperature() =>
  //     weatherDataValue()!.main!.temp!.round().toString();

  // String minTemperature() =>
  //     weatherDataValue()!.main!.tempMin!.round().toString();

  // String maxTemperature() =>
  //     weatherDataValue()!.main!.tempMax!.round().toString();

    String weatherIconCode() {
    final iconCode = weatherDataValue()?.weather?[0].icon;
    return iconCode ?? 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String currentTemperature() {
    final temp = weatherDataValue()?.main?.temp;
    return temp?.round().toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String minTemperature() {
    final minTemp = weatherDataValue()?.main?.tempMin;
    return minTemp?.round().toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String maxTemperature() {
    final maxTemp = weatherDataValue()?.main?.tempMax;
    return maxTemp?.round().toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
  }

   String pressure() {
    final weatherData = weatherDataValue();
    if (weatherData != null && weatherData.main != null) {
      final pressure = weatherData.main!.pressure;
      return pressure?.toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
    }
    return 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String humidity() {
    final weatherData = weatherDataValue();
    if (weatherData != null && weatherData.main != null) {
      final humidity = weatherData.main!.humidity;
      return humidity?.toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
    }
    return 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String visibility() {
    final visibility = weatherDataValue()?.visibility;
    return visibility?.toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String sunriseTime() {
    final sunrise = weatherDataValue()?.sys?.sunrise;
    return sunrise != null ? Utils.convertTimestampToTime(sunrise.toString()) : 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String sunsetTime() {
    final sunset = weatherDataValue()?.sys?.sunset;
    return sunset != null ? Utils.convertTimestampToTime(sunset.toString()) : 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String windSpeed() {
    final windSpeed = weatherDataValue()?.wind?.speed;
    return windSpeed != null ? Utils.convertSpeed(windSpeed.toString()) : 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String windDirection() {
    final windDirection = weatherDataValue()?.wind?.deg;
    return windDirection != null ? Utils.getWindDirection(windDirection.toString()) : 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String feelsLike() {
    final feelsLike = weatherDataValue()?.main?.feelsLike;
    return feelsLike?.round().toString() ?? 'N/A'; // Return a default value or handle the case when data is not available.
  }

  String dtValue() {
    final dt = weatherDataValue()?.dt;
    return dt != null ? Utils.convertDtToTime(dt.toString()) : 'N/A'; // Return a default value or handle the case when data is not available.
  }

  // String pressure() => '${weatherDataValue()!.main!.pressure.toString()} hPa';

  // String humidity() => '${weatherDataValue()!.main!.humidity.toString()} %';

  // String visibility() =>
  //     Utils.convertVisibility(weatherDataValue()!.visibility.toString());

  // String sunriseTime() =>
  //     Utils.convertTimestampToTime(weatherDataValue()!.sys!.sunrise.toString());

  // String sunsetTime() =>
  //     Utils.convertTimestampToTime(weatherDataValue()!.sys!.sunset.toString());

  // String windSpeed() =>
  //     Utils.convertSpeed(weatherDataValue()!.wind!.speed.toString());

  // String windDirection() =>
  //     Utils.getWindDirection(weatherDataValue()!.wind!.deg.toString());

  // String feelsLike() => weatherDataValue()!.main!.feelsLike!.round().toString();

  // String dtValue() => Utils.convertDtToTime(weatherDataValue()!.dt.toString());

  @override
  void onInit() {
    super.onInit();
    if (_isLoading.isTrue) {
      getLocationAndFetchWeather();
    }
  }

  Future<void> getLocationAndFetchWeather() async {
    try {

      await getLocation();
      await getWeather();
    } catch (e) {
      print('Error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Location',
            'Location permissions are denied',
            snackPosition: SnackPosition.BOTTOM,
          );
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Future<void> getWeather() async {
  //   try {
  //     final weatherData = await ApiServices().getWeatherApi(
  //       latitude.value,
  //       longitude.value,
  //     );

  //     final weatherModel = WeatherModel.fromJson(weatherData);
  //     setWeatherMain(weatherModel.weather![0].main!.toString());

  //     _weatherData.value = weatherModel;
  //   } catch (e) {
  //     print('Error fetching weather data: $e');
  //   }
  // }
  Future<void> getWeather() async {
  try {
    final weatherData = await ApiServices().getWeatherApi(
      latitude.value,
      longitude.value,
    );

    print('Weather Data from API: $weatherData');

    final weatherModel = WeatherModel.fromJson(weatherData);
    print('Weather Model: $weatherModel');

    if (weatherModel.weather != null && weatherModel.weather!.isNotEmpty) {
      final mainDescription = weatherModel.weather![0].main;
      print('Main Description: $mainDescription');
    }

    setWeatherMain(weatherModel.weather?[0].main?.toString() ?? 'N/A');

    _weatherData.value = weatherModel;
  } catch (e) {
    print('Error fetching weather data: $e');
  }
}
}
