import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CustomSnackbar {

  static void showError(BuildContext context, String message) {
    _showMessage(context, ContentType.failure, "خطأ", message);
  }

  static void showSuccess(BuildContext context, String message) {
    _showMessage(context, ContentType.success, "نجاح", message);
  }

  static void showWarning(BuildContext context, String message) {
    _showMessage(context, ContentType.warning, "تحذير", message);
  }

  static void showInfo(BuildContext context, String message) {
    _showMessage(context, ContentType.help, "معلومات", message);
  }

  static void showInternetError(BuildContext context) {
    _showMessage(context, ContentType.failure, "خطأ في الاتصال", "تأكد من اتصالك بالإنترنت وحاول مجددًا");
  }

  static void _showMessage(BuildContext context, ContentType type, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
