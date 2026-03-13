// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:millionaire_barber/core/constants/app_colors.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:millionaire_barber/core/services/whatsapp_service.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _phoneController = TextEditingController();
//   final _codeController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//
//   bool _isLoading = false;
//   bool _codeSent = false;
//   bool _showPassword = false;
//
//   // ═══════════════════════════════════════════════════════════
//   // 🔐 تشفير كلمة المرور
//   // ═══════════════════════════════════════════════════════════
//   String _hashPassword(String password) {
//     final bytes = utf8.encode(password);
//     return sha256.convert(bytes).toString();
//   }
//
//   // ═══════════════════════════════════════════════════════════
//   // 📧 إرسال رمز التحقق
//   // ═══════════════════════════════════════════════════════════
//   Future<void> _sendResetCode() async {
//     if (_phoneController.text.trim().isEmpty) {
//       _showError('الرجاء إدخال رقم الهاتف');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await Supabase.instance.client.rpc(
//         'generate_password_reset_code',
//         params: {'p_phone': _phoneController.text.trim()},
//       );
//
//       if (response['success'] == true) {
//         final sent = await WhatsAppService.sendVerificationCode(
//           phoneNumber: _phoneController.text.trim(),
//           code: response['reset_code'].toString(),
//         );
//
//         if (sent) {
//           setState(() => _codeSent = true);
//           _showSuccess('تم إرسال رمز التحقق إلى واتساب ✅');
//         } else {
//           _showError('فشل إرسال الرسالة، تأكد من رقم الهاتف');
//         }
//       } else {
//         _showError(response['message']?.toString() ?? 'حدث خطأ');
//       }
//     } catch (e) {
//       _showError('حدث خطأ: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════
//   // ✅ إعادة تعيين كلمة المرور
//   // ═══════════════════════════════════════════════════════════
//   Future<void> _resetPassword() async {
//     if (_codeController.text.trim().isEmpty ||
//         _newPasswordController.text.trim().isEmpty) {
//       _showError('الرجاء إدخال جميع الحقول');
//       return;
//     }
//
//     if (_newPasswordController.text.length < 6) {
//       _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final hashedPassword = _hashPassword(_newPasswordController.text.trim());
//
//       final response = await Supabase.instance.client.rpc(
//         'reset_password_with_code',
//         params: {
//           'p_phone': _phoneController.text.trim(),
//           'p_reset_code': _codeController.text.trim(),
//           'p_new_password': hashedPassword,
//         },
//       );
//
//       if (response['success'] == true) {
//         _showSuccess(response['message']?.toString() ?? 'تم تغيير كلمة المرور');
//         await Future.delayed(Duration(seconds: 2));
//         Navigator.pop(context);
//       } else {
//         _showError(response['message']?.toString() ?? 'حدث خطأ');
//       }
//     } catch (e) {
//       _showError('حدث خطأ: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════
//   // 🎨 UI
//   // ═══════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_rounded,
//             color: isDark ? Colors.white : Colors.black,
//             size: 20.sp,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ═══════════════════════════════════════════════════
//               // أيقونة
//               // ═══════════════════════════════════════════════════
//               _buildIcon(isDark),
//               SizedBox(height: 24.h),
//
//               // ═══════════════════════════════════════════════════
//               // العنوان
//               // ═══════════════════════════════════════════════════
//               _buildTitle(isDark),
//               SizedBox(height: 8.h),
//               _buildSubtitle(isDark),
//               SizedBox(height: 40.h),
//
//               // ═══════════════════════════════════════════════════
//               // المحتوى
//               // ═══════════════════════════════════════════════════
//               if (!_codeSent) ...[
//                 _buildPhoneField(isDark),
//               ] else ...[
//                 _buildOTPSection(isDark),
//                 SizedBox(height: 24.h),
//                 _buildPasswordField(isDark),
//               ],
//
//               SizedBox(height: 32.h),
//
//               // ═══════════════════════════════════════════════════
//               // الزر
//               // ═══════════════════════════════════════════════════
//               _buildActionButton(isDark),
//
//               // ═══════════════════════════════════════════════════
//               // زر إعادة الإرسال
//               // ═══════════════════════════════════════════════════
//               if (_codeSent) ...[
//                 SizedBox(height: 16.h),
//                 _buildResendButton(isDark),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════
//   // Widgets
//   // ═══════════════════════════════════════════════════════════
//
//   Widget _buildIcon(bool isDark) {
//     return Container(
//       height: 100.h,
//       width: 100.w,
//       decoration: BoxDecoration(
//         color: AppColors.darkRed.withOpacity(0.1),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         Icons.lock_reset_rounded,
//         size: 50.sp,
//         color: AppColors.darkRed,
//       ),
//     );
//   }
//
//   Widget _buildTitle(bool isDark) {
//     return Text(
//       _codeSent ? 'تحقق من الرمز' : 'استعادة كلمة المرور',
//       style: TextStyle(
//         fontSize: 28.sp,
//         fontWeight: FontWeight.bold,
//         color: isDark ? Colors.white : Colors.black,
//         fontFamily: 'Cairo',
//       ),
//       textAlign: TextAlign.center,
//     );
//   }
//
//   Widget _buildSubtitle(bool isDark) {
//     return Text(
//       _codeSent
//           ? 'أدخل الرمز المُرسل إلى واتساب'
//           : 'سنرسل لك رمز التحقق عبر واتساب',
//       style: TextStyle(
//         fontSize: 15.sp,
//         color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//         fontFamily: 'Cairo',
//       ),
//       textAlign: TextAlign.center,
//     );
//   }
//
//   Widget _buildPhoneField(bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _phoneController,
//         keyboardType: TextInputType.phone,
//         style: TextStyle(
//           fontSize: 16.sp,
//           color: isDark ? Colors.white : Colors.black,
//           fontFamily: 'Cairo',
//         ),
//         decoration: InputDecoration(
//           hintText: '967777777777',
//           hintStyle: TextStyle(
//             color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//           ),
//           prefixIcon: Icon(
//             Icons.phone_rounded,
//             color: AppColors.darkRed,
//             size: 22.sp,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 20.w,
//             vertical: 18.h,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOTPSection(bool isDark) {
//     return Column(
//       children: [
//         Text(
//           'رمز التحقق',
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//             color: isDark ? Colors.white : Colors.black87,
//             fontFamily: 'Cairo',
//           ),
//         ),
//         SizedBox(height: 16.h),
//
//         Directionality(
//           textDirection: TextDirection.ltr,
//           child: PinCodeTextField(
//             appContext: context,
//             length: 6,
//             controller: _codeController,
//             animationType: AnimationType.fade,
//             animationDuration: Duration(milliseconds: 300),
//
//             pinTheme: PinTheme(
//               shape: PinCodeFieldShape.box,
//               borderRadius: BorderRadius.circular(12.r),
//               fieldHeight: 56.h,
//               fieldWidth: 48.w,
//
//               // الألوان - Dark Mode Support
//               activeColor: AppColors.darkRed,
//               activeFillColor: isDark
//                   ? AppColors.darkRed.withOpacity(0.1)
//                   : AppColors.darkRed.withOpacity(0.05),
//               selectedColor: AppColors.darkRed,
//               selectedFillColor: AppColors.darkRed.withOpacity(0.15),
//               inactiveColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//               inactiveFillColor: isDark
//                   ? const Color(0xFF1E1E1E)
//                   : Colors.grey.shade50,
//               errorBorderColor: Colors.red,
//             ),
//
//             enableActiveFill: true,
//             keyboardType: TextInputType.number,
//             cursorColor: AppColors.darkRed,
//             textStyle: TextStyle(
//               fontSize: 24.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Colors.black,
//             ),
//
//             backgroundColor: Colors.transparent,
//
//             onCompleted: (code) {
//             },
//
//             onChanged: (value) {},
//
//             beforeTextPaste: (text) {
//               return text?.contains(RegExp(r'^[0-9]+$')) ?? false;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPasswordField(bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _newPasswordController,
//         obscureText: !_showPassword,
//         style: TextStyle(
//           fontSize: 16.sp,
//           color: isDark ? Colors.white : Colors.black,
//           fontFamily: 'Cairo',
//         ),
//         decoration: InputDecoration(
//           hintText: 'كلمة المرور الجديدة',
//           hintStyle: TextStyle(
//             color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
//           ),
//           prefixIcon: Icon(
//             Icons.lock_rounded,
//             color: AppColors.darkRed,
//             size: 22.sp,
//           ),
//           suffixIcon: IconButton(
//             icon: Icon(
//               _showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
//               color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
//               size: 20.sp,
//             ),
//             onPressed: () => setState(() => _showPassword = !_showPassword),
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 20.w,
//             vertical: 18.h,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton(bool isDark) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52.h,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : (_codeSent ? _resetPassword : _sendResetCode),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.darkRed,
//           foregroundColor: Colors.white,
//           disabledBackgroundColor: Colors.grey.shade300,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//         ),
//         child: _isLoading
//             ? SizedBox(
//           height: 24.h,
//           width: 24.w,
//           child: const CircularProgressIndicator(
//             color: Colors.white,
//             strokeWidth: 2,
//           ),
//         )
//             : Text(
//           _codeSent ? 'تأكيد وتغيير كلمة المرور' : 'إرسال رمز التحقق',
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Cairo',
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResendButton(bool isDark) {
//     return TextButton(
//       onPressed: () {
//         setState(() {
//           _codeSent = false;
//           _codeController.clear();
//         });
//       },
//       child: Text(
//         'إعادة إرسال الرمز',
//         style: TextStyle(
//           color: AppColors.darkRed,
//           fontSize: 15.sp,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'Cairo',
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════
//   // Helpers
//   // ═══════════════════════════════════════════════════════════
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//       ),
//     );
//   }
//
//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _codeController.dispose();
//     _newPasswordController.dispose();
//     super.dispose();
//   }
// }


import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:millionaire_barber/core/constants/app_colors.dart';
import 'package:millionaire_barber/core/services/whatsapp_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _showPassword = false;

  // ═══════════════════════════════════════════════════════════
  // 🔐 تشفير كلمة المرور
  // ═══════════════════════════════════════════════════════════
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ═══════════════════════════════════════════════════════════
  // 📲 إرسال رمز التحقق
  // ═══════════════════════════════════════════════════════════
  Future<void> _sendResetCode() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showError('الرجاء إدخال رقم الهاتف');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.rpc(
        'generate_password_reset_code',
        params: {'p_phone': phone},
      );

      if (response['success'] == true) {
        final code = response['reset_code'].toString();

        final sent = await WhatsAppService.sendVerificationCode(
          phoneNumber: phone,
          code: code,
        );

        if (sent) {
          setState(() => _codeSent = true);
          _showSuccess('تم إرسال رمز التحقق إلى واتساب ✅');
        } else {
          _showError('فشل إرسال الرسالة، تأكد من رقم الهاتف');
        }
      } else {
        _showError(response['message']?.toString() ?? 'الرقم غير مسجل');
      }
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ إعادة تعيين كلمة المرور
  // ═══════════════════════════════════════════════════════════
  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty) {
      _showError('الرجاء إدخال جميع الحقول');
      return;
    }

    if (code.length < 6) {
      _showError('الرجاء إدخال رمز التحقق كاملاً');
      return;
    }

    if (newPassword.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final hashedPassword = _hashPassword(newPassword);

      final response = await Supabase.instance.client.rpc(
        'reset_password_with_code',
        params: {
          'p_phone': _phoneController.text.trim(),
          'p_reset_code': code,
          'p_new_password': hashedPassword,
        },
      );

      if (response['success'] == true) {
        _showSuccess(
          response['message']?.toString() ?? 'تم تغيير كلمة المرور بنجاح ✅',
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        _showError(response['message']?.toString() ?? 'رمز التحقق غير صحيح');
      }
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🎨 Build
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIcon(),
              SizedBox(height: 24.h),
              _buildTitle(isDark),
              SizedBox(height: 8.h),
              _buildSubtitle(isDark),
              SizedBox(height: 40.h),

              if (!_codeSent) ...[
                _buildPhoneField(isDark),
              ] else ...[
                _buildOTPSection(isDark),
                SizedBox(height: 24.h),
                _buildPasswordField(isDark),
              ],

              SizedBox(height: 32.h),
              _buildActionButton(),

              if (_codeSent) ...[
                SizedBox(height: 16.h),
                _buildResendButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Widgets
  // ═══════════════════════════════════════════════════════════

  Widget _buildIcon() {
    return Center(
      child: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: AppColors.darkRed.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_reset_rounded,
          size: 50.sp,
          color: AppColors.darkRed,
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      _codeSent ? 'تحقق من الرمز' : 'استعادة كلمة المرور',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      _codeSent
          ? 'أدخل الرمز المُرسل إلى واتساب وكلمة المرور الجديدة'
          : 'سنرسل لك رمز التحقق عبر واتساب',
      style: TextStyle(
        fontSize: 15.sp,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return _buildInputContainer(
      isDark: isDark,
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.white : Colors.black,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: '967777777777',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.phone_rounded,
            color: AppColors.darkRed,
            size: 22.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
        ),
      ),
    );
  }

  Widget _buildOTPSection(bool isDark) {
    return Column(
      children: [
        Text(
          'رمز التحقق',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
            fontFamily: 'Cairo',
          ),
        ),
        SizedBox(height: 16.h),
        Directionality(
          textDirection: TextDirection.ltr,
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _codeController,
            animationType: AnimationType.fade,
            animationDuration: const Duration(milliseconds: 300),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12.r),
              fieldHeight: 56.h,
              fieldWidth: 48.w,
              activeColor: AppColors.darkRed,
              activeFillColor: isDark
                  ? AppColors.darkRed.withOpacity(0.1)
                  : AppColors.darkRed.withOpacity(0.05),
              selectedColor: AppColors.darkRed,
              selectedFillColor: AppColors.darkRed.withOpacity(0.15),
              inactiveColor:
              isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              inactiveFillColor:
              isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
              errorBorderColor: Colors.red,
            ),
            enableActiveFill: true,
            keyboardType: TextInputType.number,
            cursorColor: AppColors.darkRed,
            textStyle: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            backgroundColor: Colors.transparent,
            onCompleted: (_) => _resetPassword(),
            onChanged: (_) {},
            beforeTextPaste: (text) =>
            text?.contains(RegExp(r'^[0-9]+$')) ?? false,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return _buildInputContainer(
      isDark: isDark,
      child: TextField(
        controller: _newPasswordController,
        obscureText: !_showPassword,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.white : Colors.black,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'كلمة المرور الجديدة',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: AppColors.darkRed,
            size: 22.sp,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 20.sp,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_codeSent ? _resetPassword : _sendResetCode),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: 24.h,
          width: 24.w,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          _codeSent ? 'تأكيد وتغيير كلمة المرور' : 'إرسال رمز التحقق',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () {
        setState(() {
          _codeSent = false;
          _codeController.clear();
          _newPasswordController.clear();
        });
      },
      child: Text(
        'إعادة إرسال الرمز',
        style: TextStyle(
          color: AppColors.darkRed,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Helper Widgets
  // ═══════════════════════════════════════════════════════════

  Widget _buildInputContainer({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
