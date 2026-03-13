import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/support_repository.dart';
import '../../domain/models/faq_model.dart';
import '../../domain/models/support_message_model.dart';

class SupportProvider extends ChangeNotifier {
  final SupportRepository supportRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  SupportProvider({required this.supportRepository});

  List<FAQModel> _faqs = [];
  List<FAQModel> get faqs => _faqs;

  List<SupportMessageModel> _messages = [];
  List<SupportMessageModel> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  /// جلب الأسئلة الشائعة
  Future<void> fetchFAQs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _faqs = await supportRepository.getFAQs();
    } catch (e) {
      _error = 'فشل تحميل الأسئلة الشائعة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إرسال رسالة دعم
  Future<bool> sendMessage({
    required int userId,
    required String subject,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final supportMessage = SupportMessageModel(
        userId: userId,
        subject: subject,
        message: message,
      );

      final success = await supportRepository.sendSupportMessage(supportMessage);

      if (success) {
        await fetchUserMessages(userId);
      }

      return success;
    } catch (e) {
      _error = 'فشل إرسال الرسالة';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب رسائل المستخدم
  Future<void> fetchUserMessages(int userId) async {
    try {
      _messages = await supportRepository.getUserMessages(userId);
      notifyListeners();
    } catch (e) {
    }
  }

  /// تجميع الأسئلة حسب الفئة
  Map<String, List<FAQModel>> getFAQsByCategory() {
    final Map<String, List<FAQModel>> categorized = {};

    for (var faq in _faqs) {
      final category = faq.getCategory() ?? 'عام';
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(faq);
    }

    return categorized;
  }

  /// ✅ الاشتراك في تحديثات رسائل الدعم للمستخدم
  void subscribeToUserMessages(int userId) {
    unsubscribeFromSupport();


    _realtimeChannel = _supabase
        .channel('support_messages_user_$userId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'support_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {

        if (payload.eventType == PostgresChangeEvent.insert) {
          // رسالة جديدة
          if (payload.newRecord != null) {
            final newMessage = SupportMessageModel.fromJson(payload.newRecord);
            _messages.insert(0, newMessage);
            notifyListeners();
          }
        } else if (payload.eventType == PostgresChangeEvent.update) {
          // تحديث رسالة (رد من الدعم)
          if (payload.newRecord != null) {
            final updatedMessage = SupportMessageModel.fromJson(payload.newRecord);
            final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
            if (index >= 0) {
              _messages[index] = updatedMessage;
              notifyListeners();
            }
          }
        }
      },
    )
        .subscribe();
  }

  /// ✅ الاشتراك في تحديثات الأسئلة الشائعة
  void subscribeToFAQs() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
    }


    _realtimeChannel = _supabase
        .channel('faqs_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'faqs',
      callback: (payload) {

        // إعادة جلب الأسئلة
        fetchFAQs();
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك
  void unsubscribeFromSupport() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  void clear() {
    _faqs = [];
    _messages = [];
    _error = null;
    unsubscribeFromSupport();
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromSupport();
    super.dispose();
  }
}