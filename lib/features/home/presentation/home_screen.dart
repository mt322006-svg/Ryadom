import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../chat/domain/chat_models.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../geo/domain/geo_privacy.dart';
import '../../geo/domain/map_links.dart';
import '../../nostr/data/local_nostr_request_store.dart';
import '../../nostr/data/we_ryadom_nostr_gateway.dart';
import '../../nostr/domain/we_ryadom_nostr.dart';
import '../../requests/domain/help_request.dart';
import '../../requests/domain/request_lifecycle.dart';
import '../../requests/presentation/request_creation_screen.dart';
import '../../../theme/ryadom_buttons.dart';
import '../../../theme/ryadom_app_theme.dart';
import '../../../theme/ryadom_palette.dart';
import '../../../theme/ryadom_tokens.dart';
import '../../../widgets/ryadom_startup_gate.dart';
import '../../../widgets/ryadom_surface_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../l10n/ryadom_l10n_helpers.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../trust/data/blocked_identity_store.dart';
import '../../trust/data/report_store.dart';
import '../../trust/data/response_rate_limiter.dart';
import '../../trust/domain/trust_guard.dart';
import 'helper_selection_sheet.dart';
import 'home_labels.dart';
import 'home_models.dart';
import 'home_bottom_nav.dart';
import 'home_header_widgets.dart';
import 'radar_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appTheme,
    required this.onAppThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
    this.nostrGateway,
    this.requestStore,
  });

  final RyadomAppTheme appTheme;
  final ValueChanged<RyadomAppTheme> onAppThemeChanged;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final WeRyadomNostrGateway? nostrGateway;
  final LocalNostrRequestStore? requestStore;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const List<int> _radiusOptions = [500, 1000, 3000, 5000, 10000];
  static const Duration _geoRefreshInterval = Duration(seconds: 45);

  LocalNostrRequestStore? _requestStore;
  late final WeRyadomNostrGateway _nostrGateway;
  bool _storeReady = false;
  HomeTab _tab = HomeTab.radar;
  RadarFilter _selectedFilter = RadarFilter.all;
  StreamSubscription? _nostrEventsSubscription;
  Position? _currentPosition;
  bool _locationEnabled = false;
  bool _loadingLocation = false;
  bool _loadingNostr = true;
  bool _geoRefreshInFlight = false;
  String? _locationError;
  DateTime? _lastLocationUpdate;
  double? _locationAccuracyMeters;
  String? _nostrError;
  NostrConnectionStatus _nostrStatus = NostrConnectionStatus.starting;
  String _relayUrl = 'wss://nos.lol';
  String? _npub;
  int _radiusMeters = 1000;
  String _appVersionLabel = '…';
  final Map<String, RequestRelayState> _requestRelayStates = {};
  final BlockedIdentityStore _blockedIdentityStore = const BlockedIdentityStore();
  final ResponseRateLimiter _responseRateLimiter = const ResponseRateLimiter();
  Set<String> _blockedPubkeys = {};
  Timer? _geoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nostrGateway = widget.nostrGateway ?? LiveWeRyadomNostrGateway();
    if (widget.requestStore != null) {
      _requestStore = widget.requestStore;
      _storeReady = true;
    }
    _bootstrap();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _locationEnabled) {
      unawaited(_requestCurrentLocation(silent: true));
    }
  }

  Future<void> _bootstrap() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersionLabel = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (_) {
      _appVersionLabel = '—';
    }

    if (widget.requestStore != null) {
      _requestStore = widget.requestStore;
      _storeReady = true;
    } else {
      _requestStore = await LocalNostrRequestStore.open();
      _storeReady = true;
    }

    _blockedPubkeys = await _blockedIdentityStore.loadBlockedPubkeys();

    if (!mounted) {
      return;
    }

    setState(() {});
    _initializeNostr();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _geoRefreshTimer?.cancel();
    _nostrEventsSubscription?.cancel();
    _nostrGateway.dispose();
    super.dispose();
  }

  void _startGeoRefreshTimer() {
    _geoRefreshTimer?.cancel();
    _geoRefreshTimer = Timer.periodic(_geoRefreshInterval, (_) {
      if (!mounted || !_locationEnabled) {
        return;
      }
      unawaited(_requestCurrentLocation(silent: true));
    });
  }

  void _stopGeoRefreshTimer() {
    _geoRefreshTimer?.cancel();
    _geoRefreshTimer = null;
  }

  Future<void> _openRequestCreation() async {
    final createdRequest = await Navigator.of(context).push<HelpRequest>(
      MaterialPageRoute(
        builder: (_) => RequestCreationScreen(
          initialAreaLabel: _locationEnabled && _currentPosition != null
              ? GeoPrivacy.approximateAreaLabel(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                )
              : null,
          initialLatitude: _locationEnabled ? _currentPosition?.latitude : null,
          initialLongitude: _locationEnabled
              ? _currentPosition?.longitude
              : null,
        ),
      ),
    );

    if (createdRequest == null) {
      return;
    }

    final areaBucket = createdRequest.latitude != null &&
            createdRequest.longitude != null
        ? GeoPrivacy.areaBucket(
            createdRequest.latitude!,
            createdRequest.longitude!,
          )
        : 'global';

    setState(() {
      _requestStore!.publishRequest(
        createdRequest,
        areaBucket: areaBucket,
        authorPubkey: _nostrGateway.currentPubkey,
      );
      _requestRelayStates[createdRequest.id] = RequestRelayState.localOnly;
      _selectedFilter = RadarFilter.all;
    });

    final published = await _nostrGateway.publishRequest(createdRequest);
    if (!mounted) {
      return;
    }

    setState(() {
      _requestRelayStates[createdRequest.id] = published
          ? RequestRelayState.sentToRelay
          : RequestRelayState.localOnly;
    });

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          published ? l10n.snackPublishedRelay : l10n.snackPublishedLocal,
        ),
      ),
    );
  }

  Future<HelpRequest> _respondToRequest(HelpRequest request) async {
    if (request.isOwnRequest || request.hasCurrentUserResponded) {
      return request;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_isBlockedRequest(request)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.snackAuthorBlocked)),
      );
      return request;
    }

    if (!await _responseRateLimiter.canRespond()) {
      final remaining = await _responseRateLimiter.remainingResponses();
      if (!mounted) {
        return request;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.snackRateLimited(remaining)),
        ),
      );
      return request;
    }

    final updatedRequest = request.copyWith(
      hasCurrentUserResponded: true,
      responseCount: request.responseCount + 1,
    );

    setState(() {
      _requestStore!.respondToRequest(request);
    });
    await _responseRateLimiter.recordResponse();

    final requestEventId = _requestStore!.requestEventIdFor(request.id);
    final requestAuthorPubkey = _requestStore!.requestAuthorPubkeyFor(request.id);
    if (requestEventId != null && requestAuthorPubkey != null) {
      unawaited(
        _nostrGateway.publishResponse(
          request: request,
          requestEventId: requestEventId,
          requestAuthorPubkey: requestAuthorPubkey,
        ),
      );
    }

    if (!mounted) {
      return updatedRequest;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.snackResponseSent)),
    );

    return _requestStore!.nearbyRequests.firstWhere(
      (item) => item.id == request.id,
      orElse: () => updatedRequest,
    );
  }

  Future<void> _initializeNostr() async {
    _nostrEventsSubscription ??= _nostrGateway.events.listen((record) {
      if (!mounted) {
        return;
      }

      setState(() => _applyRelayRecord(record));
    });

    final state = await _nostrGateway.initialize();
    if (!mounted) {
      return;
    }

    setState(() {
      _applyNostrState(state);
      _loadingNostr = false;
    });
  }

  void _applyRelayRecord(dynamic record) {
    final wasRequest = record.event.kind == weRyadomRequestKind;
    final requestId = wasRequest
        ? WeRyadomNostr.firstTagValue(record.event, 'd')
        : null;
    final isForeignRequest = wasRequest &&
        requestId != null &&
        requestId.isNotEmpty &&
        record.event.pubkey != _nostrGateway.currentPubkey &&
        !_ownRequestIds.contains(requestId);

    _requestStore!.ingestEventRecord(
      record,
      currentPubkey: _nostrGateway.currentPubkey,
      blockedPubkeys: _blockedPubkeys,
    );

    if (wasRequest && requestId != null && requestId.isNotEmpty) {
      _requestRelayStates[requestId] = record.event.pubkey ==
              _nostrGateway.currentPubkey
          ? RequestRelayState.sentToRelay
          : RequestRelayState.seenFromRelay;
    }

    if (!mounted) {
      return;
    }

    if (isForeignRequest) {
      final l10n = context.l10n;
      final title =
          (record.event.content['title'] as String?) ?? l10n.snackUntitledRequest;
      setState(() => _selectedFilter = RadarFilter.all);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.snackNewRequestNearby(title)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      setState(() {});
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentTheme: widget.appTheme,
          onThemeSelected: (theme) {
            widget.onAppThemeChanged(theme);
            Navigator.of(context).pop();
          },
          currentLocale: widget.currentLocale,
          onLocaleSelected: widget.onLocaleChanged,
          onOpenRelay: () {
            Navigator.of(context).pop();
            _openNostrSettings();
          },
          onOpenGeo: () {
            Navigator.of(context).pop();
            _openGeoSettings();
          },
        ),
      ),
    );
  }

  Future<void> _openNostrSettings() async {
    final controller = TextEditingController(text: _relayUrl);
    try {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final l10n = context.l10n;
              final theme = Theme.of(context);
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              final statusLabel = _loadingNostr
                  ? l10n.nostrConnectionStatus(NostrConnectionStatus.connecting)
                  : l10n.nostrConnectionStatus(_nostrStatus);

              void refreshSheet() {
                if (context.mounted) {
                  setModalState(() {});
                }
              }

              Future<void> reconnect() async {
                final relay = controller.text.trim();
                if (relay.isEmpty || _loadingNostr) {
                  return;
                }

                setState(() => _loadingNostr = true);
                refreshSheet();

                final state = await _nostrGateway.reconnect(relay);
                if (!mounted) {
                  return;
                }

                setState(() {
                  _applyNostrState(state);
                  _loadingNostr = false;
                });
                refreshSheet();
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 20 + bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nostrSettingsTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.nostrSettingsHint,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _loadingNostr
                            ? Icons.sync_rounded
                            : _nostrStatus == NostrConnectionStatus.online
                            ? Icons.wifi_tethering_rounded
                            : Icons.portable_wifi_off_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(statusLabel),
                      subtitle: _nostrError == null
                          ? Text(_relayUrl)
                          : Text(_nostrError!),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      enabled: !_loadingNostr,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Relay URL',
                        hintText: 'wss://nos.lol',
                      ),
                    ),
                    if (_npub != null) ...[
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.nostrYourNpub),
                        subtitle: Text(shortNpub(_npub!)),
                        trailing: IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: _npub!),
                            );
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
                      label: _loadingNostr
                          ? l10n.nostrConnectionStatus(
                              NostrConnectionStatus.connecting,
                            )
                          : l10n.nostrReconnect,
                      onPressed: _loadingNostr ? null : reconnect,
                      expand: true,
                    ),
                    const SizedBox(height: 8),
                    RyadomGlassButton(
                      label: l10n.later,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      variant: RyadomGlassVariant.secondary,
                      expand: true,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _refreshRelayInbox() async {
    setState(() => _loadingNostr = true);
    final state = await _nostrGateway.reconnect(_relayUrl);
    if (!mounted) {
      return;
    }
    setState(() {
      _applyNostrState(state);
      _loadingNostr = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isConnected
              ? context.l10n.snackRelayRefreshed
              : context.l10n.snackRelayUnavailable,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyNostrState(NostrGatewayState state) {
    _relayUrl = state.relayUrl;
    _nostrStatus = state.connectionStatus;
    _nostrError = state.errorMessage;
    _npub = state.npub;
  }

  String _geoStatusLabel(AppLocalizations l10n) {
    if (_loadingLocation) {
      return l10n.geoSearching;
    }
    if (_locationEnabled && _currentPosition != null) {
      final accuracy = _locationAccuracyMeters;
      if (accuracy != null && accuracy <= 50) {
        return l10n.geoPrecise;
      }
      if (accuracy != null && accuracy <= 150) {
        return l10n.geoStable;
      }
      return l10n.geoNearby;
    }
    return _locationError ?? l10n.geoDisabled;
  }

  String _geoMetaLabel(AppLocalizations l10n) {
    if (_locationEnabled && _currentPosition != null) {
      final accuracy = _locationAccuracyMeters;
      final updated = _lastLocationUpdate;
      final parts = <String>[];
      if (accuracy != null) {
        parts.add(l10n.geoAccuracy(accuracy.round()));
      }
      if (updated != null) {
        parts.add(l10n.geoUpdated(l10n.formatClock(updated)));
      }
      return parts.isEmpty ? l10n.geoCaptured : parts.join(' • ');
    }

    if (_locationError != null) {
      return l10n.geoMetaWithoutGeo;
    }

    return l10n.geoMetaOptional;
  }

  String _geoDetailsText(AppLocalizations l10n) {
    if (_locationEnabled && _currentPosition != null) {
      return l10n.geoDetailsEnabled;
    }
    if (_loadingLocation) {
      return l10n.geoDetailsLoading;
    }
    if (_locationError != null) {
      return l10n.geoDetailsError;
    }
    return l10n.geoDetailsDefault;
  }

  Future<void> _requestCurrentLocation({
    VoidCallback? onChanged,
    bool silent = false,
  }) async {
    if (_geoRefreshInFlight) {
      return;
    }
    if (silent && !_locationEnabled) {
      return;
    }

    final l10n = context.l10n;
    _geoRefreshInFlight = true;

    void notify(VoidCallback update) {
      if (!mounted) {
        return;
      }
      setState(update);
      onChanged?.call();
    }

    if (!silent) {
      notify(() {
        _loadingLocation = true;
        _locationError = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silent) {
          notify(() {
            _locationError = l10n.geoErrorServiceDisabled;
            _loadingLocation = false;
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !silent) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) {
        return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent) {
          notify(() {
            _locationError = l10n.geoErrorPermissionDenied;
            _loadingLocation = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: silent ? LocationAccuracy.low : LocationAccuracy.medium,
          timeLimit: Duration(seconds: silent ? 12 : 20),
        ),
      );

      notify(() {
        _currentPosition = position;
        _locationEnabled = true;
        _loadingLocation = false;
        _lastLocationUpdate = DateTime.now();
        _locationAccuracyMeters = position.accuracy;
        _locationError = null;
      });
      _startGeoRefreshTimer();
    } catch (_) {
      if (!silent) {
        notify(() {
          _locationError = l10n.geoErrorFailed;
          _loadingLocation = false;
        });
      }
    } finally {
      _geoRefreshInFlight = false;
    }
  }

  void _disableLocation({VoidCallback? onChanged}) {
    if (!mounted) {
      return;
    }
    _stopGeoRefreshTimer();
    setState(() {
      _locationEnabled = false;
      _currentPosition = null;
      _locationError = null;
      _lastLocationUpdate = null;
      _locationAccuracyMeters = null;
    });
    onChanged?.call();
  }

  Future<void> _openGeoSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
            final mediaQuery = MediaQuery.of(context);
            final maxSheetHeight = mediaQuery.size.height * 0.88;

            void refreshSheet() {
              if (context.mounted) {
                setModalState(() {});
              }
            }

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    20 + mediaQuery.viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.geoTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _geoDetailsText(l10n),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _loadingLocation
                              ? Icons.location_searching_rounded
                              : _locationEnabled
                              ? Icons.my_location_rounded
                              : Icons.location_disabled_outlined,
                        ),
                        title: Text(_geoStatusLabel(l10n)),
                        subtitle: Text(_geoMetaLabel(l10n)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          RyadomGlassButton.icon(
                            onPressed: _loadingLocation
                                ? null
                                : () => _requestCurrentLocation(
                                      onChanged: refreshSheet,
                                    ),
                            icon: _loadingLocation
                                ? Icons.hourglass_top_rounded
                                : Icons.refresh_rounded,
                            label: _loadingLocation
                                ? l10n.geoSearching
                                : _locationEnabled
                                ? l10n.geoRefresh
                                : l10n.geoEnable,
                            compact: true,
                          ),
                          RyadomGlassButton.icon(
                            onPressed: _locationEnabled && !_loadingLocation
                                ? () {
                                    _disableLocation(onChanged: refreshSheet);
                                  }
                                : null,
                            icon: Icons.location_off_rounded,
                            label: l10n.geoDisable,
                            variant: RyadomGlassVariant.secondary,
                            compact: true,
                          ),
                          RyadomGlassButton.icon(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              _pickRadius();
                            },
                            icon: Icons.radar_rounded,
                            label: l10n.geoRadiusButton(
                              l10n.formatRadius(_radiusMeters),
                            ),
                            variant: RyadomGlassVariant.secondary,
                            compact: true,
                          ),
                        ],
                      ),
                      if (_locationEnabled && _currentPosition != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.geoPublicZone(
                            GeoPrivacy.approximateAreaLabel(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickRadius() async {
    final selectedRadius = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.radiusPickerTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.radiusPickerHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final radius in _radiusOptions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.formatRadius(radius)),
                    trailing: radius == _radiusMeters
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(context).pop(radius),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedRadius != null) {
      setState(() => _radiusMeters = selectedRadius);
    }
  }

  double? _distanceForRequest(HelpRequest request) {
    if (_locationEnabled &&
        _currentPosition != null &&
        request.latitude != null &&
        request.longitude != null) {
      return Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        request.latitude!,
        request.longitude!,
      );
    }

    if (request.distanceHintMeters != null) {
      return request.distanceHintMeters!.toDouble();
    }

    return null;
  }

  bool _isBlockedRequest(HelpRequest request) {
    final author = _requestStore!.requestAuthorPubkeyFor(request.id);
    return TrustGuard.isBlockedAuthor(
      authorPubkey: author,
      blockedPubkeys: _blockedPubkeys,
    );
  }

  Future<void> _blockParticipant(String pubkey) async {
    final updated = await _blockedIdentityStore.blockPubkey(pubkey);
    if (!mounted) {
      return;
    }
    setState(() => _blockedPubkeys = updated);
  }

  Future<String?> _resolveHelperPubkey(HelpRequest request) async {
    final responders = _requestStore!.respondersFor(request.id);
    if (responders.isEmpty) {
      return null;
    }

    final existing = _requestStore!.chosenHelperPubkeyFor(request.id);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    if (responders.length == 1) {
      return responders.first.pubkey;
    }

    return showHelperSelectionSheet(
      context: context,
      requestTitle: request.title,
      responders: responders,
    );
  }

  HelpRequest? _requestById(String requestId) {
    for (final request in _requestStore!.ownRequests) {
      if (request.id == requestId) {
        return request;
      }
    }
    for (final request in _requestStore!.nearbyRequests) {
      if (request.id == requestId) {
        return request;
      }
    }
    return null;
  }

  Future<void> _markRequestCompleted(HelpRequest request) async {
    final l10n = context.l10n;
    final note = l10n.noteHelpReceived;
    setState(() {
      _requestStore!.updateRequestStatus(
        requestId: request.id,
        status: RequestStatus.completed,
        note: note,
      );
    });

    final requestEventId = _requestStore!.requestEventIdFor(request.id);
    if (requestEventId != null) {
      unawaited(
        _nostrGateway.publishRequestState(
          requestId: request.id,
          requestEventId: requestEventId,
          status: RequestStatus.completed,
          note: note,
        ),
      );
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snackRequestCompleted)),
    );
  }

  Future<void> _cancelRequest(HelpRequest request) async {
    if (!RequestLifecycle.canCancel(request)) {
      return;
    }

    final l10n = context.l10n;
    final note = l10n.noteRequestCancelled;
    setState(() {
      _requestStore!.updateRequestStatus(
        requestId: request.id,
        status: RequestStatus.cancelled,
        note: note,
      );
    });

    final requestEventId = _requestStore!.requestEventIdFor(request.id);
    if (requestEventId != null) {
      unawaited(
        _nostrGateway.publishRequestState(
          requestId: request.id,
          requestEventId: requestEventId,
          status: RequestStatus.cancelled,
          note: note,
        ),
      );
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snackRequestCancelled)),
    );
  }

  Future<void> _rateRequest(HelpRequest request, int stars) async {
    final l10n = context.l10n;
    final note = l10n.noteRating(stars);
    setState(() {
      _requestStore!.updateRequestStatus(
        requestId: request.id,
        status: RequestStatus.rated,
        note: note,
        rating: stars,
      );
    });

    final requestEventId = _requestStore!.requestEventIdFor(request.id);
    if (requestEventId != null) {
      unawaited(
        _nostrGateway.publishRequestState(
          requestId: request.id,
          requestEventId: requestEventId,
          status: RequestStatus.rated,
          note: note,
          rating: stars,
        ),
      );
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snackRatingSaved(stars))),
    );
  }

  Future<void> _confirmHelperChoice(HelpRequest request, String helperPubkey) async {
    setState(() {
      _requestStore!.chooseHelper(
        requestId: request.id,
        helperPubkey: helperPubkey,
      );
    });

    final requestEventId = _requestStore!.requestEventIdFor(request.id);
    if (requestEventId != null) {
      unawaited(
        _nostrGateway.publishHelperChosen(
          requestId: request.id,
          requestEventId: requestEventId,
          helperPubkey: helperPubkey,
        ),
      );
    }
  }

  Future<void> _openRequestChat(HelpRequest request) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final requestEventId = _requestStore!.requestEventIdFor(request.id);
    final requestAuthorPubkey = _requestStore!.requestAuthorPubkeyFor(request.id);
    String? participantPubkey;

    if (request.isOwnRequest) {
      final helperPubkey = await _resolveHelperPubkey(request);
      if (helperPubkey == null) {
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _requestStore!.respondersFor(request.id).isEmpty
                  ? l10n.snackNoResponses
                  : l10n.snackChooseHelper,
            ),
          ),
        );
        return;
      }
      await _confirmHelperChoice(request, helperPubkey);
      if (!mounted) {
        return;
      }
      participantPubkey = helperPubkey;
    } else {
      participantPubkey = requestAuthorPubkey;
    }

    if (requestEventId == null || requestAuthorPubkey == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.snackChatNoRelay)),
      );
      return;
    }

    final blockedPubkey = participantPubkey;

    await navigator.push(
      MaterialPageRoute(
        builder: (routeContext) => ChatScreen(
          session: _buildChatSession(
            routeContext,
            request,
            requestEventId: requestEventId,
            requestAuthorPubkey: requestAuthorPubkey,
            participantPubkey: participantPubkey,
          ),
          nostrGateway: _nostrGateway,
          currentPubkey: _nostrGateway.currentPubkey,
          initialChatPalette: widget.appTheme.chatPalette,
          onParticipantBlocked: blockedPubkey == null
              ? null
              : () => _blockParticipant(blockedPubkey),
        ),
      ),
    );
  }

  HelpChatSession _buildChatSession(
    BuildContext context,
    HelpRequest request, {
    required String requestEventId,
    required String requestAuthorPubkey,
    required String? participantPubkey,
  }) {
    final l10n = context.l10n;
    final participantName = request.isOwnRequest
        ? (participantPubkey == null
              ? l10n.chatNoResponseYet
              : l10n.chatHelperNearby)
        : l10n.chatRequestAuthor;
    final participantSubtitle = request.isOwnRequest
        ? (participantPubkey == null
              ? l10n.chatWaitingResponse
              : l10n.chatHasResponse)
        : request.areaLabel;

    final messages = _requestStore!.chatMessagesFor(
      requestId: request.id,
      currentPubkey: _nostrGateway.currentPubkey,
      participantName: participantName,
      requestAuthorPubkey: requestAuthorPubkey,
      activeParticipantPubkey: participantPubkey,
    );

    return HelpChatSession(
      request: request,
      title: request.isOwnRequest ? l10n.chatHelpTitle : l10n.chatResponseTitle,
      statusLabel: participantPubkey == null
          ? l10n.chatNoParticipant
          : l10n.chatReady,
      participant: ChatParticipant(
        name: participantName,
        subtitle: participantSubtitle,
        isCurrentUser: false,
      ),
      requestEventId: requestEventId,
      requestAuthorPubkey: requestAuthorPubkey,
      participantPubkey: participantPubkey,
      messages: messages,
    );
  }

  void _openRequestDetails(HelpRequest request) {
    var actionInFlight = false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final fresh = _requestById(request.id) ?? request;
            final authorPubkey =
                _requestStore?.requestAuthorPubkeyFor(fresh.id);

            void refreshSheet() {
              if (context.mounted) {
                setModalState(() {});
              }
            }

            return _RequestDetailsSheet(
              request: fresh,
              distanceMeters: _distanceForRequest(fresh),
              busy: actionInFlight,
              onCancel: RequestLifecycle.canCancel(fresh)
                  ? () async {
                      if (actionInFlight) {
                        return;
                      }
                      actionInFlight = true;
                      refreshSheet();
                      await _cancelRequest(fresh);
                      actionInFlight = false;
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    }
                  : null,
              onRespond: () async {
                if (actionInFlight) {
                  return;
                }
                if (fresh.isOwnRequest) {
                  Navigator.of(sheetContext).pop();
                  await _openRequestChat(_requestById(fresh.id) ?? fresh);
                  return;
                }

                if (fresh.hasCurrentUserResponded) {
                  Navigator.of(sheetContext).pop();
                  await _openRequestChat(_requestById(fresh.id) ?? fresh);
                  return;
                }

                actionInFlight = true;
                refreshSheet();
                final chatRequest = await _respondToRequest(fresh);
                actionInFlight = false;
                if (!mounted) {
                  return;
                }
                refreshSheet();
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
                await _openRequestChat(
                  _requestById(chatRequest.id) ?? chatRequest,
                );
              },
              onMarkComplete: fresh.isOwnRequest &&
                      (fresh.status == RequestStatus.inProgress ||
                          fresh.status == RequestStatus.accepted)
                  ? () async {
                      if (actionInFlight) {
                        return;
                      }
                      actionInFlight = true;
                      refreshSheet();
                      await _markRequestCompleted(
                        _requestById(fresh.id) ?? fresh,
                      );
                      actionInFlight = false;
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    }
                  : null,
              onRate: fresh.isOwnRequest &&
                      fresh.status == RequestStatus.completed
                  ? (stars) async {
                      if (actionInFlight) {
                        return;
                      }
                      actionInFlight = true;
                      refreshSheet();
                      await _rateRequest(
                        _requestById(fresh.id) ?? fresh,
                        stars,
                      );
                      actionInFlight = false;
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    }
                  : null,
              onReport: authorPubkey == null || authorPubkey.isEmpty
                  ? null
                  : () async {
                      if (actionInFlight) {
                        return;
                      }
                      actionInFlight = true;
                      refreshSheet();
                      final l10n = context.l10n;
                      await const ReportStore().addReport(
                        reportedPubkey: authorPubkey,
                        requestId: fresh.id,
                        reason: l10n.chatReportReason,
                      );
                      actionInFlight = false;
                      if (!mounted) {
                        return;
                      }
                      refreshSheet();
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(l10n.snackReported)),
                      );
                    },
              onBlock: authorPubkey == null ||
                      authorPubkey.isEmpty ||
                      fresh.isOwnRequest
                  ? null
                  : () async {
                      if (actionInFlight) {
                        return;
                      }
                      actionInFlight = true;
                      refreshSheet();
                      final l10n = context.l10n;
                      await _blockParticipant(authorPubkey);
                      actionInFlight = false;
                      if (!mounted) {
                        return;
                      }
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(l10n.snackBlocked)),
                      );
                    },
            );
          },
        );
      },
    );
  }

  String _ownRequestCta(HelpRequest request, AppLocalizations l10n) {
    if (request.responseCount == 0) {
      return l10n.waitingResponses;
    }
    final chosen = _requestStore!.chosenHelperPubkeyFor(request.id);
    if (request.responseCount > 1 && (chosen == null || chosen.isEmpty)) {
      return l10n.chooseHelper;
    }
    return l10n.openChat;
  }

  /// Чужие активные запросы рядом — одна логика для радара и вкладки «Запросы».
  /// Без гео показываем всё с relay; с гео — фильтр по радиусу.
  List<HelpRequest> _foreignActiveNearbyRequests() {
    final ownIds = _ownRequestIds;
    final myPubkey = _nostrGateway.currentPubkey;
    return _requestStore!.nearbyRequests.where((request) {
      if (!_isForeignRequestForRadar(request, ownIds: ownIds, myPubkey: myPubkey)) {
        return false;
      }
      if (_isBlockedRequest(request)) {
        return false;
      }
      if (!RequestLifecycle.isActiveNearby(request)) {
        return false;
      }
      if (_locationEnabled) {
        final distance = _distanceForRequest(request);
        if (distance == null || distance > _radiusMeters) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort(_compareByProximity);
  }

  int _compareByProximity(HelpRequest a, HelpRequest b) {
    final distanceA = _distanceForRequest(a);
    final distanceB = _distanceForRequest(b);
    if (distanceA == null && distanceB == null) {
      return 0;
    }
    if (distanceA == null) {
      return 1;
    }
    if (distanceB == null) {
      return -1;
    }
    return distanceA.compareTo(distanceB);
  }

  Set<String> get _ownRequestIds =>
      _requestStore!.ownRequests.map((request) => request.id).toSet();

  bool _isForeignRequestForRadar(
    HelpRequest request, {
    required Set<String> ownIds,
    required String? myPubkey,
  }) {
    if (ownIds.contains(request.id) || request.isOwnRequest) {
      return false;
    }
    if (myPubkey == null || myPubkey.isEmpty) {
      return true;
    }
    final author = _requestStore!.requestAuthorPubkeyFor(request.id);
    return author != myPubkey;
  }

  /// Чужие активные запросы для радара и «Активность рядом» (с учётом фильтра).
  List<HelpRequest> get _visibleRequests {
    final nearbyRequests = _foreignActiveNearbyRequests();

    switch (_selectedFilter) {
      case RadarFilter.all:
      case RadarFilter.requests:
        return nearbyRequests;
      case RadarFilter.people:
      case RadarFilter.signals:
        // Hidden in UI for now; never leave user on an empty dead filter.
        return nearbyRequests;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_storeReady || _requestStore == null) {
      return const RyadomStartupGate();
    }

    final theme = Theme.of(context);
    final foreignNearbyRequests = _foreignActiveNearbyRequests();
    final visibleRequests = _visibleRequests;
    final ownRequests = _requestStore!.ownRequests;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab.index,
          children: [
            _buildRadarTab(
              theme: theme,
              visibleRequests: visibleRequests,
              nearbyRequests: foreignNearbyRequests,
              ownRequests: ownRequests,
            ),
            _buildRequestsTab(
              theme: theme,
              ownRequests: ownRequests,
              nearbyRequests: foreignNearbyRequests,
            ),
            _buildProfileTab(theme),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        current: _tab,
        onSelected: (tab) => setState(() => _tab = tab),
      ),
    );
  }

  Widget _buildRadarTab({
    required ThemeData theme,
    required List<HelpRequest> visibleRequests,
    required List<HelpRequest> nearbyRequests,
    required List<HelpRequest> ownRequests,
  }) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: _refreshRelayInbox,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        HomeRadarHeader(
          onCreateRequest: _openRequestCreation,
          onOpenSettings: _openSettings,
          onOpenNostrSettings: _openNostrSettings,
          onOpenGeoSettings: _openGeoSettings,
          onPickRadius: _pickRadius,
          isNostrLoading: _loadingNostr,
          nostrStatus: _loadingNostr
              ? NostrConnectionStatus.connecting
              : _nostrStatus,
          isLocationEnabled: _locationEnabled,
          isLocationLoading: _loadingLocation,
          locationLabel: _geoStatusLabel(l10n),
          radiusLabel: l10n.formatRadius(_radiusMeters),
        ),
        const SizedBox(height: 16),
        RadarFilterBar(
          selectedFilter:
              _selectedFilter == RadarFilter.people ||
                  _selectedFilter == RadarFilter.signals
              ? RadarFilter.all
              : _selectedFilter,
          onSelected: (filter) {
            setState(() => _selectedFilter = filter);
          },
        ),
        const SizedBox(height: 16),
        RadarPanel(
          requests: visibleRequests,
          filter: _selectedFilter,
          onRequestTap: _openRequestDetails,
          radiusLabel: l10n.formatRadius(_radiusMeters),
          radiusMeters: _radiusMeters,
          distanceForRequest: _distanceForRequest,
          userLatitude: _locationEnabled ? _currentPosition?.latitude : null,
          userLongitude: _locationEnabled ? _currentPosition?.longitude : null,
        ),
        const SizedBox(height: 16),
        RyadomGlassButton.icon(
          onPressed: _openRequestCreation,
          icon: Icons.add_rounded,
          label: l10n.needHelpTitle,
          expand: true,
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: l10n.activityNearby,
          actionLabel: _selectedFilter == RadarFilter.requests
              ? l10n.filterShowRequests
              : l10n.filterShowAll,
          onActionTap: _selectedFilter == RadarFilter.requests
              ? () => setState(() => _selectedFilter = RadarFilter.all)
              : null,
        ),
        const SizedBox(height: 12),
        if (visibleRequests.isEmpty)
          _EmptyActivityCard(filter: _selectedFilter)
        else
          ...visibleRequests
              .take(4)
              .map(
                (request) => _ActivityRow(
                  request,
                  distanceMeters: _distanceForRequest(request),
                  onTap: () => _openRequestDetails(request),
                ),
              ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                value: '${nearbyRequests.length}',
                label: l10n.filterActiveRequests,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                value: overviewResponseLabel(nearbyRequests),
                label: l10n.filterNearbyResponses,
                color: RyadomColors.of(context).urgent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: l10n.myRequests,
          actionLabel: '${ownRequests.length}',
        ),
        const SizedBox(height: 12),
        if (ownRequests.isEmpty)
          const _EmptyActivityCard.myRequests()
        else
          ...ownRequests.map(
            (request) => _OwnRequestCard(
              request,
              relayState:
                  _requestRelayStates[request.id] ?? RequestRelayState.localOnly,
              actionLabel: _ownRequestCta(request, l10n),
              onTap: () => _openRequestChat(request),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          l10n.radarFooterHint,
          style: theme.textTheme.bodyMedium,
        ),
      ],
      ),
    );
  }

  Widget _buildRequestsTab({
    required ThemeData theme,
    required List<HelpRequest> ownRequests,
    required List<HelpRequest> nearbyRequests,
  }) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(l10n.navRequests, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.requestsTabSubtitle,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: l10n.myRequestsShort,
          actionLabel: '${ownRequests.length}',
        ),
        const SizedBox(height: 12),
        if (ownRequests.isEmpty)
          const _EmptyActivityCard.myRequests()
        else
          ...ownRequests.map(
            (request) => _OwnRequestCard(
              request,
              relayState:
                  _requestRelayStates[request.id] ?? RequestRelayState.localOnly,
              actionLabel: _ownRequestCta(request, l10n),
              onTap: () => _openRequestChat(request),
            ),
          ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: l10n.nearbySection,
          actionLabel: '${nearbyRequests.length}',
        ),
        const SizedBox(height: 12),
        if (nearbyRequests.isEmpty)
          const _EmptyActivityCard(filter: RadarFilter.all)
        else
          ...nearbyRequests.map(
            (request) => _ActivityRow(
              request,
              distanceMeters: _distanceForRequest(request),
              onTap: () => _openRequestDetails(request),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileTab(ThemeData theme) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(l10n.navProfile, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.profileSubtitle,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.wifi_tethering_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.profileNostr),
                  subtitle: Text(
                    _nostrError ?? l10n.compactNostrStatus(_nostrStatus),
                  ),
                  trailing: TextButton(
                    onPressed: _openNostrSettings,
                    child: Text(l10n.profileRelay),
                  ),
                ),
                if (_npub != null) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('npub'),
                    subtitle: Text(shortNpub(_npub!)),
                    trailing: IconButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final copiedMessage = l10n.nostrNpubCopied;
                        await Clipboard.setData(ClipboardData(text: _npub!));
                        if (!context.mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(copiedMessage)),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ),
                ],
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.my_location_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.geoTitle),
                  subtitle: Text(_geoStatusLabel(l10n)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _openGeoSettings,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.settingsTitle),
                  subtitle: Text(
                    l10n.profileTheme(l10n.themeTitle(widget.appTheme)),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _openSettings,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.aboutBuild, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(l10n.appTitle),
                const SizedBox(height: 4),
                Text(
                  l10n.aboutVersion(_appVersionLabel),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutBuildNote,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final action = Text(
      actionLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.headlineSmall)),
        const SizedBox(width: 12),
        Flexible(
          child: onActionTap == null
              ? action
              : TextButton(
                  onPressed: onActionTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: action,
                ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(
    this.request, {
    required this.onTap,
    this.distanceMeters,
  });

  final HelpRequest request;
  final VoidCallback onTap;
  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final chipColor =
        urgencyColor(request.urgency, colors: RyadomColors.of(context));
    final distanceLabel = l10n.formatDistance(distanceMeters);
    final secondaryParts = <String>[
      request.timeLabel,
      if (distanceMeters != null) distanceLabel,
      if (request.hasCurrentUserResponded) l10n.youResponded,
    ];

    return RyadomSurfaceCard(
      margin: const EdgeInsets.only(bottom: RyadomTokens.itemGap),
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_rounded, color: chipColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 17,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.areaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  secondaryParts.join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _MetaChip(
            label: distanceMeters != null
                ? distanceLabel
                : request.hasCurrentUserResponded
                    ? l10n.responseChip
                    : l10n.urgencyLabel(request.urgency),
            color: chipColor,
          ),
        ],
      ),
    );
  }
}

class _RequestDetailsSheet extends StatelessWidget {
  const _RequestDetailsSheet({
    required this.request,
    required this.onRespond,
    this.onMarkComplete,
    this.onCancel,
    this.onRate,
    this.onReport,
    this.onBlock,
    this.distanceMeters,
    this.busy = false,
  });

  final HelpRequest request;
  final VoidCallback onRespond;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onCancel;
  final void Function(int stars)? onRate;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final double? distanceMeters;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final chipColor =
        urgencyColor(request.urgency, colors: RyadomColors.of(context));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 22,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: RyadomColors.of(context).border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: l10n.urgencyLabel(request.urgency),
                        color: chipColor,
                      ),
                      _MetaChip(
                        label: l10n.compensationLabel(request.compensation),
                        color: request.compensation == RequestCompensation.free
                            ? theme.colorScheme.primary
                            : RyadomColors.of(context).urgent,
                      ),
                      _MetaChip(
                        label:
                            l10n.responseCountChipLabel(request.responseCount),
                        color: RyadomColors.of(context).muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(request.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(request.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  _SafetyNoteCard(
                    message: request.compensation == RequestCompensation.paid
                        ? l10n.safetyPaid
                        : l10n.safetyFree,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.areaLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (distanceMeters != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.formatDistance(distanceMeters),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (request.latitude != null &&
                      request.longitude != null) ...[
                    const SizedBox(height: 14),
                    _MapPointCard(
                      latitude: request.latitude!,
                      longitude: request.longitude!,
                      enabled: !busy,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.timeLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetaChip(
                    label: l10n.statusLabel(request.status),
                    color: theme.colorScheme.primary,
                  ),
                  if (onRate != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.rateHelpTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var stars = 1; stars <= 5; stars++)
                          IconButton(
                            tooltip: l10n.rateStarsTooltip(stars),
                            onPressed: busy ? null : () => onRate!(stars),
                            icon: Icon(
                              Icons.star_rounded,
                              size: 34,
                              color: Color.lerp(
                                const Color(0xFFD6CEC3),
                                const Color(0xFFE8B84A),
                                stars / 5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (onReport != null)
                        TextButton.icon(
                          onPressed: busy ? null : onReport,
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(l10n.report),
                        ),
                      if (onBlock != null)
                        TextButton.icon(
                          onPressed: busy ? null : onBlock,
                          icon: const Icon(Icons.block_outlined, size: 18),
                          label: Text(l10n.block),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RyadomSheetActions(
                    extra: onMarkComplete == null && onCancel == null
                        ? null
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (onMarkComplete != null) ...[
                                RyadomGlassButton(
                                  label: l10n.helpReceived,
                                  onPressed: busy ? null : onMarkComplete,
                                  variant: RyadomGlassVariant.ghost,
                                  expand: true,
                                ),
                                if (onCancel != null) const SizedBox(height: 10),
                              ],
                              if (onCancel != null)
                                RyadomGlassButton(
                                  label: l10n.cancelRequest,
                                  onPressed: busy ? null : onCancel,
                                  variant: RyadomGlassVariant.secondary,
                                  expand: true,
                                ),
                            ],
                          ),
                    primaryLabel: request.isOwnRequest ||
                            request.hasCurrentUserResponded
                        ? l10n.openChat
                        : l10n.respond,
                    onPrimary: busy ? null : onRespond,
                    secondaryLabel: l10n.later,
                    onSecondary:
                        busy ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPointCard extends StatelessWidget {
  const _MapPointCard({
    required this.latitude,
    required this.longitude,
    required this.enabled,
  });

  final double latitude;
  final double longitude;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = RyadomColors.of(context);
    final coords = MapLinks.formatCoordinates(latitude, longitude);

    Future<void> openMap(MapApp app) async {
      final ok = await MapLinks.openInMaps(
        latitude: latitude,
        longitude: longitude,
        preferred: app,
      );
      if (!context.mounted) {
        return;
      }
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapOpenFailed)),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.mapCoordsTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          InkWell(
            onTap: enabled
                ? () async {
                    await Clipboard.setData(ClipboardData(text: coords));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.mapCoordsCopied)),
                      );
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.my_location_rounded, size: 18, color: colors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      coords,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Icon(Icons.copy_rounded, size: 18, color: colors.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(l10n.mapCoordsHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RyadomGlassButton.icon(
                onPressed: enabled ? () => openMap(MapApp.yandex) : null,
                icon: Icons.map_outlined,
                label: l10n.mapOpenYandex,
                compact: true,
              ),
              RyadomGlassButton.icon(
                onPressed: enabled ? () => openMap(MapApp.google) : null,
                icon: Icons.public_rounded,
                label: l10n.mapOpenGoogle,
                compact: true,
                variant: RyadomGlassVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyNoteCard extends StatelessWidget {
  const _SafetyNoteCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivityCard extends StatelessWidget {
  const _EmptyActivityCard({required this.filter}) : forOwnRequests = false;

  const _EmptyActivityCard.myRequests()
      : filter = RadarFilter.requests,
        forOwnRequests = true;

  final RadarFilter filter;
  final bool forOwnRequests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final accent = theme.colorScheme.primary;
    final (icon, title, body) = forOwnRequests
        ? (
            Icons.campaign_outlined,
            l10n.emptyMyRequestsTitle,
            l10n.emptyMyRequestsBody,
          )
        : switch (filter) {
            RadarFilter.people => (
              Icons.people_outline_rounded,
              l10n.emptyPeopleTitle,
              l10n.emptyPeopleBody,
            ),
            RadarFilter.signals => (
              Icons.bolt_outlined,
              l10n.emptySignalsTitle,
              l10n.emptySignalsBody,
            ),
            RadarFilter.requests => (
              Icons.receipt_long_outlined,
              l10n.emptyFilterTitle,
              l10n.emptyFilterBody,
            ),
            RadarFilter.all => (
              Icons.radar_rounded,
              l10n.emptyQuietTitle,
              l10n.emptyQuietBody,
            ),
          };

    return RyadomSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RyadomSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _OwnRequestCard extends StatelessWidget {
  const _OwnRequestCard(
    this.request, {
    required this.onTap,
    required this.relayState,
    required this.actionLabel,
  });

  final HelpRequest request;
  final VoidCallback onTap;
  final RequestRelayState relayState;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return RyadomSurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                label: l10n.statusLabel(request.status),
                color: theme.colorScheme.primary,
              ),
              _MetaChip(
                label: l10n.responseCountChipLabel(request.responseCount),
                color: const Color(0xFF7B6A58),
              ),
              _MetaChip(
                label: l10n.relayStateLabel(relayState),
                color: relayState.color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            request.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                actionLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


