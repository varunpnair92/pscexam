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

    // ── Exam Battle live fetch via battleExams API ──
    final isBattle = _currentItem.isBattle ||
        _currentItem.navigation.toLowerCase().contains('battle') ||
        _currentItem.url.toLowerCase().contains('battle') ||
        trimmed.contains('ബാറ്റിൽ');

    if (isBattle) {
      try {
        final res = await http.get(Uri.parse(AppConfig.battleExams)).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          List bList = [];
          if (decoded is Map && decoded['battles'] is List) {
            bList = decoded['battles'];
          } else if (decoded is List) {
            bList = decoded;
          }

          if (bList.isNotEmpty) {
            final firstB = bList[0];
            final bName = firstB['category'] ?? firstB['name'] ?? 'LDC Mock Exam';
            final totalQ = firstB['total_questions'] ?? firstB['questions_count'] ?? 20;
            _livePointsCache[trimmed] = [
              "$bName — 1,450+ ഉദ്യോഗാർത്ഥികളുമായി തത്സമയ ലൈവ് റാങ്ക് മത്സരം",
              "ആകെ ചോദ്യങ്ങൾ: $totalQ എണ്ണം (നെഗറ്റീവ് മാർക്കിംഗ് ബാധകം)",
              "പരീക്ഷ പൂർത്തിയാകുമ്പോൾ തത്സമയ റാങ്ക് ലിസ്റ്റും സൊല്യൂഷനും",
            ];
            _liveStatsCache[trimmed] = ["# Live Battle", "$totalQ Questions", "1,450+ Users"];
            if (mounted && _currentItem.demoQuery == trimmed) {
              setState(() {});
            }
            return;
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

          // 1. Try summary_lines
          if (decoded['summary_lines'] is List && (decoded['summary_lines'] as List).isNotEmpty) {
            lines = (decoded['summary_lines'] as List)
                .map((e) => e.toString().trim().replaceAll(RegExp(r'^[-•*#0-9.]+\s*'), ''))
                .where((e) => e.isNotEmpty && e.length > 3 && e != '#' && !e.startsWith('http'))
                .take(4)
                .toList();
          }

          // 2. Try raw summary
          if (lines.length < 2 && decoded['summary'] != null && decoded['summary'].toString().trim().isNotEmpty) {
            final sLines = decoded['summary']
                .toString()
                .split('\n')
                .map((e) => e.trim().replaceAll(RegExp(r'^[-•*#0-9.]+\s*'), ''))
                .where((e) => e.isNotEmpty && e.length > 3 && e != '#')
                .take(4)
                .toList();
            if (sLines.isNotEmpty) lines = sLines;
          }

          // 3. Try description lines or sentences
          if (lines.length < 2 && decoded['description'] != null && decoded['description'].toString().trim().isNotEmpty) {
            final rawDesc = decoded['description'].toString().trim();
            final dLines = rawDesc
                .split('\n')
                .map((e) => e.trim().replaceAll(RegExp(r'^[-•*#0-9.]+\s*'), ''))
                .where((e) => e.isNotEmpty && e.length > 6)
                .take(4)
                .toList();

            if (dLines.length >= 2) {
              lines = dLines;
            } else {
              final dSentences = rawDesc
                  .split('.')
                  .map((e) => e.trim().replaceAll(RegExp(r'^[-•*#0-9.]+\s*'), ''))
                  .where((e) => e.isNotEmpty && e.length > 8)
                  .take(4)
                  .toList();
              if (dSentences.isNotEmpty) lines = dSentences;
            }
          }

          // 4. Try children topics
          if (lines.length < 2 && decoded['children'] is List && (decoded['children'] as List).isNotEmpty) {
            lines = (decoded['children'] as List)
                .map((e) => "${(e is Map ? e['name'] ?? e['keyword'] : e)} — പ്രധാന സിലബസ് വിവരങ്ങൾ")
                .take(4)
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

    // Special handling for Exam Battle & Exam Create: No search typing needed!
    if (_currentItem.isBattle || _currentItem.isExamCreate) {
      _phaseTimer = Timer(const Duration(milliseconds: 650), () {
        _runClickPhase();
      });
      return;
    }

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
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 690),
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
          _buildPhaseStatusBadge(item, gradient),
          const SizedBox(height: 12),

          // If Exam Battle -> Build authentic Exam Battle UI
          if (item.isBattle) ...[
            _buildBattleSimulation(item, gradient),
          ] else if (item.isExamCreate) ...[
            _buildExamCreateSimulation(item, gradient),
          ] else ...[
            // Simulated Interactive Search Bar with Hand Pointer
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

            const SizedBox(height: 14),

            // Highlighted Data Area
            if (_currentPhase == DemoPhase.dataHighlighted ||
                _currentPhase == DemoPhase.completed)
              _buildSpotlightDataCard(item, gradient)
            else
              _buildWaitingPlaceholder(item, gradient),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseStatusBadge(FeatureDemoModel item, List<Color> gradient) {
    String label;
    IconData icon;
    Color color;

    if (item.isBattle) {
      switch (_currentPhase) {
        case DemoPhase.typing:
          label = "1. ലൈവ് എക്സാം പരിശോധിക്കുന്നു (Live Arena)...";
          icon = Icons.military_tech_rounded;
          color = const Color(0xFF1976D2);
          break;
        case DemoPhase.clicking:
          label = "2. 'Attend Exam Now' ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു...";
          icon = Icons.touch_app_rounded;
          color = const Color(0xFFE65100);
          break;
        case DemoPhase.dataHighlighted:
          label = "3. ലൈവ് പരീക്ഷ ആരംഭിച്ചു — റാങ്ക് മത്സരം സജീവം!";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
        case DemoPhase.completed:
          label = "പൂർത്തിയായി! ഇനി നേരിട്ട് പങ്കെടുക്കാം (Ready!)";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
      }
    } else if (item.isExamCreate) {
      switch (_currentPhase) {
        case DemoPhase.typing:
          label = "1. വിഷയം: '${item.demoQuery}', 20 ചോദ്യങ്ങൾ തിരഞ്ഞെടുക്കുന്നു...";
          icon = Icons.tune_rounded;
          color = const Color(0xFF1976D2);
          break;
        case DemoPhase.clicking:
          label = "2. 'Generate Exam' ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു...";
          icon = Icons.touch_app_rounded;
          color = const Color(0xFFE65100);
          break;
        case DemoPhase.dataHighlighted:
          label = "3. മോക്ക് എക്സാം തയ്യാറായി — പരീക്ഷ തുടങ്ങാം!";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
        case DemoPhase.completed:
          label = "പൂർത്തിയായി! ഇനി നേരിട്ട് പരീക്ഷ എഴുതാം (Ready!)";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
      }
    } else if (item.isStudySearch) {
      switch (_currentPhase) {
        case DemoPhase.typing:
          label = "1. '${item.demoQuery}' ഓട്ടോ-ടൈപ്പ് ചെയ്യുന്നു...";
          icon = Icons.keyboard_rounded;
          color = const Color(0xFF1976D2);
          break;
        case DemoPhase.clicking:
          label = "2. സെർച്ച് ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു...";
          icon = Icons.touch_app_rounded;
          color = const Color(0xFFE65100);
          break;
        case DemoPhase.dataHighlighted:
          label = "3. വിശദീകരണവും ചോദ്യങ്ങളും പരീക്ഷയും (3-Tab Study View)";
          icon = Icons.menu_book_rounded;
          color = _green1;
          break;
        case DemoPhase.completed:
          label = "പൂർത്തിയായി! ഇനി പഠനം ആരംഭിക്കാം (Ready!)";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
      }
    } else if (item.isSummary) {
      switch (_currentPhase) {
        case DemoPhase.typing:
          label = "1. '${item.demoQuery}' ഓട്ടോ-ടൈപ്പ് ചെയ്യുന്നു (Auto-Typing)...";
          icon = Icons.keyboard_rounded;
          color = const Color(0xFF1976D2);
          break;
        case DemoPhase.clicking:
          label = "2. സെർച്ച് ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു (Auto-Clicking)...";
          icon = Icons.touch_app_rounded;
          color = const Color(0xFFE65100);
          break;
        case DemoPhase.dataHighlighted:
          label = "3. സംഗ്രഹവും കുറിപ്പുകളും തത്സമയം കാണുന്നു (Summary View)";
          icon = Icons.auto_stories_rounded;
          color = _green1;
          break;
        case DemoPhase.completed:
          label = "പൂർത്തിയായി! ഇനി സ്വയം പരീക്ഷിക്കാം (Ready!)";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
      }
    } else if (item.isTimeline) {
      switch (_currentPhase) {
        case DemoPhase.typing:
          label = "1. '${item.demoQuery}' ഓട്ടോ-ടൈപ്പ് ചെയ്യുന്നു...";
          icon = Icons.keyboard_rounded;
          color = const Color(0xFF1976D2);
          break;
        case DemoPhase.clicking:
          label = "2. ടൈംലൈൻ ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു...";
          icon = Icons.touch_app_rounded;
          color = const Color(0xFFE65100);
          break;
        case DemoPhase.dataHighlighted:
          label = "3. വർഷക്രമത്തിലുള്ള ടൈംലൈൻ കാണുന്നു (Timeline Stream)";
          icon = Icons.timeline_rounded;
          color = _green1;
          break;
        case DemoPhase.completed:
          label = "പൂർത്തിയായി! ഇനി സ്വയം പരീക്ഷിക്കാം (Ready!)";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
      }
    } else {
      switch (_currentPhase) {
        case DemoPhase.typing:
          label = "1. '${item.demoQuery}' ഓട്ടോ-ടൈപ്പ് ചെയ്യുന്നു...";
          icon = Icons.keyboard_rounded;
          color = const Color(0xFF1976D2);
          break;
        case DemoPhase.clicking:
          label = "2. സെർച്ച് ഓട്ടോ-ക്ലിക്ക് ചെയ്യുന്നു...";
          icon = Icons.touch_app_rounded;
          color = const Color(0xFFE65100);
          break;
        case DemoPhase.dataHighlighted:
          label = "3. ഉപവിഷയങ്ങൾ തത്സമയം കണ്ടെത്തുന്നു (Search Results)";
          icon = Icons.grid_view_rounded;
          color = _green1;
          break;
        case DemoPhase.completed:
          label = "പൂർത്തിയായി! ഇനി സ്വയം പരീക്ഷിക്കാം (Ready!)";
          icon = Icons.check_circle_rounded;
          color = _green1;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
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
          if (_typedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade400),
            ),
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

  // ════════════════════════════════════════════════════════
  // ─── 1. AUTHENTIC EXAM BATTLE SIMULATION CARD ───
  // ════════════════════════════════════════════════════════
  Widget _buildBattleSimulation(FeatureDemoModel item, List<Color> gradient) {
    final bool isClicking = _currentPhase == DemoPhase.clicking;
    final bool isHighlighted = _currentPhase == DemoPhase.dataHighlighted || _currentPhase == DemoPhase.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Tab Bar (from ExamBattlePage)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _green1,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _green1.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.military_tech_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "Battles (1)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard_rounded, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 5),
                      Text(
                        "Results & Ranks",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Authentic Live Battle Exam Card (from ExamBattlePage)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlighted ? _green1 : gradient.first.withValues(alpha: 0.4),
              width: isHighlighted ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isHighlighted ? _green1 : gradient.first).withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar of Battle Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: (isHighlighted ? _green1 : gradient.first).withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _textDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "KERALA PSC • LIVE BATTLE",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "LIVE NOW",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "LDC 2026 Mega Mock Exam Battle",
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "തത്സമയ ലൈവ് റാങ്ക് മത്സരം (Statewide Live Rank)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Info Chips
                    Row(
                      children: [
                        _buildBattleChip(Icons.quiz_outlined, "100 Questions"),
                        const SizedBox(width: 8),
                        _buildBattleChip(Icons.timer_outlined, "75 Mins"),
                        const SizedBox(width: 8),
                        _buildBattleChip(Icons.people_outline_rounded, "1,450+ Users"),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Live Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded, size: 16, color: Colors.amber.shade900),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "ബാറ്റിൽ ഇപ്പോൾ സജീവമാണ് • ഇന്ന് രാത്രി 9:00 വരെ",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Action Button with Pointer Click Simulation
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedScale(
                          scale: (_isPointerPressed && isClicking) ? 0.94 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isHighlighted
                                    ? [const Color(0xFF0D3320), const Color(0xFF1B8A4E)]
                                    : [_green1, _green2],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _green1.withValues(alpha: isClicking ? 0.6 : 0.28),
                                  blurRadius: isClicking ? 14 : 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isHighlighted
                                      ? Icons.check_circle_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isHighlighted
                                      ? "✓ Attending Live Battle Now..."
                                      : "Attend Exam Now",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Hand pointer landing on Attend Exam Now button
                        if (isClicking)
                          Positioned(
                            right: 40,
                            bottom: -18,
                            child: SlideTransition(
                              position: _pointerOffsetAnim,
                              child: _buildHandPointer(gradient),
                            ),
                          ),
                      ],
                    ),

                    // When Highlighted / Attending: Show live battle rules & standing
                    if (isHighlighted) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FBF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _green1.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flash_on_rounded, size: 16, color: _green1),
                                const SizedBox(width: 6),
                                const Text(
                                  "തത്സമയ മത്സരം ആരംഭിച്ചു!",
                                  style: TextStyle(
                                    color: _textDark,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildBattleRuleItem("ഓരോ ശരിയുത്തരത്തിനും: +1 മാർക്ക്"),
                            _buildBattleRuleItem("തെറ്റായ ഉത്തരങ്ങൾക്ക്: -0.33 മാർക്ക്"),
                            _buildBattleRuleItem("പരീക്ഷ പൂർത്തിയാകുമ്പോൾ തത്സമയ റാങ്ക് ലിസ്റ്റ്"),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBattleChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: _green1),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 14, color: _green1),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ─── 1.5 AUTHENTIC EXAM CREATE SIMULATION (AI EXAM GENERATOR) ───
  // ════════════════════════════════════════════════════════
  Widget _buildExamCreateSimulation(FeatureDemoModel item, List<Color> gradient) {
    final bool isClicking = _currentPhase == DemoPhase.clicking;
    final bool isHighlighted =
        _currentPhase == DemoPhase.dataHighlighted || _currentPhase == DemoPhase.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Hero Banner (from ExamCreatePage) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_green1, _green2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _green1.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "AI Exam Generator",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "ഇഷ്ടമുള്ള പരീക്ഷ തയ്യാറാക്കാം",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "ഏത് വിഷയത്തിലും ഇഷ്ടമുള്ള ചോദ്യങ്ങൾ തിരഞ്ഞെടുക്കാം",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── 2. Topic Selection Card ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? _green1.withValues(alpha: 0.35) : Colors.grey.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: _green1, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Topic or Keyword / വിഷയം:",
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Topic input simulated box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green1.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: _green1, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      item.demoQuery,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _green1,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Selected",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Suggested chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildExamCreateTopicChip(item.demoQuery, true),
                  _buildExamCreateTopicChip("നവോത്ഥാനം", false),
                  _buildExamCreateTopicChip("നദികൾ", false),
                  _buildExamCreateTopicChip("ഭരണഘടന", false),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── 3. Question Count Section ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? _green1.withValues(alpha: 0.35) : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded, color: _green1, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    "ചോദ്യങ്ങളുടെ എണ്ണം (Question Count):",
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 12, color: Colors.amber.shade900),
                        const SizedBox(width: 4),
                        Text(
                          "15 Mins",
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Preset chips: 10, 20 (selected), 30, 50
              Row(
                children: [
                  _buildExamCreateCountChip("10 Qs", false),
                  const SizedBox(width: 8),
                  _buildExamCreateCountChip("20 Qs", true),
                  const SizedBox(width: 8),
                  _buildExamCreateCountChip("30 Qs", false),
                  const SizedBox(width: 8),
                  _buildExamCreateCountChip("50 Qs", false),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── 4. Generate Exam Button with Pointer Simulation ──
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: (_isPointerPressed && isClicking) ? 0.94 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHighlighted
                        ? [const Color(0xFF0D3320), const Color(0xFF1B8A4E)]
                        : [_green1, _green2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _green1.withValues(alpha: isClicking ? 0.6 : 0.28),
                      blurRadius: isClicking ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isHighlighted
                          ? Icons.check_circle_rounded
                          : Icons.bolt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHighlighted
                          ? "✓ 20 Questions Exam Generated!"
                          : "⚡ Generate Exam / പരീക്ഷ തുടങ്ങുക",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hand pointer landing on Generate Exam button
            if (isClicking)
              Positioned(
                right: 40,
                bottom: -18,
                child: SlideTransition(
                  position: _pointerOffsetAnim,
                  child: _buildHandPointer(gradient),
                ),
              ),
          ],
        ),

        // ── 5. When Highlighted: Show generated exam summary card ──
        if (isHighlighted) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4FBF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green1.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: _green1.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: _green1,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "മോക്ക് എക്സാം തയ്യാറായി! (${item.demoQuery})",
                        style: const TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _green1.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "READY",
                        style: TextStyle(
                          color: _green1,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "• 20 ചോദ്യങ്ങൾ • സമയം: 15 മിനിറ്റ്\n• ഓരോ ചോദ്യത്തിനും 4 ഓപ്ഷനുകൾ & വിശദീകരണം\n• താഴെയുള്ള 'ഇപ്പോൾ കാണുക (Try Now)' അമർത്തി പരീക്ഷ എഴുതാം!",
                  style: TextStyle(
                    color: Color(0xFF2C5E40),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExamCreateTopicChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? _green1 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _green1 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check_rounded, color: Colors.white, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : _textDark,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCreateCountChip(String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _green1 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _green1 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _green1.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, color: Colors.white, size: 12),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudySearchSpotlightCard(FeatureDemoModel item, List<Color> gradient) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gradient.first.withValues(alpha: 0.45), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Study Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gradient.first.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.menu_book_rounded, size: 18, color: gradient.first),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.demoQuery,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const Text(
                      "സ്റ്റഡി സെർച്ച് • വിശദീകരണങ്ങളും ചോദ്യങ്ങളും",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: gradient.first,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "STUDY SEARCH",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3 Tabs bar matching StudySearchPage
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _green1,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: _green1.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Description",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    child: Text(
                      "Questions (24)",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    child: Text(
                      "Mock Exam",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Description Snippet Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.article_rounded, size: 14, color: _green1),
                    const SizedBox(width: 5),
                    Text(
                      "${item.demoQuery} - സമഗ്ര കുറിപ്പുകൾ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "കേരളത്തിലെ 44 നദികൾ, അവയുടെ ഉത്ഭവം, പതനം, നീളം, പ്രധാന അണക്കെട്ടുകൾ, പോഷകനദികൾ എന്നിവയെക്കുറിച്ചുള്ള പ്രധാന വിവരങ്ങൾ...",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sample Questions Preview Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, size: 14, color: _green1),
                    const SizedBox(width: 5),
                    const Text(
                      "പരീക്ഷാ ചോദ്യങ്ങൾ (Sample Question)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  "Q: കേരളത്തിലെ ഏറ്റവും നീളം കൂടിയ നദി ഏത്?\n✓ ഉത്തരം: പെരിയാർ (244 കി.മീ)",
                  style: TextStyle(
                    fontSize: 11,
                    color: _textDark,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Tip Callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.blue.shade800, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "✨ 3 ടാബുകളിലായി വിവരണം, ചോദ്യങ്ങൾ, പരീക്ഷ ലഭ്യമാണ്!",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ─── 2. AUTHENTIC SUMMARY PAGE SPOTLIGHT CARD ───
  // ════════════════════════════════════════════════════════
  Widget _buildSummarySpotlightCard(FeatureDemoModel item, List<Color> gradient) {
    final desc = item.sampleSummaryDescription;
    final categories = item.sampleSummaryCategories;
    final cards = item.sampleSummaryCards;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _green1.withValues(alpha: 0.45), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: _green1.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic Header Card (matches KeywordSummaryPage)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green1.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _green1.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_rounded, color: _green1, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.demoQuery,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _green1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "SUMMARY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildSummaryChip(Icons.tag_rounded, "ID: #154"),
                    _buildSummaryChip(Icons.water_drop_rounded, "44 Rivers"),
                    _buildSummaryChip(Icons.dashboard_outlined, "${categories.length} Categories"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Description Card (matches KeywordSummaryPage _buildDescriptionCard)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green1.withValues(alpha: 0.25), width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _green1,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "വിവരണം (Description)",
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 12.2,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Category Filter Chips Bar
          Row(
            children: [
              const Icon(Icons.category_rounded, size: 14, color: _green1),
              const SizedBox(width: 5),
              Text(
                "വിഭാഗങ്ങൾ (${categories.length})",
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final isFirst = idx == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFirst ? _green1 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isFirst ? _green1 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    categories[idx],
                    style: TextStyle(
                      color: isFirst ? Colors.white : _textDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Summary Fact Cards
          Column(
            children: cards.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green1.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _green1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water_drop_rounded, size: 16, color: _green1),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c['title'] ?? '',
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _green1.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c['value'] ?? '',
                                  style: const TextStyle(
                                    color: _green1,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c['desc'] ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),
          // Tip Callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, color: Colors.amber.shade900, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "✨ വിവരണം, വിഭാഗങ്ങൾ, സംഗ്രഹം എന്നിവ ഒരിടത്ത് പഠിക്കാം!",
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: _green1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green1.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _green1),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ─── 3. AUTHENTIC SEARCH GRID SPOTLIGHT CARD ───
  // ════════════════════════════════════════════════════════
  Widget _buildSearchGridSpotlightCard(FeatureDemoModel item, List<Color> gradient) {
    final gridItems = item.sampleSearchGridItems;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gradient.first.withValues(alpha: 0.45), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gradient.first.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.grid_view_rounded, size: 18, color: gradient.first),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.demoQuery} — ഉപവിഷയങ്ങൾ",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      "Search Results (${gridItems.length} Sub-Topics)",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: gradient.first,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "SEARCH",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2-Column Grid (matches SearchParentNavigationPage layout)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, idx) {
              final g = gridItems[idx];
              final List<Color> itemGrad = g['gradient'] as List<Color>? ?? gradient;
              final IconData icon = g['icon'] as IconData? ?? Icons.topic_rounded;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      itemGrad.first,
                      itemGrad.last,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: itemGrad.first.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Watermark Icon
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Icon(
                          icon,
                          color: Colors.white.withValues(alpha: 0.16),
                          size: 55,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: Colors.white, size: 14),
                            ),
                            const Spacer(),
                            Text(
                              g['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              g['detail'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Footer info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.blue.shade800, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "✨ 44 ഉപവിഷയങ്ങളും സിലബസ് വിവരങ്ങളും കണ്ടെത്തി!",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ─── 4. AUTHENTIC TIMELINE STREAM SPOTLIGHT CARD ───
  // ════════════════════════════════════════════════════════
  Widget _buildTimelineSpotlightCard(FeatureDemoModel item, List<Color> gradient) {
    final points = item.sampleHighlightedPoints;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gradient.first.withValues(alpha: 0.45), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gradient.first.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.timeline_rounded, size: 18, color: gradient.first),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.demoQuery,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const Text(
                      "ചരിത്ര സംഭവങ്ങൾ • വർഷക്രമത്തിൽ",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: gradient.first,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "TIMELINE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timeline Stream Items
          Column(
            children: List.generate(points.length, (idx) {
              final pt = points[idx];
              String yearText = "";
              String eventTitle = pt;
              String eventDesc = "";

              if (pt.contains('—')) {
                final parts = pt.split('—');
                yearText = parts[0].trim();
                final rest = parts.sublist(1).join('—').trim();
                if (rest.contains(':')) {
                  final sub = rest.split(':');
                  eventTitle = sub[0].trim();
                  eventDesc = sub.sublist(1).join(':').trim();
                } else if (rest.contains('(') && rest.endsWith(')')) {
                  final openIdx = rest.indexOf('(');
                  eventTitle = rest.substring(0, openIdx).trim();
                  eventDesc = rest.substring(openIdx + 1, rest.length - 1).trim();
                } else {
                  eventTitle = rest;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gradient.first.withValues(alpha: 0.16)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: gradient.first,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        yearText.isNotEmpty ? yearText : "${1720 + idx * 20}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventTitle,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (eventDesc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              eventDesc,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 6),
          // Tip Callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, color: Colors.amber.shade900, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "✨ ചരിത്ര സംഭവങ്ങൾ വർഷക്രമത്തിൽ ഓർത്തു വെക്കാം!",
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightDataCard(FeatureDemoModel item, List<Color> gradient) {
    if (item.isBattle || item.isExamCreate) {
      return const SizedBox.shrink();
    }
    Widget content;
    if (item.isStudySearch) {
      content = _buildStudySearchSpotlightCard(item, gradient);
    } else if (item.isSummary) {
      content = _buildSummarySpotlightCard(item, gradient);
    } else if (item.isTimeline) {
      content = _buildTimelineSpotlightCard(item, gradient);
    } else {
      content = _buildSearchGridSpotlightCard(item, gradient);
    }

    return ScaleTransition(
      scale: _pulseScaleAnim,
      child: content,
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
