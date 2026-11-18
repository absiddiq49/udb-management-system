import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/citizen_tip.dart';
import '../../providers/request_provider.dart';
import '../../core/utils/file_import_service.dart';
import '../widgets/contact_action_pill.dart';

class CitizenTipDialog extends StatefulWidget {
  final String bodyReference;

  const CitizenTipDialog({super.key, required this.bodyReference});

  @override
  State<CitizenTipDialog> createState() => _CitizenTipDialogState();
}

class _CitizenTipDialogState extends State<CitizenTipDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationController = TextEditingController();
  final _missingPersonController = TextEditingController();
  final _gdController = TextEditingController();
  final _thanaController = TextEditingController();
  final _reasonsController = TextEditingController();
  bool _submitted = false;
  PickedImageFile? _attachedPhoto;

  Future<void> _handlePickPhoto() async {
    final picked = await pickImageFromDevice();
    if (picked != null) {
      setState(() => _attachedPhoto = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationController.dispose();
    _missingPersonController.dispose();
    _gdController.dispose();
    _thanaController.dispose();
    _reasonsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final tip = CitizenTip(
        id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
        bodyReference: widget.bodyReference,
        claimantName: _nameController.text.trim(),
        claimantPhone: _phoneController.text.trim(),
        claimantEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        relationshipToMissing: _relationController.text.trim(),
        missingPersonName: _missingPersonController.text.trim(),
        missingPersonGd: _gdController.text.trim(),
        thanaFiled: _thanaController.text.trim(),
        similarityReasons: _reasonsController.text.trim(),
        submittedAt: 'Just now',
      );

      context.read<RequestProvider>().submitCitizenTip(tip);
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

    return Dialog(
      backgroundColor: cardBg,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _submitted
              ? _buildSuccessView(textPri, textSec)
              : _buildFormView(textPri, textSec),
        ),
      ),
    );
  }

  Widget _buildFormView(Color textPri, Color textSec) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.record_voice_over_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit Identification Lead / Tip',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Target Case: ${widget.bodyReference}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textSec, size: 20),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'If you believe this unidentified deceased individual could be your missing family member, please share relevant details. A CID investigation officer will review this lead with highest priority.',
              style: TextStyle(color: textSec, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Your Full Name *', hintText: 'Enter your name'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Contact Phone Number *', hintText: '01XXXXXXXXX'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _relationController,
                    decoration: const InputDecoration(labelText: 'Relationship *', hintText: 'e.g. Brother, Father'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _missingPersonController,
                    decoration: const InputDecoration(labelText: 'Missing Person Name *', hintText: 'Full name'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gdController,
                    decoration: const InputDecoration(labelText: 'Thana GD / FIR Number', hintText: 'GD No. & Year'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _thanaController,
                    decoration: const InputDecoration(labelText: 'Police Station / Thana', hintText: 'Thana name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _reasonsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Why do you believe this is a match? *',
                hintText: 'Describe matching marks, scars, tattoos, dental work, clothing, height, or circumstances...',
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'Please provide matching reasons' : null,
            ),
            const SizedBox(height: 14),
            // Attached Photo for Verification
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? AppColors.slate100 : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supporting Photo (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Attach a photo of the missing person, previous medical scars, or clothing for verification.',
                    style: TextStyle(fontSize: 11, color: AppColors.slate500),
                  ),
                  const SizedBox(height: 10),
                  if (_attachedPhoto != null)
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            _attachedPhoto!.dataUrl,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _attachedPhoto!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                              ),
                              Text(
                                _attachedPhoto!.humanSize,
                                style: const TextStyle(color: AppColors.slate500, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.red),
                          onPressed: () => setState(() => _attachedPhoto = null),
                          tooltip: 'Remove photo',
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _handlePickPhoto,
                      icon: const Icon(Icons.file_upload_outlined, size: 15),
                      label: const Text('Import Photo from Device / Gallery', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primaryBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded, size: 15),
                  label: const Text('Submit Tip to CID'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(Color textPri, Color textSec) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: AppColors.greenLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 48),
        ),
        const SizedBox(height: 18),
        Text(
          'Lead Submitted Successfully',
          style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          'Your tip for Case ${widget.bodyReference} has been transmitted to the CID CIB Desk. '
          'An assigned investigating officer will verify the General Diary details and contact you at ${_phoneController.text.trim()}.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSec, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            const ContactActionPill.phone(
              label: 'Emergency: 999',
              target: '999',
              isEmergency: true,
            ),
            ContactActionPill.phone(
              label: 'CID Desk: ${AppConstants.cidHelpline}',
              target: AppConstants.cidHelpline,
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          ),
          child: const Text('Return to Dossier'),
        ),
      ],
    );
  }
}

