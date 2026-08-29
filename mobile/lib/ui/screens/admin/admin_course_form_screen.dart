import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/course.dart';
import '../../../data/models/enums.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_cover.dart';
import '../../widgets/section_header.dart';

/// Create or edit a course. Pops with `true` when something was saved.
class AdminCourseFormScreen extends StatefulWidget {
  const AdminCourseFormScreen({super.key, this.course});

  final Course? course;

  @override
  State<AdminCourseFormScreen> createState() => _AdminCourseFormScreenState();
}

class _AdminCourseFormScreenState extends State<AdminCourseFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _title =
      TextEditingController(text: widget.course?.title ?? '');
  late final TextEditingController _slug =
      TextEditingController(text: widget.course?.slug ?? '');
  late final TextEditingController _summary =
      TextEditingController(text: widget.course?.summary ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.course?.description ?? '');
  late final TextEditingController _instructor =
      TextEditingController(text: widget.course?.instructorName ?? '');
  late final TextEditingController _price =
      TextEditingController(text: '${widget.course?.price ?? 0}');
  late final TextEditingController _weeks =
      TextEditingController(text: '${widget.course?.durationWeeks ?? 4}');

  late String _category = widget.course?.category ?? 'ict';
  late CourseLevel _level = widget.course?.level ?? CourseLevel.beginner;
  late String _cover = widget.course?.coverGradient ?? 'mint';
  late bool _published = widget.course?.isPublished ?? false;
  late DeliveryMode _delivery =
      widget.course?.deliveryMode ?? DeliveryMode.inPerson;
  bool _busy = false;

  bool get _isEdit => widget.course != null;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      _title.addListener(_syncSlug);
    }
  }

  void _syncSlug() {
    _slug.text = _slugify(_title.text);
  }

  static String _slugify(String input) => input
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-');

  @override
  void dispose() {
    _title.removeListener(_syncSlug);
    _title.dispose();
    _slug.dispose();
    _summary.dispose();
    _description.dispose();
    _instructor.dispose();
    _price.dispose();
    _weeks.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);

    final AdminProvider admin = context.read<AdminProvider>();
    final String? error;

    if (_isEdit) {
      error = await admin.updateCourse(widget.course!.id, <String, dynamic>{
        'title': _title.text.trim(),
        'slug': _slug.text.trim(),
        'summary': _summary.text.trim(),
        'description': _description.text.trim(),
        'category': _category,
        'level': _level.api,
        'price': int.tryParse(_price.text.trim()) ?? 0,
        'durationWeeks': int.tryParse(_weeks.text.trim()) ?? 4,
        'instructorName': _instructor.text.trim(),
        'coverGradient': _cover,
        'isPublished': _published,
        'deliveryMode': _delivery.api,
      });
    } else {
      error = await admin.createCourse(<String, dynamic>{
        'title': _title.text.trim(),
        'slug': _slug.text.trim(),
        'summary': _summary.text.trim(),
        'description': _description.text.trim(),
        'category': _category,
        'level': _level,
        'price': int.tryParse(_price.text.trim()) ?? 0,
        'durationWeeks': int.tryParse(_weeks.text.trim()) ?? 4,
        'instructorName': _instructor.text.trim(),
        'coverGradient': _cover,
        'isPublished': _published,
        'deliveryMode': _delivery,
      });
    }

    if (!mounted) return;
    setState(() => _busy = false);

    if (error == null) {
      AppSnack.success(
        context,
        _isEdit ? 'Course updated.' : 'Course created.',
      );
      Navigator.of(context).pop(true);
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit course' : 'New course'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          children: <Widget>[
            GradientCover(
              gradientKey: _cover,
              height: 96,
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Title',
              controller: _title,
              hint: 'e.g. Web Development Fundamentals',
              textCapitalizationWords: true,
              validator: (String? v) =>
                  Validators.minLength(v, 3, field: 'Title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Slug',
              controller: _slug,
              hint: 'web-development-fundamentals',
              helper: 'Used in the web address. Lowercase, dashes only.',
              validator: (String? v) =>
                  Validators.required(v, field: 'Slug'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Summary',
              controller: _summary,
              hint: 'One line shown on the course card',
              maxLines: 2,
              minLines: 2,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              controller: _description,
              hint: 'Full description shown on the course page',
              maxLines: 6,
              minLines: 4,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Instructor',
              controller: _instructor,
              hint: 'Who teaches this?',
              textCapitalizationWords: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: 'Price (TSh)',
                    controller: _price,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    helper: '0 = free',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Duration (weeks)',
                    controller: _weeks,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Classification'),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CourseCategories.keys
                  .map(
                    (String key) => ChoiceChip(
                      label: Text(CourseCategories.label(key)),
                      selected: _category == key,
                      onSelected: (_) => setState(() => _category = key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text(
              'Level',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: CourseLevel.values
                  .map(
                    (CourseLevel l) => ChoiceChip(
                      label: Text(l.label),
                      selected: _level == l,
                      onSelected: (_) => setState(() => _level = l),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text(
              'Delivery',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'In-person courses can be paid for inside the iPhone app. '
              'Online courses cannot - Apple requires its own in-app purchase '
              'for content delivered in the app, so those students reserve a '
              'place and pay elsewhere.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: context.mutedColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: DeliveryMode.values
                  .map(
                    (DeliveryMode m) => ChoiceChip(
                      label: Text(m.label),
                      selected: _delivery == m,
                      onSelected: (_) => setState(() => _delivery = m),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text(
              'Cover colour',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <String>['mint', 'peach', 'lavender', 'sky', 'rose']
                  .map(
                    (String key) => ChoiceChip(
                      label: Text(key),
                      selected: _cover == key,
                      onSelected: (_) => setState(() => _cover = key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: SwitchListTile(
                value: _published,
                onChanged: (bool v) => setState(() => _published = v),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Published',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: context.inkColor,
                  ),
                ),
                subtitle: Text(
                  'Visible in the public catalogue and in the app.',
                  style:
                      TextStyle(fontSize: 12.5, color: context.mutedColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isEdit ? 'Save changes' : 'Create course',
              busy: _busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
