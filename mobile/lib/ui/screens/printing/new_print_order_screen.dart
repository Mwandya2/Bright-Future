import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/print_order.dart';
import '../../../providers/print_order_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_header.dart';

class NewPrintOrderScreen extends StatefulWidget {
  const NewPrintOrderScreen({super.key});

  @override
  State<NewPrintOrderScreen> createState() => _NewPrintOrderScreenState();
}

class _NewPrintOrderScreenState extends State<NewPrintOrderScreen> {
  ServiceType _service = ServiceType.document;
  final TextEditingController _description = TextEditingController();
  final TextEditingController _copies = TextEditingController(text: '1');
  bool _color = false;
  bool _busy = false;
  String? _filePath;
  String? _fileName;

  @override
  void dispose() {
    _description.dispose();
    _copies.dispose();
    super.dispose();
  }

  int get _copyCount {
    final int parsed = int.tryParse(_copies.text.trim()) ?? 1;
    return parsed < 1 ? 1 : parsed;
  }

  int get _estimate => PrintOrder.estimate(
        serviceType: _service,
        copies: _copyCount,
        color: _color,
      );

  Future<void> _pickFile() async {
    try {
      // file_picker 12 replaced the FilePickerResult wrapper: pickFile returns
      // the single PlatformFile directly, or null when the user backs out.
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: <String>[
          'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx',
          'jpg', 'jpeg', 'png', 'txt',
        ],
      );
      if (file == null || file.path == null) return;
      setState(() {
        _filePath = file.path;
        _fileName = file.name;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      AppSnack.error(context, 'Could not open the file picker. ${e.message}');
    } catch (_) {
      if (!mounted) return;
      AppSnack.error(context, 'Could not open the file picker.');
    }
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final String? warning = await context.read<PrintOrderProvider>().create(
          serviceType: _service,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          copies: _copyCount,
          color: _color,
          filePath: _filePath,
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (warning == null) {
      AppSnack.success(context, 'Order submitted. We will let you know when it is ready.');
      Navigator.of(context).pop();
    } else if (warning.startsWith('Order submitted')) {
      AppSnack.info(context, warning);
      Navigator.of(context).pop();
    } else {
      AppSnack.error(context, warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New print order')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: <Widget>[
          const SectionHeader(
            title: 'What are we printing?',
            subtitle: 'Pricing updates as you choose',
          ),
          ...ServiceTypeX.all.map(
            (ServiceType s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => setState(() => _service = s),
                borderColor: _service == s ? AppColors.primary : null,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _service == s
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: _service == s
                          ? AppColors.primary
                          : context.mutedColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: context.inkColor,
                        ),
                      ),
                    ),
                    Text(
                      'from ${Fmt.money(s.unitPrice)}',
                      style:
                          TextStyle(fontSize: 12.5, color: context.mutedColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Details'),
          AppTextField(
            label: 'Description',
            controller: _description,
            hint: 'e.g. 12-page report, A4, double sided',
            maxLines: 3,
            minLines: 2,
            maxLength: 300,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Number of copies',
            controller: _copies,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            prefixIcon: Icons.numbers_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: SwitchListTile(
              value: _color,
              onChanged: (bool v) => setState(() => _color = v),
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Full colour',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: context.inkColor,
                ),
              ),
              subtitle: Text(
                'Colour printing costs 1.5x the black & white rate.',
                style: TextStyle(fontSize: 12.5, color: context.mutedColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Attachment ──────────────────────────────────────
          AppCard(
            onTap: _pickFile,
            child: Row(
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.softBg(
                      AppColors.primary,
                      dark: context.isDark,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.attach_file_rounded,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _fileName ?? 'Attach your file (optional)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.inkColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fileName == null
                            ? 'PDF, Word, PowerPoint, Excel or an image'
                            : 'Tap to choose a different file',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_fileName != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(() {
                      _filePath = null;
                      _fileName = null;
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Estimate ────────────────────────────────────────
          AppCard(
            color: context.softCanvas,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Estimated price',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.mutedColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        Fmt.money(_estimate),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: context.inkColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    '$_copyCount x ${Fmt.money(_service.unitPrice)}'
                    '${_color ? ' x 1.5 colour' : ''}',
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontSize: 12, color: context.mutedColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The hub confirms the final price when the job is prepared.',
            style: TextStyle(fontSize: 12, color: context.mutedColor),
          ),
          const SizedBox(height: 22),
          AppButton(
            label: 'Submit order',
            busy: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
