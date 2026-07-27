import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../theme/ryadom_palette.dart';
import '../../../theme/ryadom_tokens.dart';
import '../../../widgets/ryadom_surface_card.dart';
import '../../requests/domain/request_responder.dart';

Future<String?> showHelperSelectionSheet({
  required BuildContext context,
  required String requestTitle,
  required List<RequestResponder> responders,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);
      final l10n = context.l10n;
      final colors = RyadomColors.of(context);
      final bottom = MediaQuery.of(context).viewInsets.bottom;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            RyadomTokens.screenPadding,
            8,
            RyadomTokens.screenPadding,
            20 + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.helperSelectionTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                l10n.helperSelectionSubtitle(requestTitle),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: RyadomTokens.sectionGap),
              for (final responder in responders)
                RyadomSurfaceCard(
                  margin: const EdgeInsets.only(bottom: RyadomTokens.itemGap),
                  onTap: () => Navigator.of(context).pop(responder.pubkey),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _shortPubkey(responder.pubkey),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              responder.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.muted,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

String _shortPubkey(String pubkey) {
  if (pubkey.length <= 12) {
    return pubkey;
  }
  return '${pubkey.substring(0, 6)}…${pubkey.substring(pubkey.length - 4)}';
}