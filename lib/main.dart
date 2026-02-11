import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APK Today',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
      ),
      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('L', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('APK TODAY', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.blue),
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email');
        final savedPassword = prefs.getString('user_password');

        if (savedEmail == null || savedPassword == null) {
          _showSnackBar('❌ Pa gen kont! Tanpri enskri dabò.', Colors.orange);
          return;
        }

        if (savedEmail.trim().toLowerCase() == _emailController.text.trim().toLowerCase() &&
            savedPassword == _passwordController.text) {
          _showSnackBar('✅ Koneksyon reyisi!', Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(email: savedEmail)),
          );
        } else {
          _showSnackBar('❌ Imèl oswa modpas pa kòrèk!', Colors.red);
        }
      } catch (e) {
        _showSnackBar('❌ Erè: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Log In', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 40),
                  _buildTextField('Email', _emailController, TextInputType.emailAddress, false),
                  const SizedBox(height: 24),
                  _buildTextField('Password', _passwordController, TextInputType.text, true),
                  const SizedBox(height: 32),
                  _buildButton('Log In', _login),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())),
                    child: const Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.black87, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            hintText: obscure ? '••••••' : 'Antre $label',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Tanpri antre $label';
            if (label == 'Email' && !value.contains('@')) return 'Imèl pa valid';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text.trim());
        await prefs.setString('user_password', _passwordController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Kont ou kreye avèk siksè!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Erè: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sign Up', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 40),
                  _buildTextField('Email', _emailController, false, null),
                  const SizedBox(height: 24),
                  _buildTextField('Password', _passwordController, true, 8),
                  const SizedBox(height: 24),
                  _buildTextField('Confirm Password', _confirmPasswordController, true, null),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool obscure, int? minLength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            hintText: obscure ? '••••••' : 'Antre $label',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Tanpri antre $label';
            if (label == 'Email' && !value.contains('@')) return 'Imèl pa valid';
            if (minLength != null && value.length < minLength) return 'Modpas la dwe gen omwen $minLength karaktè';
            if (label == 'Confirm Password' && value != _passwordController.text) return 'Modpas yo pa menm bagay';
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}


class HomePage extends StatelessWidget {
  final String email;
  const HomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Dekonnekte?'),
                  content: const Text('Èske w vle dekonnekte?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Wi')),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.home_rounded, size: 60, color: Color(0xFF1565C0)),
              ),
              const SizedBox(height: 32),
              const Text('Welcome!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              Text(email, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Text('Ou konekte avèk siksè! 🎉', style: TextStyle(fontSize: 18, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person, 'Profil', 'Aktif'),
                      const Divider(height: 32),
                      _buildInfoRow(Icons.notifications, 'Notifikasyon', '3 nouvo'),
                      const Divider(height: 32),
                      _buildInfoRow(Icons.settings, 'Paramèt', 'Konfigire'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.black26),
      ],
    );
  }
}
