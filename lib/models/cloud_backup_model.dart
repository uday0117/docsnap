enum CloudProvider { googleDrive, dropbox, oneDrive }

class CloudAccount {
  final CloudProvider provider;
  final String email;
  final DateTime connectedAt;

  const CloudAccount({
    required this.provider,
    required this.email,
    required this.connectedAt,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'email': email,
        'connectedAt': connectedAt.toIso8601String(),
      };

  factory CloudAccount.fromJson(Map<String, dynamic> json) => CloudAccount(
        provider: CloudProvider.values.firstWhere(
          (p) => p.name == json['provider'],
          orElse: () => CloudProvider.googleDrive,
        ),
        email: json['email'] as String? ?? '',
        connectedAt: DateTime.tryParse(json['connectedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class CloudBackupItem {
  final String id;
  final String name;
  final DateTime modifiedAt;
  final int sizeBytes;

  const CloudBackupItem({
    required this.id,
    required this.name,
    required this.modifiedAt,
    this.sizeBytes = 0,
  });
}
