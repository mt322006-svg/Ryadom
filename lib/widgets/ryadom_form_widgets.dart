import 'package:flutter/material.dart';

import '../theme/ryadom_buttons.dart';
import '../theme/ryadom_tokens.dart';
import 'ryadom_surface_card.dart';

class RyadomSectionHeader extends StatelessWidget {
  const RyadomSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: RyadomTokens.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class RyadomTextFieldCard extends StatelessWidget {
  const RyadomTextFieldCard({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return RyadomSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}

class RyadomChoiceRow<T> extends StatelessWidget {
  const RyadomChoiceRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final T value;
  final List<RyadomChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RyadomSectionHeader(title: title, subtitle: subtitle),
        Wrap(
          spacing: RyadomTokens.itemGap,
          runSpacing: RyadomTokens.itemGap,
          children: [
            for (final option in options)
              RyadomSegmentChip(
                label: option.label,
                selected: option.value == value,
                onTap: () => onChanged(option.value),
              ),
          ],
        ),
      ],
    );
  }
}

class RyadomChoiceOption<T> {
  const RyadomChoiceOption(this.value, this.label);

  final T value;
  final String label;
}