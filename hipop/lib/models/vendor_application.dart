import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  pending,
  approved,
  rejected,
  waitlisted,
}

class VendorApplication extends Equatable {
  final String id;
  final String marketId;
  final String vendorId; // User ID of the vendor applicant
  final String vendorName;
  final String vendorEmail;
  final String? vendorPhone;
  final String businessName;
  final String businessDescription;
  final List<String> productCategories;
  final String? websiteUrl;
  final String? instagramHandle;
  final String? specialRequests; // Special equipment, space needs, etc.
  final ApplicationStatus status;
  final String? reviewNotes; // Organizer notes
  final String? reviewedBy; // Market organizer who reviewed
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata; // Flexible field for additional data

  const VendorApplication({
    required this.id,
    required this.marketId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorEmail,
    this.vendorPhone,
    required this.businessName,
    required this.businessDescription,
    this.productCategories = const [],
    this.websiteUrl,
    this.instagramHandle,
    this.specialRequests,
    this.status = ApplicationStatus.pending,
    this.reviewNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory VendorApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VendorApplication(
      id: doc.id,
      marketId: data['marketId'] ?? '',
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      vendorEmail: data['vendorEmail'] ?? '',
      vendorPhone: data['vendorPhone'],
      businessName: data['businessName'] ?? '',
      businessDescription: data['businessDescription'] ?? '',
      productCategories: List<String>.from(data['productCategories'] ?? []),
      websiteUrl: data['websiteUrl'],
      instagramHandle: data['instagramHandle'],
      specialRequests: data['specialRequests'],
      status: ApplicationStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      reviewNotes: data['reviewNotes'],
      reviewedBy: data['reviewedBy'],
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'marketId': marketId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'vendorEmail': vendorEmail,
      'vendorPhone': vendorPhone,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'productCategories': productCategories,
      'websiteUrl': websiteUrl,
      'instagramHandle': instagramHandle,
      'specialRequests': specialRequests,
      'status': status.name,
      'reviewNotes': reviewNotes,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  VendorApplication copyWith({
    String? id,
    String? marketId,
    String? vendorId,
    String? vendorName,
    String? vendorEmail,
    String? vendorPhone,
    String? businessName,
    String? businessDescription,
    List<String>? productCategories,
    String? websiteUrl,
    String? instagramHandle,
    String? specialRequests,
    ApplicationStatus? status,
    String? reviewNotes,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return VendorApplication(
      id: id ?? this.id,
      marketId: marketId ?? this.marketId,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      vendorPhone: vendorPhone ?? this.vendorPhone,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      productCategories: productCategories ?? this.productCategories,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isPending => status == ApplicationStatus.pending;
  bool get isApproved => status == ApplicationStatus.approved;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get isWaitlisted => status == ApplicationStatus.waitlisted;
  bool get hasBeenReviewed => reviewedAt != null;

  String get statusDisplayName {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.waitlisted:
        return 'Waitlisted';
    }
  }

  // Approve the application
  VendorApplication approve(String reviewerId, {String? notes}) {
    return copyWith(
      status: ApplicationStatus.approved,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
      reviewNotes: notes,
      updatedAt: DateTime.now(),
    );
  }

  // Reject the application
  VendorApplication reject(String reviewerId, {String? notes}) {
    return copyWith(
      status: ApplicationStatus.rejected,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
      reviewNotes: notes,
      updatedAt: DateTime.now(),
    );
  }

  // Waitlist the application
  VendorApplication waitlist(String reviewerId, {String? notes}) {
    return copyWith(
      status: ApplicationStatus.waitlisted,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
      reviewNotes: notes,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        marketId,
        vendorId,
        vendorName,
        vendorEmail,
        vendorPhone,
        businessName,
        businessDescription,
        productCategories,
        websiteUrl,
        instagramHandle,
        specialRequests,
        status,
        reviewNotes,
        reviewedBy,
        reviewedAt,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  String toString() {
    return 'VendorApplication(id: $id, marketId: $marketId, vendorName: $vendorName, businessName: $businessName, status: $status)';
  }
}