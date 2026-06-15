import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stitch_smart_church_guide/core/constants/app_constants.dart';
import 'package:stitch_smart_church_guide/core/constants/enums.dart';
import 'package:stitch_smart_church_guide/models/booking.dart';
import 'package:stitch_smart_church_guide/providers/booking_provider.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BookingType _type = BookingType.retreat;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _adminEmailController = TextEditingController(text: kAdminEmail);
  String? _churchName;
  DateTime _date = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthService>().currentProfile?.id ?? 'guest';
    context.read<BookingProvider>().loadUserBookings(userId);
  }

  Future<void> _createBooking() async {
    if (_titleController.text.isEmpty || _churchName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }

    final userId = context.read<AuthService>().currentProfile?.id ?? 'guest';
    final booking = await context.read<BookingProvider>().createBooking(
      userId: userId,
      title: _titleController.text,
      type: _type,
      churchName: _churchName!,
      date: _date,
      location: _locationController.text.isNotEmpty
          ? _locationController.text
          : _churchName!,
      adminEmail: _adminEmailController.text.trim().isNotEmpty
          ? _adminEmailController.text.trim()
          : null,
    );

    if (mounted) context.push('/booking-qr/${booking.id}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingProvider>().bookings;
    final locationService = context.watch<LocationService>();
    final nearestChurches = locationService
        .churchesWithDistance()
        .take(8)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('نظام التذكير')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تذكير جديد', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<BookingType>(
              segments: BookingType.values
                  .map(
                    (t) => ButtonSegment(
                      value: t,
                      label: Text(t.label),
                      icon: Icon(t.icon),
                    ),
                  )
                  .toList(),
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'عنوان ${_type.label}',
                prefixIcon: Icon(_type.icon),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _adminEmailController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني للإدارة',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك التواصل مع الإدارة عبر admin@smartchurch.org',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _churchName,
              decoration: const InputDecoration(
                labelText: 'اختر الكنيسة الأقرب',
                prefixIcon: Icon(Icons.church),
              ),
              items: nearestChurches
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.name,
                      child: Text(
                        '${c.name} - ${c.distanceKm?.toStringAsFixed(1) ?? '?'} كم',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _churchName = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'عنوان المكان (اختياري)',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('التاريخ'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createBooking,
              child: const Text('تأكيد التذكير'),
            ),
            const SizedBox(height: 32),
            Text('تذكيراتي', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...bookings.map((b) => _BookingListTile(booking: b)),
          ],
        ),
      ),
    );
  }
}

class _BookingListTile extends StatelessWidget {
  const _BookingListTile({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(booking.type.icon),
        title: Text(booking.title),
        subtitle: Text(
          '${booking.churchName} - ${booking.date.day}/${booking.date.month}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.qr_code),
          onPressed: () => context.push('/booking-qr/${booking.id}'),
        ),
      ),
    );
  }
}

class BookingQrScreen extends StatelessWidget {
  const BookingQrScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final booking = context
        .watch<BookingProvider>()
        .bookings
        .cast<Booking?>()
        .firstWhere((b) => b!.id == bookingId, orElse: () => null);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('التذكير غير موجود')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('رمز التذكير')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: booking.qrCode,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                booking.title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(booking.churchName),
              Text(
                '${booking.type.label} - ${booking.date.day}/${booking.date.month}/${booking.date.year}',
              ),
              const SizedBox(height: 16),
              Text(
                booking.qrCode,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
