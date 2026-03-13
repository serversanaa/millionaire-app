import 'dart:io';

import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';

class PaymentResult {
  final String               paymentMethod; // 'cash' | 'electronic'
  final ElectronicWalletModel? wallet;       // المحفظة المختارة إن وُجدت
  final File?                receiptFile;   // ملف الإيصال
  final String               paymentLabel;  // نص للعرض

  const PaymentResult({
    required this.paymentMethod,
    this.wallet,
    this.receiptFile,
    required this.paymentLabel,
  });
}
