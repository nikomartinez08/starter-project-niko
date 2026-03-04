import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // COLORES CORPORATIVOS
  static const Color kBgColor = Color(0xFFF9FAFB);
  static const Color kPrimaryText = Color(0xFF111827);
  static const Color kSecondaryText = Color(0xFF6B7280);
  static const Color kBorderColor = Color(0xFFE5E7EB);
  static const Color kCtaColor = Color(0xFF1E3A8A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // El layout se encarga del fondo
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                // Desktop Layout: Split Screen
                return Row(
                  children: [
                    // Left Column (Dark, 60% approx via Flex)
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: const Color(0xFF0F172A),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: -20,
                              right: -20,
                              child: Text(
                                "NEWS",
                                style: TextStyle(
                                  fontSize: 140,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0x08FFFFFF),
                                  letterSpacing: -5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(60.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "NEWS APP",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    "Información clara. Contexto real. Análisis sin ruido.",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right Column (Light, 40% approx via Flex)
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: kBgColor,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: _buildRightColumn(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile Layout: Full Screen Background with content
                return Stack(
                  children: [
                    // Full Screen Background Image
                    Positioned.fill(
                      child: Image.network(
                        "https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=2070&auto=format&fit=crop",
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Full Screen Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.3, 1.0],
                            colors: [
                              const Color(0xFF0F172A).withValues(alpha: 0.9), // Dark Blue at top
                              const Color(0xFF0F172A).withValues(alpha: 0.8),
                              const Color(0xFFF9FAFB).withValues(alpha: 0.95), // Light Gray at bottom
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Background Watermark Text (Fixed at bottom right)
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: IgnorePointer(
                        child: Text(
                          "NEWS",
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            letterSpacing: -5,
                          ),
                        ),
                      ),
                    ),
                    // Scrollable Content
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header Content (Transparent background)
                          SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "NEWS APP",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Información clara. Contexto real.",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Form Section
                          Padding(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                            child: _buildRightColumn(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }



  Widget _buildRightColumn() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(40),
        child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Iniciar sesión",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: kPrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Accede a la información que define el futuro.",
              style: TextStyle(
                fontSize: 14,
                color: kSecondaryText,
              ),
            ),
            const SizedBox(height: 32),
            
            // Email Field
            _buildLabel("Correo electrónico"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: "nombre@empresa.com",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Password Field
            _buildLabel("Contraseña"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: "••••••••",
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es requerida';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCtaColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                      SignInEvent(
                        _emailController.text,
                        _passwordController.text,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Ingresar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            // Forgot Password
            Center(
              child: TextButton(
                onPressed: () {
                  // Lógica de recuperación
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    fontSize: 13,
                    color: kSecondaryText,
                  ),
                ),
              ),
            ),

            // Google Sign In
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: kBorderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("O", style: TextStyle(color: kSecondaryText, fontSize: 12)),
                ),
                const Expanded(child: Divider(color: kBorderColor)),
              ],
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  foregroundColor: kPrimaryText,
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(SignInWithGoogleEvent());
                },
                icon: const Icon(Icons.g_mobiledata, size: 28), 
                label: const Text(
                  "Continuar con Google",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

             // Footer: Register / Google (Keeping functional but minimizing style)
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: () {
                   Navigator.of(context).pushNamed('/Register');
                },
                child: RichText(
                  text: const TextSpan(
                    text: "¿No tienes acceso? ",
                    style: TextStyle(color: kSecondaryText, fontSize: 13),
                    children: [
                      TextSpan(
                        text: "Crear cuenta",
                        style: TextStyle(
                          color: kCtaColor,
                          fontWeight: FontWeight.w600,
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
    ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kPrimaryText,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: kPrimaryText,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kSecondaryText.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBorderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: kCtaColor, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
