import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Sengaja tidak pakai FirebaseAuth.currentUser.updatePassword() langsung
/// karena itu butuh re-autentikasi baru-baru ini (kalau tidak, akan gagal
/// dengan error "requires-recent-login"). Lebih sederhana & aman untuk MVP:
/// reuse ForgotPasswordUseCase yang sudah ada dari fitur Authentication —
/// kirim link reset password ke email akun sendiri.
class ChangePasswordPage extends ConsumerWidget {
  final String email;
  const ChangePasswordPage({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Untuk keamanan akun, ubah password dilakukan lewat link yang dikirim ke email kamu.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(email, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(forgotPasswordControllerProvider.notifier)
                            .submit(email);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Link ubah password sudah dikirim ke $email'
                                  : 'Gagal mengirim link. Coba lagi.',
                            ),
                          ),
                        );
                      },
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Kirim Link Ubah Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
