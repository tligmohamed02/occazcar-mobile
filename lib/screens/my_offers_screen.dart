import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final _apiService = ApiService();
  List<Offer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);

    try {
      final offers = await _apiService.getBuyerOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      try {
        final offers = await _apiService.getSellerOffers();
        setState(() {
          _offers = offers;
          _isLoading = false;
        });
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e2.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _updateOfferStatus(int offerId, String status) async {
    try {
      await _apiService.updateOfferStatus(offerId, status);
      _loadOffers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offre mise à jour')),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACCEPTEE':
        return Colors.green;
      case 'REFUSEE':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_offers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune offre',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      child: ListView.builder(
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${offer.vehicleBrand} ${offer.vehicleModel}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(offer.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          offer.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Acheteur: ${offer.buyerName}'),
                  if (offer.buyerPhone != null)
                    Text('Tél: ${offer.buyerPhone}'),
                  const SizedBox(height: 8),
                  Text(
                    'Prix proposé: ${offer.proposedPrice.toStringAsFixed(0)} TND',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (offer.message != null) ...[
                    const SizedBox(height: 8),
                    Text('Message: ${offer.message}'),
                  ],
                  if (offer.status == 'EN_ATTENTE') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _updateOfferStatus(offer.id, 'ACCEPTEE'),
                            icon: const Icon(Icons.check),
                            label: const Text('Accepter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _updateOfferStatus(offer.id, 'REFUSEE'),
                            icon: const Icon(Icons.close),
                            label: const Text('Refuser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}