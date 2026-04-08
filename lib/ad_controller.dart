import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'ad_model.dart';
import 'auth_controller.dart';

class AdController extends GetxController {
  var ads = <AdModel>[].obs;
  var _shownThisSession = false;

  @override
  void onInit() {
    super.onInit();
    fetchAndShowAd();
  }

  Future<void> fetchAndShowAd({bool force = false}) async {
    try {
      final auth = AuthController.instance;
      String url = AppConfig.activeAds;
      if (auth.isLoggedIn.value) {
        url += "?userid=${auth.userId.value}";
      }
      
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        ads.value = data
            .map((e) => AdModel.fromJson(e))
            .where((a) => a.active && a.category == 'popup')
            .toList();

        if (ads.isNotEmpty && (force || !_shownThisSession)) {
          _shownThisSession = true;
          // Small delay to let the home screen render first
          await Future.delayed(const Duration(milliseconds: 800));
          _showAdPopup(ads.first);
        }
      }
    } catch (_) {
      // Silently fail — ads are non-critical
    }
  }

  void _showAdPopup(AdModel ad) {
    Get.dialog(
      _AdPopupWidget(ad: ad),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }
}

// ─── Ad Popup Widget ──────────────────────────────────────────────────────────

class _AdPopupWidget extends StatefulWidget {
  final AdModel ad;
  const _AdPopupWidget({required this.ad});

  @override
  State<_AdPopupWidget> createState() => _AdPopupWidgetState();
}

class _AdPopupWidgetState extends State<_AdPopupWidget>
    with SingleTickerProviderStateMixin {
  int _secondsLeft = 0;
  Timer? _countdownTimer;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();

    // Auto-close countdown
    if (widget.ad.timer > 0) {
      _secondsLeft = widget.ad.timer;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) {
          t.cancel();
          if (Get.isDialogOpen ?? false) Get.back();
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    const green = Color(0xFF1B8A4E);

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image (if available)
                  if (ad.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Image.network(
                        ad.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3320),
                          ),
                        ),
                        if (ad.description != null &&
                            ad.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            ad.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Button row
                        Row(
                          children: [
                            if (ad.linkUrl != null &&
                                ad.linkUrl!.isNotEmpty) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (Get.isDialogOpen ?? false) Get.back();
                                    // TODO: launch URL
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('Learn More'),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (Get.isDialogOpen ?? false) Get.back();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                child: Text(
                                  _secondsLeft > 0
                                      ? 'Close ($_secondsLeft)'
                                      : 'Close',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ✕ Close button (top-right)
            Positioned(
              top: -14,
              right: -14,
              child: GestureDetector(
                onTap: () {
                  if (Get.isDialogOpen ?? false) Get.back();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Colors.grey),
                ),
              ),
            ),

            // Countdown ring (top-left corner) if auto-close is on
            if (widget.ad.timer > 0)
              Positioned(
                top: -14,
                left: -14,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B8A4E),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$_secondsLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
