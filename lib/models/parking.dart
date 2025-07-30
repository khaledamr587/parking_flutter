class Parking {
  final int? id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final int totalSpots;
  final int availableSpots;
  final double hourlyRate;
  final double dailyRate;
  final String currency;
  final List<String> amenities;
  final String parkingType; // 'public', 'private', 'residential'
  final bool isOpen;
  final String? openingHours;
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Parking({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.totalSpots,
    required this.availableSpots,
    required this.hourlyRate,
    required this.dailyRate,
    this.currency = 'EUR',
    this.amenities = const [],
    this.parkingType = 'public',
    this.isOpen = true,
    this.openingHours,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      country: json['country'],
      totalSpots: json['total_spots'],
      availableSpots: json['available_spots'],
      hourlyRate: json['hourly_rate'].toDouble(),
      dailyRate: json['daily_rate'].toDouble(),
      currency: json['currency'] ?? 'EUR',
      amenities: List<String>.from(json['amenities'] ?? []),
      parkingType: json['parking_type'] ?? 'public',
      isOpen: json['is_open'] ?? true,
      openingHours: json['opening_hours'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      website: json['website'],
      images: List<String>.from(json['images'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'total_spots': totalSpots,
      'available_spots': availableSpots,
      'hourly_rate': hourlyRate,
      'daily_rate': dailyRate,
      'currency': currency,
      'amenities': amenities,
      'parking_type': parkingType,
      'is_open': isOpen,
      'opening_hours': openingHours,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'website': website,
      'images': images,
      'rating': rating,
      'review_count': reviewCount,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  Parking copyWith({
    int? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    int? totalSpots,
    int? availableSpots,
    double? hourlyRate,
    double? dailyRate,
    String? currency,
    List<String>? amenities,
    String? parkingType,
    bool? isOpen,
    String? openingHours,
    String? contactPhone,
    String? contactEmail,
    String? website,
    List<String>? images,
    double? rating,
    int? reviewCount,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Parking(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      currency: currency ?? this.currency,
      amenities: amenities ?? this.amenities,
      parkingType: parkingType ?? this.parkingType,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      website: website ?? this.website,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  double get occupancyRate => totalSpots > 0 ? (totalSpots - availableSpots) / totalSpots : 0.0;
  bool get hasAvailableSpots => availableSpots > 0;
} 