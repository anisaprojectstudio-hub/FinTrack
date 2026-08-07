import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_menu_tile.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
            'Kamu perlu login lagi untuk mengakses data keuanganmu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (confirmed == true) {
      // Setelah logout, authStateProvider otomatis berubah dan _AuthGate di
      // main.dart yang mengarahkan kembali ke LoginPage — tidak perlu
      // navigasi manual di sini.
      await ref.read(logoutUseCaseProvider).call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 24),
            SettingsMenuTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profil',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
              ),
            ),
            SettingsMenuTile(
              icon: Icons.lock_outline,
              title: 'Ubah Password',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ChangePasswordPage(email: user.email)),
              ),
            ),
            SettingsMenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              trailing: Switch(
                value: user.notificationsEnabled,
                onChanged: (v) => ref
                    .read(notificationToggleControllerProvider.notifier)
                    .toggle(v),
              ),
            ),
            SettingsMenuTile(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'FinTrack',
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                      'Aplikasi manajemen keuangan pribadi — Flutter, Riverpod, Firebase.'),
                ],
              ),
            ),
            const Divider(height: 32),
            SettingsMenuTile(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red.shade400,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat profil: $err')),
      ),
    );
  }
}
