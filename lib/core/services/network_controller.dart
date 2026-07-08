import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum NetworkQuality { none, low, good }

class NetworkDependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  
  // Observable states
  final Rx<NetworkQuality> quality = NetworkQuality.none.obs;
  final RxBool isConnected = false.obs;
  final RxString connectionType = 'none'.obs;
  final RxInt latency = 0.obs;
  final RxBool isChecking = false.obs;
  final RxBool hasFinishedInitialCheck = false.obs;

  StreamSubscription? _connectivitySub;
  Timer? _qualityTimer;

  @override
  void onInit() {
    super.onInit();
    _listenConnectivity();
    _startQualityChecks();
  }

  void _listenConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      connectionType.value = result.name;
      
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
        quality.value = NetworkQuality.none;
        latency.value = 0;
      } else {
        // Re-check quality immediately on network configuration change
        checkQuality();
      }
    });
  }

  void _startQualityChecks() {
    checkQuality();
    // Periodically measure network latency/quality every 15 seconds
    _qualityTimer = Timer.periodic(const Duration(seconds: 15), (_) => checkQuality());
  }

  Future<void> checkQuality() async {
    if (isChecking.value) return;
    isChecking.value = true;
    
    final stopwatch = Stopwatch()..start();
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      stopwatch.stop();
      
      if (!hasInternet) {
        isConnected.value = false;
        quality.value = NetworkQuality.none;
        latency.value = 0;
      } else {
        final ms = stopwatch.elapsedMilliseconds;
        latency.value = ms;
        isConnected.value = true;
        // Mark as low quality if response takes > 800ms
        quality.value = ms < 800 ? NetworkQuality.good : NetworkQuality.low;
      }
    } catch (_) {
      isConnected.value = false;
      quality.value = NetworkQuality.none;
      latency.value = 0;
    } finally {
      isChecking.value = false;
      hasFinishedInitialCheck.value = true;
    }
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    _qualityTimer?.cancel();
    super.onClose();
  }
}

class InternetWrapper extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;

  const InternetWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
  });

  @override
  State<InternetWrapper> createState() => _InternetWrapperState();
}

class _InternetWrapperState extends State<InternetWrapper> {
  late final NetworkController _networkController;
  StreamSubscription? _subscription;
  StreamSubscription? _initSub;

  bool _isBannerVisible = false;
  String _bannerText = '';
  Color _bannerColor = Colors.red;
  IconData _bannerIcon = Icons.wifi_off_rounded;
  Timer? _hideTimer;
  bool? _lastConnectedState;

  @override
  void initState() {
    super.initState();
    _networkController = Get.find<NetworkController>();

    _lastConnectedState = _networkController.isConnected.value;

    // Listen to changes
    _subscription = _networkController.isConnected.listen((connected) {
      if (!_networkController.hasFinishedInitialCheck.value) {
        _lastConnectedState = connected;
        return;
      }

      if (_lastConnectedState == null) {
        _lastConnectedState = connected;
        if (!connected) {
          _showBanner(
            text: "No internet",
            color: const Color(0xFFEF4444), // Tailwind Red 500
            icon: Icons.wifi_off_rounded,
          );
        }
        return;
      }

      if (_lastConnectedState != connected) {
        _lastConnectedState = connected;
        if (connected) {
          _showBanner(
            text: "Back to internet",
            color: const Color(0xFF10B981), // Tailwind Green 500
            icon: Icons.wifi_rounded,
          );
        } else {
          _showBanner(
            text: "No internet",
            color: const Color(0xFFEF4444), // Tailwind Red 500
            icon: Icons.wifi_off_rounded,
          );
        }
      }
    });

    // Listen to initial check completion to show red offline banner if starts offline
    _initSub = _networkController.hasFinishedInitialCheck.listen((initialized) {
      if (initialized && !_networkController.isConnected.value) {
        _showBanner(
          text: "No internet",
          color: const Color(0xFFEF4444),
          icon: Icons.wifi_off_rounded,
        );
      }
    });
  }

  void _showBanner({required String text, required Color color, required IconData icon}) {
    _hideTimer?.cancel();
    setState(() {
      _bannerText = text;
      _bannerColor = color;
      _bannerIcon = icon;
      _isBannerVisible = true;
    });

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isBannerVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _initSub?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastOutSlowIn,
          height: _isBannerVisible ? (statusBarHeight + 28) : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: _bannerColor,
          ),
          child: Container(
            height: statusBarHeight + 28,
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_bannerIcon, color: Colors.white, size: 12),
                const SizedBox(width: 6),
                Text(
                  _bannerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }
}

class NetworkStatusPill extends StatelessWidget {
  const NetworkStatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NetworkController>();
    return Obx(() {
      final isOnline = controller.isConnected.value;
      final q = controller.quality.value;
      final type = controller.connectionType.value.toLowerCase();

      IconData iconData = Icons.wifi_off_rounded;
      Color statusColor = Colors.red;
      String tooltipText = "Offline";

      if (isOnline) {
        if (q == NetworkQuality.good) {
          statusColor = const Color(0xFF10B981);
          tooltipText = "Good Network";
          if (type.contains('wifi')) {
            iconData = Icons.wifi_rounded;
          } else if (type.contains('ethernet')) {
            iconData = Icons.settings_ethernet_rounded;
          } else {
            iconData = Icons.signal_cellular_4_bar_rounded;
          }
        } else {
          statusColor = Colors.amber;
          tooltipText = "Low Network (${controller.latency.value}ms)";
          if (type.contains('wifi')) {
            iconData = Icons.wifi_2_bar_rounded;
          } else if (type.contains('ethernet')) {
            iconData = Icons.settings_ethernet_rounded;
          } else {
            iconData = Icons.signal_cellular_connected_no_internet_4_bar_rounded;
          }
        }
      }

      return Tooltip(
        message: tooltipText,
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Icon(
            iconData,
            color: statusColor,
            size: 20,
          ),
        ),
      );
    });
  }
}
