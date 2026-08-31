import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/app_connectivity_status.dart';
import '../services/i_connectivity_service.dart';

/// Wraps application screens to provide an animated offline top banner when connection is lost.
class OfflineBannerWrapper extends StatefulWidget {
  const OfflineBannerWrapper({
    super.key,
    required this.child,
    this.connectivityService,
  });

  final Widget child;
  final IConnectivityService? connectivityService;

  @override
  State<OfflineBannerWrapper> createState() => _OfflineBannerWrapperState();
}

class _OfflineBannerWrapperState extends State<OfflineBannerWrapper> {
  late final IConnectivityService _service;
  StreamSubscription<AppConnectivityStatus>? _subscription;

  bool _isOffline = false;
  bool _showRestoredBanner = false;
  Timer? _restoredTimer;

  @override
  void initState() {
    super.initState();
    _service =
        widget.connectivityService ?? GetIt.instance<IConnectivityService>();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final initial = await _service.checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = !initial.isConnected;
      });
    }

    _subscription = _service.onConnectivityChanged.listen((status) {
      if (!status.isConnected && !_isOffline) {
        setState(() {
          _isOffline = true;
          _showRestoredBanner = false;
        });
      } else if (status.isConnected && _isOffline) {
        setState(() {
          _isOffline = false;
          _showRestoredBanner = true;
        });
        _restoredTimer?.cancel();
        _restoredTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showRestoredBanner = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _restoredTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline || _showRestoredBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _isOffline
                      ? Colors.redAccent.shade700
                      : Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_isOffline ? Colors.red : Colors.green)
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOffline
                            ? Icons.wifi_off_rounded
                            : Icons.wifi_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isOffline
                              ? 'No Internet Connection (Offline)'
                              : 'Back Online',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
