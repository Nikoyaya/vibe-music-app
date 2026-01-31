import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibe_music_app/generated/app_localizations.dart';
import 'package:vibe_music_app/src/pages/auth/register/widgets/controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late RegisterController controller;

  @override
  void initState() {
    super.initState();
    // 创建新的控制器实例
    controller = RegisterController();
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
                      AppLocalizations.of(context)?.register ?? 'Register',
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
                              controller: controller.emailController,
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
                              keyboardType: TextInputType.emailAddress,
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

                          // 发送验证码按钮
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Obx(() {
                              final isDisabled =
                                  controller.isSendingCode.value ||
                                      controller.countdown.value > 0;
                              return ElevatedButton.icon(
                                onPressed: isDisabled
                                    ? null
                                    : controller.sendVerificationCode,
                                icon: controller.isSendingCode.value
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ))
                                    : controller.countdown.value > 0
                                        ? const Icon(Icons.timer,
                                            color: Colors.white)
                                        : const Icon(Icons.send,
                                            color: Colors.white),
                                label: controller.countdown.value > 0
                                    ? Text(
                                        AppLocalizations.of(context)
                                                ?.resendVerificationCode(
                                                    controller
                                                        .countdown.value) ??
                                            'Resend Code (${controller.countdown.value}s)',
                                        style: const TextStyle(
                                            color: Colors.white))
                                    : Text(
                                        AppLocalizations.of(context)
                                                ?.sendVerificationCode ??
                                            'Send Verification Code',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? const Color(0xFF333333)
                                      : const Color(0xFF1E1E1E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }),
                          ),

                          // 验证码输入框（仅发送后显示）
                          Obx(() => controller.verificationSent.value
                              ? Column(
                                  children: [
                                    const SizedBox(height: 16),
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
                                                  color:
                                                      Colors.grey.withAlpha(10),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                      ),
                                      child: TextFormField(
                                        controller: controller
                                            .verificationCodeController,
                                        decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)
                                                      ?.verificationCode ??
                                                  'Verification Code',
                                          prefixIcon: Icon(
                                            Icons.verified_user,
                                            color: isDarkMode
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.transparent,
                                          counterText: '',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                        ],
                                        maxLength: 6,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)
                                                    ?.verificationCodeRequired ??
                                                'Please enter verification code';
                                          }
                                          if (value.length != 6) {
                                            return AppLocalizations.of(context)
                                                    ?.verificationCodeLength ??
                                                'Verification code must be 6 digits';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox()),

                          // 用户名输入框
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
                              controller: controller.usernameController,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)?.username ??
                                        'Username',
                                prefixIcon: Icon(
                                  Icons.person,
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
                                          ?.enterUsername ??
                                      'Please enter username';
                                }
                                return null;
                              },
                            ),
                          ),

                          // 密码输入框
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
                                if (value.length < 6) {
                                  return AppLocalizations.of(context)
                                          ?.passwordLength ??
                                      'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),

                          // 确认密码输入框
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
                              controller: controller.confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                        ?.confirmPassword ??
                                    'Confirm Password',
                                prefixIcon: Icon(
                                  Icons.lock_reset,
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
                                          ?.enterConfirmPassword ??
                                      'Please confirm password';
                                }
                                return null;
                              },
                            ),
                          ),

                          // 注册按钮
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.handleRegister,
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
                                      : Text(AppLocalizations.of(context)
                                              ?.register ??
                                          'Register'),
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

                          // 登录链接
                          TextButton(
                            onPressed: controller.navigateToLogin,
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.alreadyHaveAccount ??
                                  'Already have an account? Login',
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
