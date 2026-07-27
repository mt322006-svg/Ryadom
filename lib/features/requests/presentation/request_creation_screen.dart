import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../../theme/ryadom_buttons.dart';
import '../../../theme/ryadom_tokens.dart';
import '../../../widgets/ryadom_form_widgets.dart';
import '../../../widgets/ryadom_surface_card.dart';

import '../domain/help_request.dart';

class RequestCreationScreen extends StatefulWidget {
  const RequestCreationScreen({
    super.key,
    this.initialAreaLabel,
    this.initialLatitude,
    this.initialLongitude,
  });

  final String? initialAreaLabel;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<RequestCreationScreen> createState() => _RequestCreationScreenState();
}

class _RequestCreationScreenState extends State<RequestCreationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final TextEditingController _locationController;

  RequestUrgency _urgency = RequestUrgency.normal;
  RequestCompensation _compensation = RequestCompensation.free;
  _TimeOption _timeOption = _TimeOption.now;
  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.initialAreaLabel ?? '',
    );
    _titleController.addListener(_refreshPreview);
    _descriptionController.addListener(_refreshPreview);
    _locationController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _titleController.removeListener(_refreshPreview);
    _descriptionController.removeListener(_refreshPreview);
    _locationController.removeListener(_refreshPreview);
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  void _publishRequest() {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final areaLabel = _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requestTitleRequired),
        ),
      );
      return;
    }

    final request = HelpRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description.isEmpty
          ? l10n.requestDefaultDescription
          : description,
      compensation: _compensation,
      areaLabel: areaLabel.isEmpty ? l10n.requestDefaultArea : areaLabel,
      timeLabel: _timeLabel(_timeOption, l10n),
      urgency: _urgency,
      status: RequestStatus.visible,
      responseCount: 0,
      isOwnRequest: true,
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
    );

    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.needHelpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            RyadomTokens.screenPadding,
            8,
            RyadomTokens.screenPadding,
            28,
          ),
          children: [
            Text(
              l10n.requestCreationIntro,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            RyadomSectionHeader(
              title: l10n.requestWhatTitle,
              subtitle: l10n.requestWhatSubtitle,
            ),
            RyadomTextFieldCard(
              controller: _titleController,
              hintText: l10n.requestWhatHint,
              maxLines: 2,
            ),
            const SizedBox(height: RyadomTokens.sectionGap),
            RyadomSectionHeader(
              title: l10n.requestContextTitle,
              subtitle: l10n.requestContextSubtitle,
            ),
            RyadomTextFieldCard(
              controller: _descriptionController,
              hintText: l10n.requestContextHint,
              maxLines: 4,
            ),
            const SizedBox(height: RyadomTokens.sectionGap),
            RyadomChoiceRow<_TimeOption>(
              title: l10n.requestWhenTitle,
              subtitle: l10n.requestWhenSubtitle,
              value: _timeOption,
              options: [
                RyadomChoiceOption(_TimeOption.now, l10n.requestWhenNow),
                RyadomChoiceOption(
                  _TimeOption.withinHour,
                  l10n.requestWhenWithinHour,
                ),
                RyadomChoiceOption(_TimeOption.today, l10n.requestWhenToday),
              ],
              onChanged: (value) => setState(() => _timeOption = value),
            ),
            const SizedBox(height: RyadomTokens.sectionGap),
            RyadomSectionHeader(
              title: l10n.requestWhereTitle,
              subtitle: l10n.requestWhereSubtitle,
            ),
            RyadomTextFieldCard(
              controller: _locationController,
              hintText: l10n.requestWhereHint,
              maxLines: 2,
            ),
            if (widget.initialLatitude != null && widget.initialLongitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.requestWherePrivacy,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: RyadomTokens.sectionGap),
            RyadomChoiceRow<RequestUrgency>(
              title: l10n.requestUrgencyTitle,
              subtitle: l10n.requestUrgencySubtitle,
              value: _urgency,
              options: [
                RyadomChoiceOption(
                  RequestUrgency.low,
                  l10n.urgencyLabel(RequestUrgency.low),
                ),
                RyadomChoiceOption(
                  RequestUrgency.normal,
                  l10n.urgencyLabel(RequestUrgency.normal),
                ),
                RyadomChoiceOption(
                  RequestUrgency.urgent,
                  l10n.urgencyLabel(RequestUrgency.urgent),
                ),
              ],
              onChanged: (value) => setState(() => _urgency = value),
            ),
            const SizedBox(height: RyadomTokens.sectionGap),
            RyadomChoiceRow<RequestCompensation>(
              title: l10n.requestPaymentTitle,
              subtitle: l10n.requestPaymentSubtitle,
              value: _compensation,
              options: [
                RyadomChoiceOption(
                  RequestCompensation.free,
                  l10n.compensationActionLabel(RequestCompensation.free),
                ),
                RyadomChoiceOption(
                  RequestCompensation.paid,
                  l10n.compensationActionLabel(RequestCompensation.paid),
                ),
              ],
              onChanged: (value) => setState(() => _compensation = value),
            ),
            const SizedBox(height: 20),
            RyadomSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.requestPreviewTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _titleController.text.isEmpty
                        ? l10n.requestPreviewTitlePlaceholder
                        : _titleController.text,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _descriptionController.text.isEmpty
                        ? l10n.requestPreviewDescriptionPlaceholder
                        : _descriptionController.text,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PreviewChip(label: _timeLabel(_timeOption, l10n)),
                      _PreviewChip(label: _urgencyLabel(_urgency, l10n)),
                      _PreviewChip(
                        label: _compensationLabel(_compensation, l10n),
                      ),
                      _PreviewChip(label: _locationController.text),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RyadomGlassButton(
              label: l10n.requestPublish,
              onPressed: _publishRequest,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

enum _TimeOption { now, withinHour, today }

String _timeLabel(_TimeOption option, AppLocalizations l10n) {
  switch (option) {
    case _TimeOption.now:
      return l10n.requestWhenNow;
    case _TimeOption.withinHour:
      return l10n.requestWhenWithinHour;
    case _TimeOption.today:
      return l10n.requestWhenToday;
  }
}

String _urgencyLabel(RequestUrgency urgency, AppLocalizations l10n) {
  return l10n.urgencyLabel(urgency);
}

String _compensationLabel(
  RequestCompensation compensation,
  AppLocalizations l10n,
) {
  return l10n.compensationActionLabel(compensation);
}