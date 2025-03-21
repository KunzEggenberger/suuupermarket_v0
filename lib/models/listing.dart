class Listing {
  final int id;
  final String seller;
  final String description;
  final String price;
  final String cryptoAddress;
  final String? imagePath;

  Listing({
    required this.id,
    required this.seller,
    required this.description,
    required this.price,
    required this.cryptoAddress,
    this.imagePath,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      seller: json['userId'],
      description: json['description'],
      price: json['price'],
      cryptoAddress: json['cryptoAddress'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller': seller,
      'description': description,
      'price': price,
      'cryptoAddress': cryptoAddress,
      'imagePath': imagePath,
    };
  }
} 