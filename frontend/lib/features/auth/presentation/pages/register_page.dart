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

  // Dark theme colors matching the home feed
  static const Color kBackground = Color(0xFF000000);
  static const Color kSurface = Color(0xFF1C1C1E);
  static const Color kBorder = Color(0xFF2C2C2E);
  static const Color kPrimaryText = Color(0xFFFFFFFF);
  static const Color kSecondaryText = Color(0xFF8E8E93);
  static const Color kAccent = Color(0xFF636366);

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
      backgroundColor: kBackground,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: kSurface,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildDesktopLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left branding panel
        Expanded(
          flex: 3,
          child: Container(
            color: kBackground,
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
                      color: Colors.white.withValues(alpha: 0.03),
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
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Sé parte de la comunidad informada más influyente. Análisis, datos y contexto en tiempo real.",
                        style: TextStyle(
                          fontSize: 18,
                          color: kSecondaryText,
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
        // Right form panel
        Expanded(
          flex: 2,
          child: Container(
            color: kSurface,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kSurface,
                  kBackground,
                ],
              ),
            ),
          ),
        ),
        // Watermark
        Positioned(
          bottom: -20,
          right: -20,
          child: IgnorePointer(
            child: Text(
              "NEWS",
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.03),
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
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Comienza tu prueba gratuita hoy.",
                        style: TextStyle(
                          fontSize: 15,
                          color: kSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Form
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: _buildForm(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder, width: 1),
      ),
      padding: const EdgeInsets.all(32),
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryText,
                letterSpacing: -0.5,
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

            // Name
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

            // Email
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

            // Password
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

            // Confirm password
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

            // Register button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Divider
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: kBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("O", style: TextStyle(color: kSecondaryText, fontSize: 12)),
                ),
                const Expanded(child: Divider(color: kBorder)),
              ],
            ),
            const SizedBox(height: 24),

            // Google button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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

            const SizedBox(height: 12),

            // GitHub button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  foregroundColor: kPrimaryText,
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(SignInWithGithubEvent());
                },
                icon: const Icon(Icons.code, size: 24),
                label: const Text(
                  "Registrarse con GitHub",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Login link
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
                          color: Colors.white,
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
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kSecondaryText,
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
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kAccent.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: kBackground,
      ),
    );
  }
}
