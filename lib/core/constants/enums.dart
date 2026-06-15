import 'package:flutter/material.dart';

enum AgeCategory {
  nursery('حضانة', 'child_care'),
  primary('ابتدائي', 'school'),
  preparatory('إعدادي', 'menu_book'),
  secondary('ثانوي', 'auto_stories'),
  university('جامعي', 'school_outlined'),
  youth('شباب', 'groups'),
  families('أسر', 'family_restroom'),
  servants('خدام', 'volunteer_activism');

  const AgeCategory(this.label, this.iconName);
  final String label;
  final String iconName;
}

enum BookingType {
  conference('مؤتمر', Icons.event),
  trip('رحلة', Icons.directions_bus),
  retreat('خلوة', Icons.nature_people);

  const BookingType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum NotificationType {
  liturgy('تذكير بالقداس', Icons.church),
  meeting('تذكير بالاجتماع', Icons.groups),
  event('فعالية جديدة', Icons.celebration);

  const NotificationType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum ChurchService {
  nursery('حضانة'),
  scouting('كشافة'),
  choir('كورال'),
  library('مكتبة'),
  sports('ملاعب'),
  hall('قاعة مناسبات'),
  specialNeeds('خدمة ذوي الاحتياجات الخاصة'),
  clinic('عيادة');

  const ChurchService(this.label);
  final String label;
}

enum LiturgyType {
  liturgy('القداس'),
  vespers('العشية'),
  praise('التسبحة');

  const LiturgyType(this.label);
  final String label;
}
