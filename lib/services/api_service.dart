import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8085/api'; // Pour émulateur Android
  // static const String baseUrl = 'http://localhost:8080/api'; // Pour iOS

  String? _token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  Future<User> register(String email, String password, String fullName, String role, String? phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return User.fromJson(data);
    } else {
      throw Exception(response.body);
    }
  }

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return User.fromJson(data);
    } else {
      throw Exception(response.body);
    }
  }

  // Vehicles
  Future<List<Vehicle>> searchVehicles({
    String? brand,
    String? model,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
  }) async {
    await _loadToken();

    final queryParams = <String, String>{};
    if (brand != null) queryParams['brand'] = brand;
    if (model != null) queryParams['model'] = model;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (minYear != null) queryParams['minYear'] = minYear.toString();
    if (maxYear != null) queryParams['maxYear'] = maxYear.toString();

    final uri = Uri.parse('$baseUrl/vehicles/search').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la recherche');
    }
  }

  Future<Vehicle> getVehicle(int id) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Véhicule non trouvé');
    }
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Vehicle>> getMyVehicles() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/my-vehicles'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  // Offers
  Future<Offer> createOffer(int vehicleId, double proposedPrice, String? message) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/offers'),
      headers: _getHeaders(),
      body: jsonEncode({
        'vehicleId': vehicleId,
        'proposedPrice': proposedPrice,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      return Offer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Offer>> getBuyerOffers() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/offers/buyer'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Offer.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  Future<List<Offer>> getSellerOffers() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/offers/seller'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Offer.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  Future<Offer> updateOfferStatus(int offerId, String status) async {
    await _loadToken();
    final response = await http.put(
      Uri.parse('$baseUrl/offers/$offerId/status'),
      headers: _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return Offer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  }
}