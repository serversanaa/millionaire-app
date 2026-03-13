// lib/features/support/domain/models/faq_model.dart

class FAQModel {
  final int id;
  final String question;
  final String questionAr;
  final String answer;
  final String answerAr;
  final String? category;
  final String? categoryAr;
  final int displayOrder;
  final bool isActive;

  FAQModel({
    required this.id,
    required this.question,
    required this.questionAr,
    required this.answer,
    required this.answerAr,
    this.category,
    this.categoryAr,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'] as int,
      question: json['question'] as String,
      questionAr: json['question_ar'] as String,
      answer: json['answer'] as String,
      answerAr: json['answer_ar'] as String,
      category: json['category'] as String?,
      categoryAr: json['category_ar'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String getQuestion() => questionAr.isNotEmpty ? questionAr : question;
  String getAnswer() => answerAr.isNotEmpty ? answerAr : answer;
  String? getCategory() => categoryAr ?? category;
}
