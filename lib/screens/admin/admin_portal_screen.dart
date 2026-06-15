import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/models/church.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  late List<Church> _churches;
  late final LocationService _locationService;
  Church? _selectedChurch;
  bool _isCreatingNew = false;

  final _nameController = TextEditingController();
  final _governorateController = TextEditingController();
  final _dioceseController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nextLiturgyController = TextEditingController();
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    _locationService = context.read<LocationService>();
    _churches = _locationService.churches.toList();
    // Listen for updates from LocationService so UI refreshes when data arrives
    _locationService.addListener(_onLocationServiceChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _churches = _locationService.churches.toList();
          if (_churches.isNotEmpty) {
            _setSelectedChurch(_churches.first);
          }
        });
      }
    });
  }

  void _onLocationServiceChanged() {
    if (!mounted) return;
    final updated = _locationService.churches.toList();
    setState(() {
      _churches = updated;
      if (_selectedChurch == null && _churches.isNotEmpty) {
        _setSelectedChurch(_churches.first);
      }
    });
  }

  void _setSelectedChurch(Church? church) {
    setState(() {
      _selectedChurch = church;
      _isCreatingNew = church == null;
      _nameController.text = church?.name ?? '';
      _governorateController.text = church?.governorate ?? '';
      _dioceseController.text = church?.diocese ?? '';
      _addressController.text = church?.address ?? '';
      _phoneController.text = church?.phone ?? '';
      _descriptionController.text = church?.description ?? '';
      _nextLiturgyController.text = church?.nextLiturgy ?? '';
      _isOpen = church?.isOpen ?? true;
    });
  }

  Future<void> _saveChurch() async {
    final name = _nameController.text.trim();
    final governorate = _governorateController.text.trim();
    final diocese = _dioceseController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final description = _descriptionController.text.trim();
    final nextLiturgy = _nextLiturgyController.text.trim();

    if (name.isEmpty ||
        governorate.isEmpty ||
        diocese.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء الحقول الأساسية قبل الحفظ')),
      );
      return;
    }

    final church = Church(
      id:
          _selectedChurch?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      imageUrl: _selectedChurch?.imageUrl ?? '',
      latitude: _selectedChurch?.latitude ?? 0.0,
      longitude: _selectedChurch?.longitude ?? 0.0,
      governorate: governorate,
      diocese: diocese,
      address: address,
      phone: phone,
      isOpen: _isOpen,
      nextLiturgy: nextLiturgy.isEmpty ? 'غير محدد' : nextLiturgy,
      description: description.isEmpty ? 'لا يوجد وصف إضافي.' : description,
      liturgies: _selectedChurch?.liturgies ?? const [],
      meetings: _selectedChurch?.meetings ?? const [],
      services: _selectedChurch?.services ?? const [],
      gallery: _selectedChurch?.gallery ?? const [],
    );

    final locationService = context.read<LocationService>();
    await locationService.saveChurch(church);

    setState(() {
      if (_isCreatingNew || _selectedChurch == null) {
        _churches.insert(0, church);
        _setSelectedChurch(church);
      } else {
        final index = _churches.indexWhere((c) => c.id == _selectedChurch!.id);
        if (index >= 0) {
          _churches[index] = church;
          _setSelectedChurch(church);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCreatingNew ? 'تم إضافة الكنيسة بنجاح' : 'تم تحديث بيانات الكنيسة',
        ),
      ),
    );
  }

  Future<void> _deleteChurch(Church church) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الكنيسة "${church.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _churches.removeWhere((c) => c.id == church.id);
    });

    if (_selectedChurch?.id == church.id) {
      if (_churches.isNotEmpty) {
        _setSelectedChurch(_churches.first);
      } else {
        _setSelectedChurch(null);
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم حذف الكنيسة "${church.name}"')));
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationServiceChanged);
    _nameController.dispose();
    _governorateController.dispose();
    _dioceseController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _nextLiturgyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _AdminCard(
                    label: 'عدد الكنائس',
                    value: _churches.length.toString(),
                    icon: Icons.church,
                    color: AppColors.copticBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AdminCard(
                    label: 'حالة النظام',
                    value: 'نشط',
                    icon: Icons.admin_panel_settings,
                    color: AppColors.copticBurgundy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'تحرير الكنائس',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                itemCount: _churches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final church = _churches[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.church),
                      title: Text(church.name),
                      subtitle: Text(
                        '${church.governorate} • ${church.diocese}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _setSelectedChurch(church),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteChurch(church),
                          ),
                        ],
                      ),
                      onTap: () => _setSelectedChurch(church),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setSelectedChurch(null),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة كنيسة جديدة'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _isCreatingNew ? 'إضافة كنيسة' : 'تعديل كنيسة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الكنيسة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _governorateController,
              decoration: const InputDecoration(labelText: 'المحافظة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dioceseController,
              decoration: const InputDecoration(labelText: 'الأمانة/التقسيم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'الهاتف'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nextLiturgyController,
              decoration: const InputDecoration(labelText: 'القداس التالي'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('الكنيسة مفتوحة'),
              value: _isOpen,
              onChanged: (value) => setState(() => _isOpen = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChurch,
              child: Text(_isCreatingNew ? 'إضافة الكنيسة' : 'حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
