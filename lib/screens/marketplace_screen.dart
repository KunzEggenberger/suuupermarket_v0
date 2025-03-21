import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/listing.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ApiService _apiService = ApiService();
  List<Listing> _listings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final listingsData = await _apiService.getListings();
      setState(() {
        _listings = listingsData.map((data) => Listing.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load listings: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadListings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_listings.isEmpty) {
      return const Center(
        child: Text('No listings available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadListings,
      child: ListView.builder(
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          final listing = _listings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: listing.imagePath != null && listing.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        '${ApiService.baseUrl}/${listing.imagePath}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50);
                        },
                      ),
                    )
                  : const Icon(Icons.image, size: 50),
              title: Text(listing.description),
              subtitle: Text('Price: ${listing.price} BTC2'),
              trailing: Text('Seller: ${listing.seller}'),
              onTap: () {
                // TODO: Navigate to listing details
              },
            ),
          );
        },
      ),
    );
  }
} 