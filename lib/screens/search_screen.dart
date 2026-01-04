import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'vehicle_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _apiService = ApiService();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  int _lastVehicleCount = 0;
  bool _showNewVehiclesAlert = false;

  @override
  void initState() {
    super.initState();
    _loadLastVehicleCount();
    _searchVehicles();
  }

  Future<void> _loadLastVehicleCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastVehicleCount = prefs.getInt('lastVehicleCount') ?? 0;
    });
  }

  Future<void> _saveVehicleCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastVehicleCount', count);
  }

  Future<void> _searchVehicles() async {
    setState(() => _isLoading = true);

    try {
      final vehicles = await _apiService.searchVehicles(
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        model: _modelController.text.isEmpty ? null : _modelController.text,
      );

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;

        // Vérifier s'il y a de nouveaux véhicules
        if (vehicles.length > _lastVehicleCount && _lastVehicleCount > 0) {
          _showNewVehiclesAlert = true;
          // Afficher une snackbar
          Future.delayed(Duration.zero, () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.new_releases, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('${vehicles.length - _lastVehicleCount} nouveau(x) véhicule(s) !'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() => _showNewVehiclesAlert = false);
                    },
                  ),
                ),
              );
            }
          });
        }

        _saveVehicleCount(vehicles.length);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              if (_showNewVehiclesAlert)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.new_releases, color: Colors.green),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Nouveaux véhicules ajoutés !',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() => _showNewVehiclesAlert = false);
                        },
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marque',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Modèle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _searchVehicles,
                icon: const Icon(Icons.search),
                label: const Text('Rechercher'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _vehicles.isEmpty
              ? const Center(child: Text('Aucun véhicule trouvé'))
              : ListView.builder(
            itemCount: _vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _vehicles[index];
              final isNew = index < (_vehicles.length - _lastVehicleCount);

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Stack(
                  children: [
                    ListTile(
                      leading: vehicle.photos.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://10.0.2.2:8085${vehicle.photos[0]}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.directions_car, size: 40);
                          },
                        ),
                      )
                          : const Icon(Icons.directions_car, size: 40),
                      title: Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${vehicle.year} • ${vehicle.mileage} km'),
                          Text(
                            '${vehicle.price.toStringAsFixed(0)} TND',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                VehicleDetailScreen(vehicleId: vehicle.id),
                          ),
                        );
                      },
                    ),
                    if (isNew && _showNewVehiclesAlert)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOUVEAU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}