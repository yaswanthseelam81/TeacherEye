import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const TeacherEyeApp());

class TeacherEyeApp extends StatelessWidget {
  const TeacherEyeApp({super.key});

  static const routeLanding = '/';
  static const routeLogin = '/login';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeacherEye AI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D5EF6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF070A12),
      ),
      initialRoute: routeLanding,
      routes: {
        routeLanding: (_) => const LandingPage(),
        routeLogin: (_) => const LoginPage(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      _TopBar(
                        onLogin: () => Navigator.pushNamed(
                          context,
                          TeacherEyeApp.routeLogin,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: _Hero(
                          onLogin: () => Navigator.pushNamed(
                            context,
                            TeacherEyeApp.routeLogin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onLogin;
  const _TopBar({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return _Glass(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.visibility, color: Color(0xFF00E5FF)),
            const SizedBox(width: 10),
            Text(
              'TeacherEye AI',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            OutlinedButton(onPressed: onLogin, child: const Text('Login')),
            const SizedBox(width: 10),
            FilledButton(onPressed: () {}, child: const Text('Get Started')),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final VoidCallback onLogin;
  const _Hero({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return _Glass(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pill('AI-powered engagement monitoring'),
            const SizedBox(height: 14),
            Text(
              'AI That Understands\nStudent Attention',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: 0.85,
              child: Text(
                'Real-time engagement monitoring for smarter online learning.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Spacer(),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Live Demo'),
                ),
                OutlinedButton(onPressed: onLogin, child: const Text('Login')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return _Glass(
      radius: 999,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF00E5FF)),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final Uri _loginUrl = Uri.parse(
    'http://127.0.0.1:5000/api/auth/login',
  );

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(const SnackBar(content: Text('Logging in...')));

    try {
      final res = await http.post(
        _loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email.text.trim(),
          'password': _password.text,
        }),
      );

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && body['ok'] == true) {
        final name = (body['user']?['name'] ?? 'User').toString();
        messenger.showSnackBar(SnackBar(content: Text('Login success: $name')));
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(body['message']?.toString() ?? 'Login failed'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth >= 900;
                      return wide
                          ? Row(
                              children: [
                                const Expanded(child: _LoginSideArt()),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: _LoginCard(
                                    formKey: _formKey,
                                    email: _email,
                                    password: _password,
                                    obscure: _obscure,
                                    loading: _loading,
                                    onToggleObscure: () =>
                                        setState(() => _obscure = !_obscure),
                                    onSubmit: _loading ? null : _submit,
                                  ),
                                ),
                              ],
                            )
                          : _LoginCard(
                              formKey: _formKey,
                              email: _email,
                              password: _password,
                              obscure: _obscure,
                              loading: _loading,
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                              onSubmit: _loading ? null : _submit,
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: SafeArea(
              child: _Glass(
                radius: 14,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final Future<void> Function()? onSubmit;

  const _LoginCard({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: 0.8,
                child: Text(
                  'Login to continue to TeacherEye AI',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Email is required';
                  if (!s.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (v) {
                  final s = (v ?? '');
                  if (s.isEmpty) return 'Password is required';
                  if (s.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSubmit,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: Text(loading ? 'Please wait...' : 'Login'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Create new account (Register next)'),
                ),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: 0.7,
                child: Text(
                  'Test creds: admin@teachereye.ai / admin123',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginSideArt extends StatelessWidget {
  const _LoginSideArt();

  @override
  Widget build(BuildContext context) {
    return _Glass(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chip('AI face scan'),
            const SizedBox(height: 18),
            Text(
              'Secure sign-in\nwith intelligent UX',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: 0.85,
              child: Text(
                'This will call your Flask login API.\nNext step: store JWT + go to Dashboard.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Spacer(),
            const _FakeScanWidget(),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return _Glass(
      radius: 999,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.face_retouching_natural,
              size: 18,
              color: Color(0xFF00E5FF),
            ),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _FakeScanWidget extends StatelessWidget {
  const _FakeScanWidget();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1435), Color(0xFF0A0F2B), Color(0xFF070A12)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 210,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0xFF1526FF),
                  Color(0xFF0A0F2B),
                  Color(0xFF070A12),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned(left: -120, top: 140, child: _Glow(Color(0xFF00E5FF), 260)),
        Positioned(
          right: -140,
          bottom: -60,
          child: _Glow(Color(0xFF8A2BE2), 320),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color c;
  final double s;
  const _Glow(this.c, this.s);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.18),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.35),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  const _Glass({required this.child, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const cols = 3;
    const rows = 2;

    for (int i = 1; i < cols; i++) {
      final x = size.width * (i / cols);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int j = 1; j < rows; j++) {
      final y = size.height * (j / rows);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
