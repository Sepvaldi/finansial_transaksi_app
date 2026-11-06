import 'package:flutter/material.dart';
import '../utils/auth_helper.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _auth = AuthService();
  final _passFocus = FocusNode();
  bool _obscure = true; // true = password disembunyikan
  bool _loading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _login() async {
    final email = _emailC.text.trim();
    final pass = _passC.text;
    if (email.isEmpty || pass.isEmpty) {
      CustomSnackbar.show(
        context,
        'Email dan password wajib diisi',
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus(); // tutup keyboard dulu
    setState(() => _loading = true);
    String? error;
    try {
      error = await _auth.login(email, pass);
    } finally {
      // finally = SELALU dijalankan, jadi _loading pasti kembali false
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;

    if (error != null) {
      CustomSnackbar.show(context, error, isError: true);
      _passC.clear(); // kosongkan password yang salah
      // minta fokus setelah frame selesai digambar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passFocus.requestFocus();
      });
    } else {
      _goHome();
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loading = true);
    String? error;
    try {
      error = await _auth.signInWithGoogle();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;

    if (error != null) {
      CustomSnackbar.show(context, error, isError: true);
    } else {
      _goHome();
    }
  }

  Future<void> _forgotPassword() async {
    final email = await CustomDialog.askEmail(
      context,
      initial: _emailC.text.trim(),
    );
    if (email == null || email.isEmpty) return;

    final error = await _auth.resetPassword(email);
    if (!mounted) return;
    CustomSnackbar.show(
      context,
      error ?? 'Link reset password dikirim ke $email',
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BackgroundUtama,
      body: SafeArea(
        child: Column(
          children: [
            // Header hijau
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 90),
              child: Column(
                children: [
                  Text(
                    'Hello!',
                    style: TextStyle(
                      fontSize: 56,
                      fontFamily: 'DaysOne',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Welcome to my bank gua',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Card abu-abu dengan sudut atas melengkung
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
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DaysOne',
                          color: AppColor.BackgroundUtama,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomInput(
                        controller: _emailC,
                        hintText: 'Input your email',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomInput(
                        controller: _passC,
                        focusNode: _passFocus,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      SizedBox(height: 25),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColor.link,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 33),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
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
                                  'Login',
                                  style: TextStyle(
                                    color: AppColor.primary,

                                    fontFamily: 'DaysOne',
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColor.hint, thickness: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or login with',
                              style: TextStyle(color: AppColor.hint),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColor.hint, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _loading ? null : _loginGoogle,
                        borderRadius: BorderRadius.circular(30),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'assets/images/google_2.png',
                            width: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have account? ",
                            style: TextStyle(
                              color: AppColor.hint,
                              fontFamily: 'DaysOne',
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: AppColor.BackgroundUtama,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DaysOne',
                              ),
                            ),
                          ),
                        ],
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
