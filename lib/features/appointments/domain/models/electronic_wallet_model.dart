// lib/features/booking/domain/models/electronic_wallet_model.dart

import 'package:millionaire_barber/core/utils/type_parser.dart';

class ElectronicWalletModel {
  final int id;
  final String walletName;
  final String walletNameAr;
  final String phoneNumber;
  final String? accountName;
  final String walletType;
  final String? iconUrl;
  final bool isActive;
  final int displayOrder;

  ElectronicWalletModel({
    required this.id,
    required this.walletName,
    required this.walletNameAr,
    required this.phoneNumber,
    this.accountName,
    required this.walletType,
    this.iconUrl,
    required this.isActive,
    required this.displayOrder,
  });

  factory ElectronicWalletModel.fromJson(Map<String, dynamic> json) {
    return ElectronicWalletModel(
      id:           parseInt(json['id']),
      walletName:   parseString(json['wallet_name']),
      walletNameAr: parseString(json['wallet_name_ar']),
      phoneNumber:  parseString(json['phone_number']),
      accountName:  parseString(json['account_name'], defaultValue: ''),
      walletType:   parseString(json['wallet_type']),
      iconUrl:      parseString(json['icon_url'], defaultValue: ''),
      isActive:     json['is_active'] as bool? ?? true,
      displayOrder: parseInt(json['display_order']) ?? 0,
    );
  }

  /// أيقونة المحفظة حسب نوعها
  String get iconAsset {
    switch (walletType) {
      case 'kash':     return 'assets/icons/kash.png';
      case 'floosak':  return 'assets/icons/floosak.png';
      case 'telecash': return 'assets/icons/telecash.png';
      default:         return 'assets/icons/wallet.png';
    }
  }
}
