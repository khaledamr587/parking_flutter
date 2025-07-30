class Reservation {
  final int? id;
  final int userId;
  final int parkingId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final double totalAmount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  // Additional properties for UI
  final String? parkingName;
  final String? parkingAddress;
  final double? parkingLatitude;
  final double? parkingLongitude;
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  Reservation({
    this.id,
    required this.userId,
    required this.parkingId,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalAmount,
    this.currency = 'EUR',
    this.status = 'pending',
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.transactionId,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.parkingName,
    this.parkingAddress,
    this.parkingLatitude,
    this.parkingLongitude,
    this.userName,
    this.userEmail,
    this.userPhone,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      parkingId: json['parking_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      durationHours: json['duration_hours'],
      totalAmount: json['total_amount'].toDouble(),
      currency: json['currency'] ?? 'EUR',
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      transactionId: json['transaction_id'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      parkingName: json['parking_name'],
      parkingAddress: json['parking_address'],
      parkingLatitude: json['parking_latitude']?.toDouble(),
      parkingLongitude: json['parking_longitude']?.toDouble(),
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'parking_id': parkingId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_hours': durationHours,
      'total_amount': totalAmount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'parking_name': parkingName,
      'parking_address': parkingAddress,
      'parking_latitude': parkingLatitude,
      'parking_longitude': parkingLongitude,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
    };
  }

  Reservation copyWith({
    int? id,
    int? userId,
    int? parkingId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    double? totalAmount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? transactionId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? parkingName,
    String? parkingAddress,
    double? parkingLatitude,
    double? parkingLongitude,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parkingId: parkingId ?? this.parkingId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      parkingName: parkingName ?? this.parkingName,
      parkingAddress: parkingAddress ?? this.parkingAddress,
      parkingLatitude: parkingLatitude ?? this.parkingLatitude,
      parkingLongitude: parkingLongitude ?? this.parkingLongitude,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  bool get isActiveReservation => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isPaid => paymentStatus == 'paid';
  bool get isExpired => DateTime.now().isAfter(endTime);
  Duration get remainingTime => endTime.difference(DateTime.now());
} 