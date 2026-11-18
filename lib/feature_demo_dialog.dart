import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'feature_demo_model.dart';
import 'feature_demo_controller.dart';

class FeatureDemoDialog extends StatefulWidget {
  final List<FeatureDemoModel> demoItems;

  const FeatureDemoDialog({super.key, required this.demoItems});

  static void show(List<FeatureDemoModel> items) {
    if (items.isEmpty) return;
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      FeatureDemoDialog(demoItems: items),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.72),
    );
  }

  @override
  State<FeatureDemoDialog> createState() => _FeatureDemoDialogState();
}

enum DemoPhase {
  typing,
  clicking,
  dataHighlighted,
  completed,
}

class _FeatureDemoDialogState extends State<FeatureDemoDialog>
    with TickerProviderStateMixin {
  late PageController _pageCtrl;
  int _currentIndex = 0;

  // Animation phase states
  DemoPhase _currentPhase = DemoPhase.typing;
  String _typedText = "";
  bool _isCursorVisible = true;
  bool _isPointerPressed = false;
  bool _isAutoPlaying = true;
  double _stepProgress = 0.0;

  // Live data caching per query
  final Map<String, List<String>> _livePointsCache = {};
  final Map<String, List<String>> _liveStatsCache = {};

  // Timers & Controllers
  Timer? _typingTimer;
  Timer? _cursorTimer;
  Timer? _phaseTimer;
  Timer? _progressTimer;
  late AnimationController _pointerAnimCtrl;
  late Animation<Offset> _pointerOffsetAnim;
  late AnimationController _highlightPulseCtrl;
  late Animation<double> _pulseScaleAnim;

  static const _green1 = Color(0xFF1B8A4E);
  static const _green2 = Color(0xFF27AE60);
  static const _textDark = Color(0xFF0D3320);

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    // Pointer flight animation
    _pointerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pointerOffsetAnim = Tween<Offset>(
      begin: const Offset(0.3, 1.2),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _pointerAnimCtrl,
      curve: Curves.easeOutCubic,
    ));

    // Highlight card pulse glow
    _highlightPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseScaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _highlightPulseCtrl, curve: Curves.easeInOut),
    );

    // Blinking cursor timer
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (mounted) {
        setState(() => _isCursorVisible = !_isCursorVisible);
      }
    });

    // Start simulation for first item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startItemSimulation();
    });
  }

  @override
  void dispose() {
    _cancelAllTimers();
    _pointerAnimCtrl.dispose();
    _highlightPulseCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _cancelAllTimers() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _phaseTimer?.cancel();
    _progressTimer?.cancel();
  }

  FeatureDemoModel get _currentItem => widget.demoItems[_currentIndex];

  Future<void> _fetchLivePoints(String query, int nodeId) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _livePointsCache.containsKey(trimmed)) return;

    final isTimeline = _currentItem.isTimeline ||
        _currentItem.navigation.toLowerCase().contains('timeline') ||
        _currentItem.url.toLowerCase().contains('timeline') ||
        trimmed.contains('സമര');

    // ── Timeline live fetch via keywordTimeline API ──
    if (isTimeline) {
      try {
        final tUrl = "${AppConfig.keywordTimeline}${Uri.encodeComponent(trimmed)}/";
        final res = await http.get(Uri.parse(tUrl)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          List rawTimeline = [];
          if (decoded is List) {
            rawTimeline = decoded;
          } else if (decoded is Map && decoded['timeline'] is List) {
            rawTimeline = decoded['timeline'];
          } else if (decoded is Map && decoded['data'] is List) {
            rawTimeline = decoded['data'];
          }

          if (rawTimeline.isNotEmpty) {
            List<String> tLines = [];
            for (var yearGroup in rawTimeline) {
              final y = yearGroup['year']?.toString() ?? '';
              final evList = yearGroup['events'];
              if (evList is List && evList.isNotEmpty) {
                final firstEv = evList[0];
                final kw = firstEv['keyword']?.toString() ?? '';
                String d = (firstEv['summary'] ?? firstEv['description'] ?? '').toString().split('\n')[0].trim();
                if (d.length > 55) d = "${d.substring(0, 52)}...";
                tLines.add(d.isNotEmpty ? "$y — $kw: $d" : "$y — $kw");
              }
            }

            if (tLines.isNotEmpty) {
              _livePointsCache[trimmed] = tLines.take(4).toList();
              final firstY = rawTimeline.first['year']?.toString() ?? '1721';
              final lastY = rawTimeline.last['year']?.toString() ?? '2007';
              _liveStatsCache[trimmed] = [
                "# $firstY-$lastY",
                "${rawTimeline.length} Events",
                "Chronological",
              ];
              if (mounted && _currentItem.demoQuery == trimmed) {
                setState(() {});
              }
              return;
            }
          }
        }
      } catch (_) {}
    }

    try {
      final url = "${AppConfig.keywordSearchSummary}?keyword=${Uri.encodeComponent(trimmed)}";
      final res = await http
          .get(Uri.parse(url), headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map) {
          List<String> lines = [];

          if (decoded['summary_lines'] is List && (decoded['summary_lines'] as List).isNotEmpty) {
            lines = (decoded['summary_lines'] as List)
                .map((e) => e.toString().trim().replaceAll(RegExp(r'^[-•*0-9.]+\s*'), ''))
                .where((e) => e.isNotEmpty && e.length > 3)
                .take(3)
                .toList();
          } else if (decoded['summary'] != null && decoded['summary'].toString().trim().isNotEmpty) {
            lines = decoded['summary']
                .toString()
                .split('\n')
                .map((e) => e.trim().replaceAll(RegExp(r'^[-•*0-9.]+\s*'), ''))
                .where((e) => e.isNotEmpty && e.length > 3)
                .take(3)
                .toList();
          } else if (decoded['children'] is List && (decoded['children'] as List).isNotEmpty) {
            lines = (decoded['children'] as List)
                .map((e) => "${(e is Map ? e['name'] ?? e['keyword'] : e)} — പ്രധാന സിലബസ് വിവരങ്ങൾ")
                .take(3)
                .toList();
          } else if (decoded['description'] != null && decoded['description'].toString().trim().isNotEmpty) {
            lines = decoded['description']
                .toString()
                .split('.')
                .map((e) => e.trim())
                .where((e) => e.length > 10)
                .take(3)
                .toList();
          }

          if (lines.isNotEmpty) {
            _livePointsCache[trimmed] = lines;
            int childCount = (decoded['children'] is List) ? (decoded['children'] as List).length : 0;
            _liveStatsCache[trimmed] = [
              "# ID: #${decoded['keyword_id'] ?? nodeId}",
              "${childCount > 0 ? childCount : lines.length} Topics",
              "Verified",
            ];
            if (mounted && _currentItem.demoQuery == trimmed) {
              setState(() {});
            }
          }
        }
      }
    } catch (_) {
      // Silently ignore, fallback will be used
    }
  }

  void _startItemSimulation() {
    _cancelAllTimers();
    if (!mounted) return;

    // Reset state for new step
    setState(() {
      _currentPhase = DemoPhase.typing;
      _typedText = "";
      _isPointerPressed = false;
      _stepProgress = 0.0;
    });
    _pointerAnimCtrl.reset();

    // Fetch live search data for this specific node in background
    _fetchLivePoints(_currentItem.demoQuery, _currentItem.id);

    // Restart blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (mounted) {
        setState(() => _isCursorVisible = !_isCursorVisible);
      }
    });

    final targetQuery = _currentItem.demoQuery;
    int charIndex = 0;

    // Phase 1: Auto-Type query character by character
    _typingTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (charIndex < targetQuery.length) {
        charIndex++;
        setState(() {
          _typedText = targetQuery.substring(0, charIndex);
        });
      } else {
        timer.cancel();
        // Wait 350ms, then begin Phase 2: Click
        _phaseTimer = Timer(const Duration(milliseconds: 350), () {
          _runClickPhase();
        });
      }
    });
  }

  void _runClickPhase() {
    if (!mounted) return;
    setState(() {
      _currentPhase = DemoPhase.clicking;
    });

    // Animate hand pointer to search button
    _pointerAnimCtrl.forward();

    // After pointer lands, simulate finger tap press
    _phaseTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isPointerPressed = true);

      // Release click and reveal highlighted data
      _phaseTimer = Timer(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() => _isPointerPressed = false);
        _runDataHighlightPhase();
      });
    });
  }

  void _runDataHighlightPhase() {
    if (!mounted) return;
    setState(() {
      _currentPhase = DemoPhase.dataHighlighted;
      _stepProgress = 0.0;
    });

    if (!_isAutoPlaying) return;

    // Show highlighted data for 3.5 seconds with auto-progress bar
    const totalTicks = 35;
    int currentTick = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      currentTick++;
      setState(() {
        _stepProgress = (currentTick / totalTicks).clamp(0.0, 1.0);
      });

      if (currentTick >= totalTicks) {
        timer.cancel();
        _onStepComplete();
      }
    });
  }

  void _onStepComplete() {
    if (!mounted) return;
    final isLast = _currentIndex >= widget.demoItems.length - 1;
    if (isLast) {
      // Completed all demo items -> smoothly auto close!
      setState(() {
        _currentPhase = DemoPhase.completed;
      });
      _phaseTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted && Get.isDialogOpen == true) {
          Get.back();
        }
      });
    } else {
      // Auto-advance to next demo item
      _currentIndex++;
      _pageCtrl.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _startItemSimulation();
    }
  }

  void _onManualNext() {
    if (_currentIndex < widget.demoItems.length - 1) {
      _currentIndex++;
      _pageCtrl.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _startItemSimulation();
    } else {
      Get.back();
    }
  }

  void _onManualPrev() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageCtrl.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _startItemSimulation();
    }
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });
    if (_isAutoPlaying && _currentPhase == DemoPhase.dataHighlighted) {
      _runDataHighlightPhase();
    } else {
      _progressTimer?.cancel();
    }
  }

  void _tryFeatureNow() {
    FeatureDemoController.navigateFromDemo(_currentItem);
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final gradient = item.gradientColors;
    final isLast = _currentIndex == widget.demoItems.length - 1;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 660),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 36,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Column(
              children: [
                // ─── Header Bar with Step Badge & Controls ───
                _buildHeaderBar(gradient),

                // ─── Top Step Progress Indicators ───
                _buildProgressBars(gradient),

                // ─── Live Interactive Simulation Canvas ───
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(), // Driven by simulation
                    itemCount: widget.demoItems.length,
                    itemBuilder: (context, index) {
                      return _buildSimulationPage(widget.demoItems[index]);
                    },
                  ),
                ),

                // ─── Auto-Advance Linear Progress Bar ───
                if (_currentPhase == DemoPhase.dataHighlighted && _isAutoPlaying)
                  LinearProgressIndicator(
                    value: _stepProgress,
                    minHeight: 3.5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(gradient.first),
                  ),

                // ─── Bottom Action Controls ───
                _buildBottomControls(gradient, isLast),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar(List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.first.withValues(alpha: 0.1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gradient.first.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 14, color: gradient.first),
                const SizedBox(width: 5),
                Text(
                  "ആപ്പ് ഫീച്ചർ ഡെമോ • Live Tour",
                  style: TextStyle(
                    color: gradient.first,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Auto-play Pause/Resume toggle
          IconButton(
            tooltip: _isAutoPlaying ? "Pause Demo" : "Resume Auto Play",
            icon: Icon(
              _isAutoPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
              size: 22,
              color: gradient.first,
            ),
            onPressed: _toggleAutoPlay,
            splashRadius: 18,
          ),
          // Step Counter
          Text(
            "${_currentIndex + 1}/${widget.demoItems.length}",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          // Close button
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
            splashRadius: 18,
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars(List<Color> gradient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(widget.demoItems.length, (i) {
          final isCompleted = i < _currentIndex;
          final isCurrent = i == _currentIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: isCompleted
                    ? _green1
                    : isCurrent
                        ? gradient.first
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSimulationPage(FeatureDemoModel item) {
    final gradient = item.gradientColors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Phase Status Banner ──
          _buildPhaseStatusBadge(gradient),
          const SizedBox(height: 12),

          // ── Simulated Interactive Search Bar with Hand Pointer ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildSimulatedSearchBar(item, gradient),
              // Floating animated pointer / hand cursor
              if (_currentPhase == DemoPhase.clicking)
                Positioned(
                  right: 14,
                  bottom: -16,
                  child: SlideTransition(
                    position: _pointerOffsetAnim,
                    child: _buildHandPointer(gradient),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Highlighted Data Area ──
          if (_currentPhase == DemoPhase.dataHighlighted ||
              _currentPhase == DemoPhase.completed)
            _buildSpotlightDataCard(item, gradient)
          else
            _buildWaitingPlaceholder(item, gradient),
        ],
      ),
    );
  }

  Widget _buildPhaseStatusBadge(List<Color> gradient) {
    String label;
    IconData icon;
    Color color;

    switch (_currentPhase) {
      case DemoPhase.typing:
        label = "1. വിഷയം ഓട്ടോ-ഫിൽ ചെയ്യുന്നു (Auto-Typing...)";
        icon = Icons.keyboard_rounded;
        color = const Color(0xFF1976D2);
        break;
      case DemoPhase.clicking:
        label = "2. സെർച്ച് ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു (Auto-Clicking...)";
        icon = Icons.touch_app_rounded;
        color = const Color(0xFFE65100);
        break;
      case DemoPhase.dataHighlighted:
        label = "3. ഹൈലൈറ്റ് ചെയ്ത ഡാറ്റ തത്സമയം കാണുന്നു (Live Data)";
        icon = Icons.auto_awesome_rounded;
        color = _green1;
        break;
      case DemoPhase.completed:
        label = "പൂർത്തിയായി! ഇനി സ്വയം പരീക്ഷിക്കാം (Ready!)";
        icon = Icons.check_circle_rounded;
        color = _green1;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedSearchBar(FeatureDemoModel item, List<Color> gradient) {
    final isClicking = _currentPhase == DemoPhase.clicking;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _currentPhase == DemoPhase.typing || isClicking
              ? gradient.first
              : Colors.grey.shade300,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: isClicking ? 0.28 : 0.08),
            blurRadius: isClicking ? 18 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(item.iconData, color: gradient.first, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    _typedText.isEmpty ? "Search topics..." : _typedText,
                    style: TextStyle(
                      color: _typedText.isEmpty
                          ? Colors.grey.shade400
                          : _textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_currentPhase == DemoPhase.typing && _isCursorVisible)
                  Container(
                    width: 2,
                    height: 18,
                    margin: const EdgeInsets.only(left: 2),
                    color: gradient.first,
                  ),
              ],
            ),
          ),
          // Clear icon when text present
          if (_typedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade400),
            ),
          // Search / Action Button with Click Feedback
          AnimatedScale(
            scale: _isPointerPressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (_isPointerPressed)
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.6),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandPointer(List<Color> gradient) {
    return AnimatedScale(
      scale: _isPointerPressed ? 0.85 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.touch_app_rounded,
          color: Colors.amberAccent,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildWaitingPlaceholder(FeatureDemoModel item, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCF9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gradient.first.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.iconData, size: 36, color: gradient.first),
          ),
          const SizedBox(height: 14),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            item.fallbackDescription,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightDataCard(FeatureDemoModel item, List<Color> gradient) {
    final cachedPoints = _livePointsCache[item.demoQuery];
    final cachedStats = _liveStatsCache[item.demoQuery];

    final isTimelineCard = item.isTimeline ||
        item.navigation.toLowerCase().contains('timeline') ||
        item.url.toLowerCase().contains('timeline') ||
        item.demoQuery.contains('സമര');

    final points = (cachedPoints != null && cachedPoints.isNotEmpty)
        ? cachedPoints
        : item.sampleHighlightedPoints;
    final stats = (cachedStats != null && cachedStats.isNotEmpty)
        ? cachedStats
        : item.sampleStats;

    return AnimatedBuilder(
      animation: _pulseScaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseScaleAnim.value,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4FBF4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gradient.first.withValues(alpha: 0.55), width: 2),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.22),
                  blurRadius: 22,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Title & Header Chips ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradient.first.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isTimelineCard ? Icons.timeline_rounded : Icons.bookmark_rounded,
                    color: gradient.first,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.demoQuery,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.categoryTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradient.first,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "LIVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Pill Badges (# ID, Categories, Points) ──
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: stats.map((st) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _green2.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    st,
                    style: TextStyle(
                      color: gradient.first,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // ── Highlighted Points (Timeline or Standard List) ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gradient.first.withValues(alpha: 0.18)),
              ),
              child: Column(
                children: List.generate(points.length, (idx) {
                  final pt = points[idx];
                  final isLastPt = idx == points.length - 1;

                  // Parse timeline year & description if formatted as YYYY — Title
                  String yearText = "";
                  String eventTitle = pt;
                  String eventDesc = "";

                  if (isTimelineCard && pt.contains('—')) {
                    final parts = pt.split('—');
                    yearText = parts[0].trim();
                    final rest = parts.sublist(1).join('—').trim();
                    if (rest.contains(':')) {
                      final subParts = rest.split(':');
                      eventTitle = subParts[0].trim();
                      eventDesc = subParts.sublist(1).join(':').trim();
                    } else if (rest.contains('(') && rest.endsWith(')')) {
                      final openIdx = rest.indexOf('(');
                      eventTitle = rest.substring(0, openIdx).trim();
                      eventDesc = rest.substring(openIdx + 1, rest.length - 1).trim();
                    } else {
                      eventTitle = rest;
                    }
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (yearText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: gradient.first,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  yearText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eventTitle,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                    if (eventDesc.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        eventDesc,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: gradient.first.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${idx + 1}",
                                  style: TextStyle(
                                    color: gradient.first,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  pt,
                                  style: const TextStyle(
                                    fontSize: 13.2,
                                    fontWeight: FontWeight.w600,
                                    color: _textDark,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isLastPt)
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color: Colors.grey.shade200,
                        ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),
            // Highlight Tip Callout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: Colors.amber.shade900, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTimelineCard
                          ? "✨ ചരിത്ര സംഭവങ്ങൾ കാലക്രമത്തിൽ മനഃപാഠമാക്കാം!"
                          : "✨ ഒറ്റ ക്ലിക്കിൽ മുഴുവൻ വിവരങ്ങളും സംഗ്രഹവും പഠിക്കാം!",
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(List<Color> gradient, bool isLast) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_currentIndex > 0) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
                  tooltip: "Previous",
                  onPressed: _onManualPrev,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _tryFeatureNow,
                  icon: Icon(Icons.play_arrow_rounded, color: gradient.first, size: 18),
                  label: Text(
                    "ഇപ്പോൾ കാണുക (Try Now)",
                    style: TextStyle(
                      color: gradient.first,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.8,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: gradient.first, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _onManualNext,
                  icon: Icon(
                    isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isLast ? "പൂർത്തിയായി (Done)" : "അടുത്തത് (Next)",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradient.first,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "ഡെമോ ഒഴിവാക്കുക (Skip Demo)",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
