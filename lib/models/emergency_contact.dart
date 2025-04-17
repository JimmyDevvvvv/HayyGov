class EmergencyContact {
  final String name;
  final String number;
  final String iconUrl;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.iconUrl,
  });

  // Save to SharedPreferences and Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'iconUrl': iconUrl,
    };
  }

  // Load from SharedPreferences
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  // Load from Firestore
  factory EmergencyContact.fromFirestore(Map<String, dynamic> data) {
    return EmergencyContact(
      name: data['name'] ?? '',
      number: data['number'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
    );
  }
}
