import 'package:flutter/material.dart';
import '../../../../core/utils/image_encoder.dart';

/// Menampilkan foto (didekode dari base64) kalau ada, atau inisial nama
/// sebagai fallback — jadi profil tetap terlihat rapi walau user belum
/// pernah upload foto sama sekali.
class ProfileAvatar extends StatelessWidget {
  final String? photoDataUri;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.photoDataUri,
    required this.name,
    this.radius = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = ImageEncoder.decodeDataUri(photoDataUri);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: bytes != null ? MemoryImage(bytes) : null,
            child: bytes == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: radius * 0.7,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          if (onTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: radius * 0.3,
                backgroundColor: colorScheme.primary,
                child: Icon(Icons.camera_alt,
                    size: radius * 0.32, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
