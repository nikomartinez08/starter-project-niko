import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pop();
          } else if (state is AuthError) {
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
                    // Left Column (Dark)
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: const Color(0xFF0F172A),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              left: -20,
                              child: Text(
                                "NEWS",
                                style: TextStyle(
                                  fontSize: 140,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.03),
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
                                    "ÚNETE AHORA",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    "Sé parte de la comunidad informada más influyente. Análisis, datos y contexto en tiempo real.",
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
                    // Right Column (Light)
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: kBgColor,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: _buildRegisterForm(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile Layout
                return Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.network(
                        "https://images.unsplash.com/photo-1566378246598-5b11a0d486cc?q=80&w=2069&auto=format&fit=crop",
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.3, 1.0],
                            colors: [
                              const Color(0xFF0F172A).withValues(alpha: 0.9),
                              const Color(0xFF0F172A).withValues(alpha: 0.8),
                              const Color(0xFFF9FAFB).withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // "NEWS" Watermark
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
                    // Content
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header
                          SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "CREAR CUENTA",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Comienza tu prueba gratuita hoy.",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Form
                          Padding(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                            child: _buildRegisterForm(),
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

  Widget _buildRegisterForm() {
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Registro",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Completa tus datos para continuar.",
                style: TextStyle(
                  fontSize: 14,
                  color: kSecondaryText,
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildLabel("Nombre completo"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: "Juan Pérez",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

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
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Confirm Password Field
              _buildLabel("Confirmar contraseña"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: "••••••••",
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Register Button
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
                            SignUpEvent(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              name: _nameController.text.trim(),
                            ),
                          );
                    }
                  },
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

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

              // Google Button
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
                    "Registrarse con Google",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "¿Ya tienes cuenta? ",
                      style: TextStyle(color: kSecondaryText, fontSize: 13),
                      children: [
                        TextSpan(
                          text: "Iniciar sesión",
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
