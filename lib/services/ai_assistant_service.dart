import 'package:stitch_smart_church_guide/core/constants/enums.dart';
// Uses runtime church data passed into `respond` instead of demo data.
import 'package:stitch_smart_church_guide/models/ai_message.dart';
import 'package:stitch_smart_church_guide/models/church.dart';
import 'package:stitch_smart_church_guide/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class AiAssistantService {
  final _uuid = const Uuid();

  AiMessage welcomeMessage() {
    return AiMessage(
      id: _uuid.v4(),
      role: AiMessageRole.assistant,
      content:
          'اهلاً! أنا مساعدك الذكي. يمكنني مساعدتك في:\n'
          '• البحث عن أقرب كنيسة\n'
          '• اقتراح اجتماعات مناسبة لك\n'
          '• الإجابة على استفساراتك الروحية والكنسية',
      timestamp: DateTime.now(),
    );
  }

  Future<AiMessage> respond(
    String query,
    UserProfile? profile,
    List<Church> nearbyChurches,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final lower = query.toLowerCase();
    String response;

    if (lower.contains('أقرب') ||
        lower.contains('قريب') ||
        lower.contains('كنيس')) {
      if (nearbyChurches.isEmpty) {
        response =
            'عذراً، لم أتمكن من العثور على كنائس قريبة. تأكد من تفعيل خدمة الموقع.';
      } else {
        final nearest = nearbyChurches.first;
        response =
            'أقرب كنيسة إليك هي "${nearest.name}" على بعد '
            '${nearest.distanceKm?.toStringAsFixed(1) ?? "?"} كم.\n'
            'العنوان: ${nearest.address}\n'
            'القداس القادم: ${nearest.nextLiturgy}';
      }
    } else if (lower.contains('اجتماع') || lower.contains('لقاء')) {
      final category = profile?.category ?? AgeCategory.youth;
      final meetings = nearbyChurches
          .expand((c) => c.meetings.map((m) => (church: c, meeting: m)))
          .where((e) => e.meeting.category == category)
          .take(3)
          .toList();

      if (meetings.isEmpty) {
        response = 'لم أجد اجتماعات مناسبة لفئتك حالياً.';
      } else {
        final buffer = StringBuffer(
          'اقتراحات اجتماعات مناسبة لفئة ${category.label}:\n\n',
        );
        for (final item in meetings) {
          buffer.writeln('• ${item.meeting.title} - ${item.church.name}');
          buffer.writeln('  ${item.meeting.day} الساعة ${item.meeting.time}');
        }
        response = buffer.toString();
      }
    } else if (lower.contains('قداس') || lower.contains('صلاة')) {
      final liturgies = nearbyChurches
          .take(3)
          .map((c) => '• ${c.name}: ${c.nextLiturgy}')
          .join('\n');
      response = 'مواعيد القداسات القادمة:\n$liturgies';
    } else if (lower.contains('حجز') ||
        lower.contains('خلوة') ||
        lower.contains('مؤتمر')) {
      response =
          'يمكنك حجز المؤتمرات والرحلات والخلوات من قسم "الحجز" في التطبيق.\n'
          'بعد الحجز ستحصل على رمز QR للتأكيد.';
    } else if (lower.contains('دير') || lower.contains('أديرة')) {
      response = 'راجع قسم الأديرة في التطبيق للاطلاع على الأديرة والمتاح.';
    } else {
      response =
          'شكراً لسؤالك! يمكنني مساعدتك في:\n'
          '• "أين أقرب كنيسة؟"\n'
          '• "اقترح اجتماعات لي"\n'
          '• "مواعيد القداسات"\n'
          '• "كيف أحجز خلوة؟"';
    }

    return AiMessage(
      id: _uuid.v4(),
      role: AiMessageRole.assistant,
      content: response,
      timestamp: DateTime.now(),
    );
  }
}
