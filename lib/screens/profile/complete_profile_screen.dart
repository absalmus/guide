import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/enums.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';
import 'package:stitch_smart_church_guide/widgets/category_chip.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _governorate;
  String? _churchId;
  AgeCategory _category = AgeCategory.youth;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthService>().currentProfile;
    if (profile != null) {
      _nameController.text = profile.name;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _governorate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم والمحافظة')),
      );
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final current = auth.currentProfile;
    if (current == null) return;

    final updated = current.copyWith(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text),
      governorate: _governorate,
      churchId: _churchId,
      category: _category,
      profileComplete: true,
    );

    await auth.updateProfile(updated);
    if (mounted) {
      setState(() => _loading = false);
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استكمال الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أخبرنا عنك',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'لتخصيص المحتوى حسب فئتك العمرية',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'العمر',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final governorates = context
                    .watch<LocationService>()
                    .availableGovernorates;
                if (governorates.isEmpty) {
                  return TextField(
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'المحافظة',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: (value) => setState(
                      () => _governorate = value.trim().isEmpty
                          ? null
                          : value.trim(),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  initialValue: _governorate,
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: governorates
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _governorate = v),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _churchId,
              decoration: const InputDecoration(
                labelText: 'الكنيسة التابعة (اختياري)',
                prefixIcon: Icon(Icons.church),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('— لا شيء —')),
                ...context
                    .watch<LocationService>()
                    .churches
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
              ],
              onChanged: (v) => setState(() => _churchId = v),
            ),
            const SizedBox(height: 24),
            Text(
              'الفئة العمرية',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AgeCategory.values.map((cat) {
                return CategoryChip(
                  category: cat,
                  selected: _category == cat,
                  onTap: () => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('حفظ والمتابعة'),
            ),
          ],
        ),
      ),
    );
  }
}
