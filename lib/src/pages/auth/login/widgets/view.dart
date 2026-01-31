import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/pages/auth/login/widgets/controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    // 创建新的控制器实例
    controller = LoginController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2A2A2A),
                  ]
                : [
                    const Color(0xFFFDE6F7),
                    const Color(0xFFFFFFFF),
                  ],
          ),
        ),
        child: Column(
          children: [
            // 返回按钮
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, bottom: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: controller.goBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 头部机器人图标
                    Container(
                      margin: const EdgeInsets.only(top: 60, bottom: 30),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF3A1A3A)
                                : const Color(0xFFF4A7C1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6D28D9),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 眼睛
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF6D28D9),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF6D28D9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 天线
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 3,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(1.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      Container(
                                        width: 15,
                                        height: 3,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(1.5),
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
                      ),
                    ),

                    // 标题
                    Text(
                      AppLocalizations.of(context)?.login ?? 'Login In',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                    ),
                    const SizedBox(height: 40),

                    // 表单
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          // 邮箱输入框
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF3A3A3A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.grey.withAlpha(10),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: TextFormField(
                              controller: controller.usernameOrEmailController,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)?.email ??
                                        'Email',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color:
                                      isDarkMode ? Colors.grey : Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)
                                          ?.enterEmail ??
                                      'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return AppLocalizations.of(context)
                                          ?.validEmail ??
                                      'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),

                          // 密码输入框
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF3A3A3A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.grey.withAlpha(10),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: TextFormField(
                              controller: controller.passwordController,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)?.password ??
                                        'Password',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color:
                                      isDarkMode ? Colors.grey : Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)
                                          ?.enterPassword ??
                                      'Please enter password';
                                }
                                return null;
                              },
                            ),
                          ),

                          // 登录按钮
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? const Color(0xFF333333)
                                        : const Color(0xFF1E1E1E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          AppLocalizations.of(context)?.login ??
                                              'Login'),
                                )),
                          ),
                          const SizedBox(height: 32),

                          // 社交登录按钮
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Facebook
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.facebook,
                                  size: 32,
                                  color: Color(0xFF4267B2),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Google
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.g_mobiledata,
                                  size: 32,
                                  color: Color(0xFFDB4437),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Apple
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.apple,
                                  size: 32,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 注册链接
                          TextButton(
                            onPressed: controller.navigateToRegister,
                            child: Text(
                              AppLocalizations.of(context)?.dontHaveAccount ??
                                  'Don\'t have an account? Register',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
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
