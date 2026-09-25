import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../../theme/ryadom_buttons.dart';
import '../../nostr/data/we_ryadom_nostr_gateway.dart';

class NostrDeveloperSheet extends StatefulWidget {
  const NostrDeveloperSheet({
    super.key,
    required this.relayUrl,
    required this.connectionStatus,
    required this.isLoading,
    required this.errorMessage,
    required this.npub,
    required this.onReconnect,
  });

  final String relayUrl;
  final NostrConnectionStatus connectionStatus;
  final bool isLoading;
  final String? errorMessage;
  final String? npub;
  final Future<NostrGatewayState> Function(String relayUrl) onReconnect;

  @override
  State<NostrDeveloperSheet> createState() => _NostrDeveloperSheetState();
}

class _NostrDeveloperSheetState extends State<NostrDeveloperSheet> {
  late final TextEditingController _controller;
  late String _relayUrl;
  late NostrConnectionStatus _status;
  late bool _loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _relayUrl = widget.relayUrl;
    _status = widget.connectionStatus;
    _loading = widget.isLoading;
    _errorMessage = widget.errorMessage;
    _controller = TextEditingController(text: _relayUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reconnect() async {
    final relay = _controller.text.trim();
    if (relay.isEmpty || _loading) {
      return;
    }

    setState(() => _loading = true);
    final state = await widget.onReconnect(relay);
    if (!mounted) {
      return;
    }
    setState(() {
      _relayUrl = state.relayUrl;
      _status = state.connectionStatus;
      _errorMessage = state.errorMessage;
      _loading = false;
      _controller.text = state.relayUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final statusLabel = _loading
        ? l10n.nostrConnectionStatus(NostrConnectionStatus.connecting)
        : l10n.nostrConnectionStatus(_status);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.nostrSettingsTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l10n.nostrSettingsHint, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _loading
                  ? Icons.sync_rounded
                  : _status == NostrConnectionStatus.online
                      ? Icons.wifi_tethering_rounded
                      : Icons.portable_wifi_off_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(statusLabel),
            subtitle: _errorMessage == null
                ? Text(_relayUrl)
                : Text(_errorMessage!),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            enabled: !_loading,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Relay URL',
              hintText: 'wss://nos.lol',
            ),
          ),
          if (widget.npub != null) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.nostrYourNpub),
              subtitle: Text(shortNpub(widget.npub!)),
              trailing: IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.npub!));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.nostrNpubCopied)),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                tooltip: l10n.tooltipCopyNpub,
              ),
            ),
          ],
          const SizedBox(height: 12),
          RyadomGlassButton(
            label: _loading
                ? l10n.nostrConnectionStatus(NostrConnectionStatus.connecting)
                : l10n.nostrReconnect,
            onPressed: _loading ? null : _reconnect,
            expand: true,
          ),
          const SizedBox(height: 8),
          RyadomGlassButton(
            label: l10n.later,
            onPressed: () => Navigator.of(context).pop(),
            variant: RyadomGlassVariant.secondary,
            expand: true,
          ),
        ],
      ),
    );
  }
}
