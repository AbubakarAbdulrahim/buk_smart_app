import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/incident.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _types = const [
    ('Insecurity', Icons.shield_rounded, Color(0xFFFDECEE), Color(0xFFE63946)),
    ('Theft', Icons.security_rounded, Color(0xFFFFF4EC), Color(0xFFEB7A32)),
    ('Emergency', Icons.crisis_alert_rounded, Color(0xFFFDECEE), Color(0xFFE63946)),
    ('Power Outage', Icons.bolt_rounded, Color(0xFFFFF7E8), Color(0xFFF5A623)),
    ('Water Outage', Icons.water_drop_rounded, Color(0xFFEDF5FF), Color(0xFF2F80ED)),
  ];

  final _desc = TextEditingController();
  final _location = TextEditingController(text: 'New Site, BUK');
  int _step = 0;
  String _type = 'Insecurity';
  XFile? _image;
  bool _submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _step = 1);
      return;
    }
    setState(() => _submitting = true);
    final firestore = context.read<FirestoreService>();
    final uid = context.read<AuthService>().currentUser?.uid ?? 'guest';

    try {
      String? url;
      if (_image != null) {
        url = await firestore.uploadImage(_image!, 'incident_images');
      }
      await firestore.createIncident(Incident(
        id: '',
        userId: uid,
        type: _type,
        description: _desc.text.trim(),
        location: _location.text.trim(),
        imageUrl: url,
        createdAt: DateTime.now(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
      setState(() {
        _step = 0;
        _desc.clear();
        _image = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        leading: _step > 0
            ? IconButton(
                onPressed: () => setState(() => _step--),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_step + 1) / 3,
                      borderRadius: BorderRadius.circular(100),
                      color: const Color(AppColors.primaryDeeper),
                      backgroundColor: const Color(0xFFE5E7EB),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Step ${_step + 1} of 3', style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary))),
                ]),
                const SizedBox(height: 16),
                Expanded(child: _buildStep()),
                AppButton(
                  label: _submitting ? 'Please wait...' : (_step < 2 ? 'Next' : 'Submit Report'),
                  onPressed: _submitting
                      ? null
                      : () {
                          if (_step < 2) {
                            if (_step == 1 && !_formKey.currentState!.validate()) return;
                            setState(() => _step++);
                          } else {
                            _submit();
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 0) {
      return ListView(
        children: [
          const Text('What are you reporting?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30)),
          const SizedBox(height: 6),
          const Text('Select the type of incident', style: TextStyle(color: Color(AppColors.textSecondary))),
          const SizedBox(height: 14),
          ..._types.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _type = t.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: t.$3,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _type == t.$1 ? const Color(AppColors.primaryDeeper) : Colors.transparent),
                    ),
                    child: Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(t.$2, size: 18, color: t.$4)),
                      const SizedBox(width: 12),
                      Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              )),
        ],
      );
    }
    if (_step == 1) {
      return ListView(
        children: [
          const Text('Provide more details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30)),
          const SizedBox(height: 6),
          const Text('Please provide as much information as possible', style: TextStyle(color: Color(AppColors.textSecondary))),
          const SizedBox(height: 16),
          TextFormField(
            controller: _desc,
            maxLines: 4,
            validator: (value) => Validators.requiredField(value, 'Description'),
            decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe what happened...'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _location,
            validator: (value) => Validators.requiredField(value, 'Location'),
            decoration: const InputDecoration(labelText: 'Location', hintText: 'Location'),
          ),
          const SizedBox(height: 12),
          const Text('Upload Photos (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1200, maxHeight: 1200);
              if (file != null) setState(() => _image = file);
            },
            style: OutlinedButton.styleFrom(minimumSize: const Size(110, 110)),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_image == null ? 'Add Photo' : 'Photo Added'),
          ),
        ],
      );
    }

    return ListView(
      children: [
        const Text('Review & Confirm', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30)),
        const SizedBox(height: 6),
        const Text('Please review your report before submitting', style: TextStyle(color: Color(AppColors.textSecondary))),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Type', _type),
              const Divider(height: 22),
              _row('Location', _location.text),
              const Divider(height: 22),
              _row('Description', _desc.text.isEmpty ? 'No description' : _desc.text),
              const Divider(height: 22),
              _row('Photo', _image?.name ?? 'None'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Color(AppColors.textSecondary)))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }
}
