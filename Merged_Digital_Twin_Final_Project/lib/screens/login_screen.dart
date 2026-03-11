import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/state.dart';
import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool remember = true;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DT.bg, Color(0xFF0B1220), Color(0xFF082F49)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22,
                  22,
                  22,
                  22 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: DT.grad,
                            boxShadow: [
                              BoxShadow(color: DT.blue.alphaF(0.35), blurRadius: 24, offset: const Offset(0, 14)),
                            ],
                          ),
                          child: const Icon(Icons.factory_rounded, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Digital Twin',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text('Industrial IoT Monitoring', style: TextStyle(color: DT.muted(0.55), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 22),

                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email', style: TextStyle(color: DT.muted(0.70), fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your email',
                                  prefixIcon: Icon(Icons.mail_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text('Password', style: TextStyle(color: DT.muted(0.70), fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: pass,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon: Icon(Icons.lock_rounded),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Checkbox(
                                    value: remember,
                                    onChanged: (v) => setState(() => remember = v ?? true),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Remember me',
                                      style: TextStyle(color: DT.muted(0.55), fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        GradientButton(
                          text: 'Sign In',
                          onTap: () => context.read<AppState>().login(),
                        ),

                        const SizedBox(height: 14),
                        Text(
                          "Don't have an account? Contact Admin",
                          style: TextStyle(color: DT.muted(0.50), fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}