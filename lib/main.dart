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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Text('L', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white))),
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


abstract class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
}

abstract class AuthPageState<T extends AuthPage> extends State<T> {
  final formKey = GlobalKey<FormState>();
  bool showKeyboard = false;
  String activeField = '';
  
  List<FocusNode> getFocusNodes();
  List<TextEditingController> getControllers();
  
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < getFocusNodes().length; i++) {
      final node = getFocusNodes()[i];
      final fieldName = getFieldNames()[i];
      node.addListener(() {
        if (node.hasFocus) setState(() { showKeyboard = true; activeField = fieldName; });
      });
    }
  }

  List<String> getFieldNames();

  void onKeyTap(String key) {
    final controller = getControllers()[getFieldNames().indexOf(activeField)];
    final text = controller.text;
    final selection = controller.selection;
    
    setState(() {
      if (key == '⌫') {
        if (selection.start > 0) {
          controller.text = text.substring(0, selection.start - 1) + text.substring(selection.end);
          controller.selection = TextSelection.collapsed(offset: selection.start - 1);
        }
      } else {
        final newText = text.substring(0, selection.start) + key + text.substring(selection.end);
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: selection.start + 1);
      }
    });
  }

  Widget buildTextField(String label, TextEditingController controller, FocusNode focus, bool obscure, {int? minLength, TextEditingController? matchController}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focus,
          keyboardType: TextInputType.none,
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
            if (matchController != null && value != matchController.text) return 'Modpas yo pa menm bagay';
            return null;
          },
        ),
      ],
    );
  }

  Widget buildButton(String text, VoidCallback onPressed) {
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

  Widget buildCustomKeyboard() {
    final keys = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '@'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.', '_', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFD7CCC8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: keys.map((row) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTapDown: (_) => onKeyTap(key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: key == '⌫' ? Colors.red.shade300 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: key == '⌫' ? Colors.white : Colors.black87)),
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        )).toList(),
      ),
    );
  }

  void showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in getControllers()) { controller.dispose(); }
    for (var node in getFocusNodes()) { node.dispose(); }
    super.dispose();
  }
}

class LoginPage extends AuthPage {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends AuthPageState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  List<FocusNode> getFocusNodes() => [_emailFocus, _passwordFocus];
  
  @override
  List<TextEditingController> getControllers() => [_emailController, _passwordController];
  
  @override
  List<String> getFieldNames() => ['email', 'password'];

  Future<void> _login() async {
    if (formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email');
        final savedPassword = prefs.getString('user_password');

        if (savedEmail == null || savedPassword == null) {
          showSnackBar('❌ Pa gen kont! Tanpri enskri dabò.', Colors.orange);
          return;
        }

        if (savedEmail.trim().toLowerCase() == _emailController.text.trim().toLowerCase() && savedPassword == _passwordController.text) {
          showSnackBar('✅ Koneksyon reyisi!', Colors.green);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(email: savedEmail)));
        } else {
          showSnackBar('❌ Imèl oswa modpas pa kòrèk!', Colors.red);
        }
      } catch (e) {
        showSnackBar('❌ Erè: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E1),
      body: GestureDetector(
        onTap: () {
          for (var node in getFocusNodes()) { node.unfocus(); }
          setState(() => showKeyboard = false);
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Text('Log In', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 40),
                        buildTextField('Email', _emailController, _emailFocus, false),
                        const SizedBox(height: 24),
                        buildTextField('Password', _passwordController, _passwordFocus, true),
                        const SizedBox(height: 32),
                        buildButton('Log In', _login),
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
              if (showKeyboard) buildCustomKeyboard(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPage extends AuthPage {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends AuthPageState<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  List<FocusNode> getFocusNodes() => [_emailFocus, _passwordFocus, _confirmFocus];
  
  @override
  List<TextEditingController> getControllers() => [_emailController, _passwordController, _confirmPasswordController];
  
  @override
  List<String> getFieldNames() => ['email', 'password', 'confirm'];

  Future<void> _signup() async {
    if (formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text.trim());
        await prefs.setString('user_password', _passwordController.text);

        if (mounted) {
          showSnackBar('✅ Kont ou kreye avèk siksè!', Colors.green);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) showSnackBar('❌ Erè: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: GestureDetector(
        onTap: () {
          for (var node in getFocusNodes()) { node.unfocus(); }
          setState(() => showKeyboard = false);
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text('Sign Up', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 40),
                        buildTextField('Email', _emailController, _emailFocus, false),
                        const SizedBox(height: 24),
                        buildTextField('Password', _passwordController, _passwordFocus, true, minLength: 8),
                        const SizedBox(height: 24),
                        buildTextField('Confirm Password', _confirmPasswordController, _confirmFocus, true, matchController: _passwordController),
                        const SizedBox(height: 32),
                        buildButton('Sign Up', _signup),
                      ],
                    ),
                  ),
                ),
              ),
              if (showKeyboard) buildCustomKeyboard(),
            ],
          ),
        ),
      ),
    );
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