import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MyOffersScreen extends StatefulWidget {
  final String userRole;

  const MyOffersScreen({super.key, required this.userRole});

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
      // Charger les offres selon le rôle de l'utilisateur
      if (widget.userRole == 'VENDEUR') {
        final sellerOffers = await _apiService.getSellerOffers();
        setState(() {
          _offers = sellerOffers;
          _isLoading = false;
        });
      } else {
        final buyerOffers = await _apiService.getBuyerOffers();
        setState(() {
          _offers = buyerOffers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateOfferStatus(int offerId, String status) async {
    try {
      await _apiService.updateOfferStatus(offerId, status);
      _loadOffers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                status == 'ACCEPTEE'
                    ? 'Offre acceptée avec succès'
                    : 'Offre refusée'
            ),
            backgroundColor: status == 'ACCEPTEE' ? Colors.green : Colors.red,
          ),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'REFUSEE':
        return 'Refusée';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ACCEPTEE':
        return Icons.check_circle;
      case 'REFUSEE':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.userRole == 'VENDEUR'
                  ? 'Aucune offre reçue'
                  : 'Aucune offre envoyée',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              widget.userRole == 'VENDEUR'
                  ? 'Les offres de vos acheteurs apparaîtront ici'
                  : 'Recherchez des véhicules et faites des offres',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
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
          final isVendeur = widget.userRole == 'VENDEUR';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec véhicule et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${offer.vehicleBrand} ${offer.vehicleModel}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isVendeur
                                  ? 'Offre de: ${offer.buyerName}'
                                  : 'Votre offre',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(offer.status),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(offer.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Informations de contact (seulement pour le vendeur)
                  if (isVendeur && offer.buyerPhone != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Tél: ${offer.buyerPhone}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Prix proposé
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Prix proposé: ${offer.proposedPrice.toStringAsFixed(0)} TND',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Message de l'offre
                  if (offer.message != null && offer.message!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Message:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(offer.message!),
                        ],
                      ),
                    ),
                  ],

                  // Date de l'offre
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(offer.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Boutons d'action pour le vendeur
                  if (isVendeur && offer.status == 'EN_ATTENTE') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _updateOfferStatus(offer.id, 'ACCEPTEE'),
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text('Accepter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _updateOfferStatus(offer.id, 'REFUSEE'),
                            icon: const Icon(Icons.close, size: 20),
                            label: const Text('Refuser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Message d'information pour l'acheteur selon le statut
                  if (!isVendeur && offer.status != 'EN_ATTENTE') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: offer.status == 'ACCEPTEE'
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: offer.status == 'ACCEPTEE'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            offer.status == 'ACCEPTEE'
                                ? Icons.celebration
                                : Icons.info_outline,
                            color: offer.status == 'ACCEPTEE'
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              offer.status == 'ACCEPTEE'
                                  ? 'Félicitations ! Le vendeur a accepté votre offre. Vous pouvez le contacter pour finaliser l\'achat.'
                                  : 'Le vendeur a décliné votre offre. Vous pouvez rechercher d\'autres véhicules.',
                              style: TextStyle(
                                color: offer.status == 'ACCEPTEE'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? "s" : ""}';
      } else if (difference.inHours > 0) {
        return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? "s" : ""}';
      } else if (difference.inMinutes > 0) {
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""}';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return dateString;
    }
  }
}