class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      phone: json['phone'],
    );
  }
}

class Vehicle {
  final int id;
  final int sellerId;
  final String sellerName;
  final String? sellerPhone;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final double price;
  final String? description;
  final String? fuelType;
  final String? transmission;
  final String? color;
  final int? doors;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String status;
  final String createdAt;

  Vehicle({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhone,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.price,
    this.description,
    this.fuelType,
    this.transmission,
    this.color,
    this.doors,
    required this.photos,
    this.latitude,
    this.longitude,
    this.address,
    required this.status,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      sellerPhone: json['sellerPhone'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      mileage: json['mileage'],
      price: json['price'].toDouble(),
      description: json['description'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      color: json['color'],
      doors: json['doors'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}

class Offer {
  final int id;
  final int vehicleId;
  final String vehicleBrand;
  final String vehicleModel;
  final int buyerId;
  final String buyerName;
  final String? buyerPhone;
  final double proposedPrice;
  final String? message;
  final String status;
  final String createdAt;

  Offer({
    required this.id,
    required this.vehicleId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.buyerId,
    required this.buyerName,
    this.buyerPhone,
    required this.proposedPrice,
    this.message,
    required this.status,
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      vehicleId: json['vehicleId'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
      buyerId: json['buyerId'],
      buyerName: json['buyerName'],
      buyerPhone: json['buyerPhone'],
      proposedPrice: json['proposedPrice'].toDouble(),
      message: json['message'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}

class Message {
  final int id;
  final int vehicleId;
  final String vehicleBrand;
  final String vehicleModel;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final String content;
  final bool isRead;
  final String createdAt;

  Message({
    required this.id,
    required this.vehicleId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      vehicleId: json['vehicleId'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      content: json['content'],
      isRead: json['isRead'],
      createdAt: json['createdAt'],
    );
  }
}

class Conversation {
  final int vehicleId;
  final String vehicleBrand;
  final String vehicleModel;
  final int otherUserId;
  final String otherUserName;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.vehicleId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      vehicleId: json['vehicleId'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
      otherUserId: json['otherUserId'],
      otherUserName: json['otherUserName'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'],
    );
  }
}