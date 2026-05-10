import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/lost_found_item.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';
import '../common/async_state_view.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key, this.openPost = false});

  final bool openPost;

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _filter = 'Newest';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    if (widget.openPost) WidgetsBinding.instance.addPostFrameCallback((_) => _openPostSheet());
  }

  Future<void> _openPostSheet() async {
    await showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const _PostItemSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(AppColors.primaryDeeper),
        onPressed: _openPostSheet,
        icon: const Icon(Icons.add),
        label: const Text('Post Item'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: TabBar(
                controller: _tab,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(color: const Color(AppColors.primaryDeeper), borderRadius: BorderRadius.circular(8)),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(AppColors.textSecondary),
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Lost'), Tab(text: 'Found')],
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: ['Newest', 'Nearest', 'Category'].map((chip) {
                final selected = _filter == chip;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = chip),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: TabBarView(controller: _tab, children: const [_LostFoundList(type: 'lost'), _LostFoundList(type: 'found')])),
        ],
      ),
    );
  }
}

class _LostFoundList extends StatelessWidget {
  const _LostFoundList({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LostFoundItem>>(
      stream: context.read<FirestoreService>().lostFound(type),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return AsyncStateView(
          connectionState: snapshot.connectionState,
          hasError: snapshot.hasError,
          errorMessage: snapshot.error?.toString(),
          isEmpty: items.isEmpty,
          emptyMessage: 'No items yet. Tap Post Item to add one.',
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = items[i];
              return SectionCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(item.imageUrl!, width: 58, height: 58, fit: BoxFit.cover)
                          : Container(width: 58, height: 58, color: const Color(0xFFF3F4F6), child: const Icon(Icons.image_outlined)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(item.location, style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
                          Text(DateFormat('h:mm a').format(item.createdAt), style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert_rounded),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PostItemSheet extends StatefulWidget {
  const _PostItemSheet();

  @override
  State<_PostItemSheet> createState() => _PostItemSheetState();
}

class _PostItemSheetState extends State<_PostItemSheet> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'lost';
  final _category = TextEditingController();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _contact = TextEditingController();
  XFile? _image;
  bool _posting = false;

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _posting = true);

    try {
      final service = context.read<FirestoreService>();
      String? url;
      if (_image != null) url = await service.uploadImage(_image!, 'lost_found_images');
      await service.createLostFound(LostFoundItem(
        id: '',
        userId: context.read<AuthService>().currentUser?.uid ?? 'guest',
        category: _category.text.trim(),
        title: _title.text.trim(),
        description: _desc.text.trim(),
        location: _location.text.trim(),
        contact: _contact.text.trim(),
        type: _type,
        imageUrl: url,
        createdAt: DateTime.now(),
      ));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Post Item', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [ButtonSegment(value: 'lost', label: Text('Lost')), ButtonSegment(value: 'found', label: Text('Found'))],
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _category, validator: (v) => Validators.requiredField(v, 'Category'), decoration: const InputDecoration(hintText: 'Select Category')),
              const SizedBox(height: 8),
              TextFormField(controller: _title, validator: (v) => Validators.requiredField(v, 'Title'), decoration: const InputDecoration(hintText: 'Enter title')),
              const SizedBox(height: 8),
              TextFormField(controller: _desc, maxLines: 3, validator: (v) => Validators.requiredField(v, 'Description'), decoration: const InputDecoration(hintText: 'Provide description...')),
              const SizedBox(height: 8),
              TextFormField(controller: _location, validator: (v) => Validators.requiredField(v, 'Location'), decoration: const InputDecoration(hintText: 'Location')),
              const SizedBox(height: 8),
              TextFormField(controller: _contact, validator: (v) => Validators.requiredField(v, 'Contact information'), decoration: const InputDecoration(hintText: 'Enter your phone or email')),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxHeight: 1200, maxWidth: 1200);
                  if (file != null) setState(() => _image = file);
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(120, 110)),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(_image?.name ?? 'Add Photo'),
              ),
              const SizedBox(height: 12),
              AppButton(label: _posting ? 'Posting...' : 'Post Item', onPressed: _posting ? null : _post),
            ],
          ),
        ),
      ),
    );
  }
}
