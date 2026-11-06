import 'package:flutter/material.dart';
import '../utils/auth_helper.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _usernameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameC.text.trim();
    final email = _emailC.text.trim();
    final pass = _passC.text;

    if (username.isEmpty || email.isEmpty || pass.isEmpty) {
      CustomSnackbar.show(context, 'Semua kolom wajib diisi', isError: true);
      return;
    }
    if (pass.length < 6) {
      CustomSnackbar.show(
        context,
        'Password minimal 6 karakter',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    final error = await _auth.register(
      username: username,
      email: email,
      password: pass,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      CustomSnackbar.show(context, error, isError: true);
    } else {
      // Firebase otomatis login setelah akun dibuat, jadi langsung ke dashboard
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BackgroundUtama,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 200), // area hijau di atas
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColor.BackgroundKedua,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 130,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DaysOne',
                          color: AppColor.BackgroundUtama,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomInput(
                        controller: _usernameC,
                        hintText: 'Input your username',
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 20),
                      CustomInput(
                        controller: _emailC,
                        hintText: 'Input your email',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      // Password selalu terlihat (obscureText = false)
                      CustomInput(
                        controller: _passC,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 60),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.BackgroundUtama,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontFamily: 'DaysOne',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColor.hint,
                        ),
                        label: const Text(
                          'Back to login',
                          style: TextStyle(
                            color: AppColor.hint,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DaysOne',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
