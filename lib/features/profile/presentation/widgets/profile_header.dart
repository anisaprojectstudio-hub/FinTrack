import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../providers/profile_providers.dart';
import 'profile_avatar.dart';

class ProfileHeader extends ConsumerWidget {
  final UserEntity user;

  const ProfileHeader({super.key, required this.user});

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;
    await ref
        .read(photoUploadControllerProvider.notifier)
        .upload(File(picked.path));

    final state = ref.read(photoUploadControllerProvider);
    if (state.hasError && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading = ref.watch(photoUploadControllerProvider).isLoading;

    return Column(
      children: [
        Stack(
          children: [
            ProfileAvatar(
              photoDataUri: user.photoUrl,
              name: user.name.isEmpty ? user.email : user.name,
              radius: 44,
              onTap: isUploading ? null : () => _pickAndUpload(context, ref),
            ),
            if (isUploading)
              Positioned.fill(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name.isNotEmpty ? user.name : user.email,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(user.email, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
