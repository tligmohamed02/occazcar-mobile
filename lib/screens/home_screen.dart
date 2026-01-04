import 'package:flutter/material.dart';
import '../models/models.dart';
import 'search_screen.dart';
import 'my_vehicles_screen.dart';
import 'my_offers_screen.dart';
import 'add_vehicle_screen.dart';
import 'conversations_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> _getPages() {
    if (widget.user.role == 'VENDEUR') {
      return [
        const SearchScreen(),
        const MyVehiclesScreen(),
        const MyOffersScreen(),
        const ConversationsScreen(),
      ];
    } else {
      return [
        const SearchScreen(),
        const MyOffersScreen(),
        const ConversationsScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavItems() {
    if (widget.user.role == 'VENDEUR') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Mes véhicules',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Offres',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Mes offres',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OccazCar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profil'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nom: ${widget.user.fullName}'),
                      Text('Email: ${widget.user.email}'),
                      Text('Rôle: ${widget.user.role}'),
                      if (widget.user.phone != null) Text('Tél: ${widget.user.phone}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _getNavItems(),
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: widget.user.role == 'VENDEUR'
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddVehicleScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}