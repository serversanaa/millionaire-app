// lib/features/support/data/repositories/support_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/faq_model.dart';
import '../../domain/models/support_message_model.dart';

class SupportRepository {
  final SupabaseClient client;

  SupportRepository(this.client);

  /// جلب الأسئلة الشائعة
  Future<List<FAQModel>> getFAQs() async {
    try {
      final response = await client
          .from('faqs')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => FAQModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// إرسال رسالة دعم
  Future<bool> sendSupportMessage(SupportMessageModel message) async {
    try {
      await client.from('support_messages').insert(message.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب رسائل المستخدم
  Future<List<SupportMessageModel>> getUserMessages(int userId) async {
    try {
      final response = await client
          .from('support_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SupportMessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}