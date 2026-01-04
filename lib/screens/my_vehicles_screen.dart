import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'vehicle_detail_screen.dart';
import 'upload_photos_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final _apiService = ApiService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);

    try {
      final vehicles = await _apiService.getMyVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToUploadPhotos(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UploadPhotosScreen(
          vehicleId: vehicle.id,
          vehicleName: '${vehicle.brand} ${vehicle.model}',
        ),
      ),
    ).then((uploaded) {
      if (uploaded == true) {
        _loadVehicles(); // Recharger pour voir les nouvelles photos
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vehicles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun véhicule',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Cliquez sur + pour ajouter un véhicule',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView.builder(
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
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
                      Row(
                        children: [
                          Icon(
                            Icons.photo,
                            size: 16,
                            color: vehicle.photos.isEmpty
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${vehicle.photos.length} photo(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: vehicle.photos.isEmpty
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
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
                    ).then((_) => _loadVehicles());
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _goToUploadPhotos(vehicle),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(vehicle.photos.isEmpty
                              ? 'Ajouter photos'
                              : 'Gérer photos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}