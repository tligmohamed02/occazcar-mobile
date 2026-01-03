import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final _apiService = ApiService();
  Vehicle? _vehicle;
  bool _isLoading = true;
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    try {
      final vehicle = await _apiService.getVehicle(widget.vehicleId);
      setState(() {
        _vehicle = vehicle;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _makeOffer() async {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un prix')),
      );
      return;
    }

    try {
      await _apiService.createOffer(
        widget.vehicleId,
        double.parse(_priceController.text),
        _messageController.text.isEmpty ? null : _messageController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offre envoyée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _showOfferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faire une offre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Votre prix (TND)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _makeOffer();
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_vehicle == null) {
      return const Scaffold(
        body: Center(child: Text('Véhicule non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_vehicle!.brand} ${_vehicle!.model}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.directions_car, size: 100, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_vehicle!.brand} ${_vehicle!.model}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_vehicle!.price.toStringAsFixed(0)} TND',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Année', _vehicle!.year.toString()),
                  _buildInfoRow('Kilométrage', '${_vehicle!.mileage} km'),
                  if (_vehicle!.fuelType != null)
                    _buildInfoRow('Carburant', _vehicle!.fuelType!),
                  if (_vehicle!.transmission != null)
                    _buildInfoRow('Transmission', _vehicle!.transmission!),
                  if (_vehicle!.color != null)
                    _buildInfoRow('Couleur', _vehicle!.color!),
                  if (_vehicle!.doors != null)
                    _buildInfoRow('Portes', _vehicle!.doors.toString()),
                  const SizedBox(height: 16),
                  if (_vehicle!.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_vehicle!.description!),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  const Text(
                    'Vendeur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Nom: ${_vehicle!.sellerName}'),
                  if (_vehicle!.sellerPhone != null)
                    Text('Tél: ${_vehicle!.sellerPhone}'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showOfferDialog,
                    icon: const Icon(Icons.local_offer),
                    label: const Text('Faire une offre'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}