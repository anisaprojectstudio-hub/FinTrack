import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(registerControllerProvider.notifier);
    final success = await controller.submit(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!success && mounted) {
      final error = ref.read(registerControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.error?.toString() ?? 'Registrasi gagal.')),
      );
    }
    // Sukses register -> Firebase otomatis sign-in -> router redirect ke Dashboard.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  label: 'Nama',
                  controller: _nameController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  label: 'Email',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  label: 'Password',
                  controller: _passwordController,
                  validator: Validators.password,
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  label: 'Konfirmasi Password',
                  controller: _confirmController,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                    label: 'Daftar', isLoading: isLoading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
