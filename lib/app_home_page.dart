import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/auth_controller.dart';
import 'home_controller.dart';
import 'test_controller.dart';
import 'image_slider_controller.dart';
import 'study_controller.dart';
import 'notification_controller.dart';
import 'notification_overlay.dart';
import 'notification_overlay.dart';
import 'knowledge_capsule_overlay.dart';
import 'news_ticker_widget.dart';
import 'psc_loading_logo.dart'; // 🔥 Import Logo
import 'ui_utils.dart';

class AppHomePage extends StatelessWidget {
  final HomeController ctrl = Get.put(HomeController());
  final testCtrl = Get.find<TestController>();
  final ImageSliderController sliderCtrl = Get.put(ImageSliderController());
  final NotificationController notifCtrl = Get.put(NotificationController());

  AppHomePage({super.key});

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);            // off-white background
  static const _surface = Colors.white;
  static const _green1 = Color(0xFF1B8A4E);        // deep green
  static const _green2 = Color(0xFF27AE60);        // mid green
  static const _green3 = Color(0xFF52C97A);        // light green
  static const _textDark = Color(0xFF0D3320);      // dark green text
  static const _textMid = Color(0xFF4D7A5E);       // muted green text
  static const _gold = Color(0xFFF5A623);          // accent gold

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _green1.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _green1.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(
                      child: PSCLoadingLogo(size: 80),
                    );
                  }
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 8),
                            const NewsTickerWidget(), // 📰 Flash News
                            const SizedBox(height: 4),
                            _resumeCard(), // 🔥 Premium Green Resume Card
                            const SizedBox(height: 4),
                            _imageSlider(),
                            const SizedBox(height: 16),
                            _examStatsSection(),
                            const SizedBox(height: 24),
                            _boxedSection(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('🚀 Attempts'),
                                  const SizedBox(height: 16),
                                  _attemptCategoriesGrid(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            _boxedSection(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('📋 Exam Categories'),
                                  const SizedBox(height: 16),
                                  _examCategoriesGrid(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            _boxedSection(
                              child: _quickActions(),
                            ),
                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            
            // ─── Daily Knowledge Capsule Overlay ───
            KnowledgeCapsuleOverlay(),
          ],
        ),
      ),
    );
  }

  // ─── SliverAppBar ─────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200, // 🔥 Reduced for better small screen fit
      pinned: true,
      backgroundColor: _green1,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_green1, _green2, _green3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: Stack(
            children: [
              // decorative circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Obx(() => Text(
                      'Hello ${ctrl.userName.value.isNotEmpty ? ctrl.userName.value : 'User'} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    )),
                    const SizedBox(height: 14),
                    // ── Search Bar inside header ──
                    const HomeSearchBar(),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
      title: const Text(
        'PSC Online',
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () => Get.find<AuthController>().signOut(),
        ),
        Obx(() => Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => Get.to(
                () => NotificationOverlay(),
                opaque: false,
                transition: Transition.fadeIn,
              ),
            ),
            if (notifCtrl.notifications.isNotEmpty)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              ),
          ],
        )),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  // ─── Resume Card ──────────────────────────────────────────────
  Widget _resumeCard() {
    return Obx(() {
      if (!testCtrl.hasResume.value) return const SizedBox.shrink();

      final int id = testCtrl.resumeExamId.value;
      final int answered = testCtrl.resumeAnswered.value;
      final int total = testCtrl.resumeTotal.value;
      final int seconds = testCtrl.resumeTimeLeft.value;
      final int min = seconds ~/ 60;
      final String title = testCtrl.examTitle.value;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B8A4E), Color(0xFF27AE60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B8A4E).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  size: 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              InkWell(
                onTap: () async {
                  await testCtrl.loadProgress(id, title: title);
                  Get.toNamed('/exam', arguments: {"id": id, "title": title});
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Continue Your Exam",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$answered/$total Answered",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$min min left",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Image Slider ─────────────────────────────────────────────
  Widget _imageSlider() {
    return Obx(() {
      if (sliderCtrl.isLoading.value) {
        return const SizedBox(
          height: 220,
          child: Center(child: PSCLoadingLogo(size: 60)),
        );
      }
      if (sliderCtrl.sliderImages.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 220,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.92),
          itemCount: sliderCtrl.sliderImages.length,
          itemBuilder: (context, index) {
            final image = sliderCtrl.sliderImages[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _green1.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(image.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ─── Exam Stats Section ───────────────────────────────────────
  Widget _examStatsSection() {
    return Obx(() {
      if (ctrl.statsLoading.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green1.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(color: _green1.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: const Center(
            child: SizedBox(height: 100, child: PSCLoadingLogo(size: 50)),
          ),
        );
      }

      final total = ctrl.totalExams.value;
      final attempted = ctrl.attemptedExams.value;
      final remaining = ctrl.remainingExams.value;
      final ratio = ctrl.successRatio.value;
      final progress = total > 0 ? attempted / total : 0.0;

      // Smart suggestion
      String suggestion;
      if (ratio >= 80) {
        suggestion = '🔥 Excellent! Keep pushing forward!';
      } else if (ratio >= 60) {
        suggestion = '📈 Good progress! Attempt $remaining more exams.';
      } else if (attempted == 0) {
        suggestion = '🚀 Start your first exam today!';
      } else {
        suggestion = '📚 Keep studying to boost your score!';
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green1.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(color: _green1.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _green1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: _green1, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Your Progress',
                  style: TextStyle(color: _textDark, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Live Exams',
                    style: TextStyle(color: _green1, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4 Stat Cards Grid (Responsive)
            LayoutBuilder(builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 340;
              if (isSmall) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _miniStat('Total', '$total', Icons.list_alt_rounded, _green1),
                        const SizedBox(width: 8),
                        _miniStat('Attended', '$attempted', Icons.check_circle_rounded, _green2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _miniStat('Remaining', '$remaining', Icons.hourglass_top_rounded, _gold),
                        const SizedBox(width: 8),
                        _miniStat('Success', '${ratio.toStringAsFixed(1)}%', Icons.emoji_events_rounded, const Color(0xFFE74C3C)),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _miniStat('Total', '$total', Icons.list_alt_rounded, _green1),
                  const SizedBox(width: 8),
                  _miniStat('Attended', '$attempted', Icons.check_circle_rounded, _green2),
                  const SizedBox(width: 8),
                  _miniStat('Remaining', '$remaining', Icons.hourglass_top_rounded, _gold),
                  const SizedBox(width: 8),
                  _miniStat('Success', '${ratio.toStringAsFixed(1)}%', Icons.emoji_events_rounded, const Color(0xFFE74C3C)),
                ],
              );
            }),

            const SizedBox(height: 14),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Completion', style: TextStyle(color: _textMid, fontSize: 12)),
                    Text('${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: _textDark, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: _green1.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(_green2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Suggestion chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withOpacity(0.25)),
              ),
              child: Text(
                suggestion,
                style: const TextStyle(color: _textDark, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            // 🔥 Value auto-scales within its space
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // 🔥 Label auto-scales within its space
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(color: _textMid, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                style: const TextStyle(color: _textMid, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ─── Section title ────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: _textDark, fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  // ─── Boxed Section Helper ────────────────────────────────────
  Widget _boxedSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _green1.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _green1.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────
  Widget _quickActions() {
    final actions = [
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Analysis',
        'route': '/globalAnalysis',
        'color': _green1,
      },
      {
        'icon': Icons.rate_review_rounded,
        'label': 'Review',
        'route': '/review',
        'color': _green2,
      },
      {
        'icon': Icons.emoji_events_rounded,
        'label': 'Results',
        'route': '/result',
        'color': _gold,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('⚡ Quick Actions'),
        const SizedBox(height: 12),
        Row(
          children: actions.asMap().entries.map((entry) {
            final a = entry.value;
            final isLast = entry.key == actions.length - 1;
            final color = a['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(a['route'] as String),
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(a['icon'] as IconData, color: color, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        a['label'] as String,
                        style: const TextStyle(
                            color: _textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Attempt Categories Grid ──────────────────────────────────
  Widget _attemptCategoriesGrid() {
    final items = ctrl.attemptCategories;
    if (items.isEmpty) return const SizedBox.shrink();

    final cardGradients = UIUtils.getPremiumGradients();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3, // 🔥 More height for content
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final name = item['name'] ?? '';
        final grad = cardGradients[i % cardGradients.length];
        final icon = UIUtils.getIconForName(name);

        return GestureDetector(
          onTap: () => ctrl.navigateAttemptCategory(item),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: grad.first.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const Spacer(),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Exam Categories Grid ─────────────────────────────────────
  Widget _examCategoriesGrid() {
    final items = ctrl.examCategories;
    if (items.isEmpty) {
      return const Center(
          child:
              Text('No exam categories', style: TextStyle(color: _textMid)));
    }

    final gradients = UIUtils.getPremiumGradients();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final name = item['name'] ?? '';
        final grad = gradients[i % gradients.length];
        final icon = UIUtils.getIconForName(name);

        return GestureDetector(
          onTap: () => ctrl.navigateExamCategory(item),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: grad.first.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // icon in white circle
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }
}

// ─── Search Bar Widget ────────────────────────────────────────────
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  static const _green1 = Color(0xFF1B8A4E);

  void _submit(String val) {
    if (val.trim().isNotEmpty) {
      // Unfocus keyboard first
      FocusManager.instance.primaryFocus?.unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        Get.delete<StudyController>();
        final kws = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        Get.toNamed('/studyFull', arguments: {
          "title": kws.length > 1 ? kws.join(", ") : val.trim(),
          "keywords": kws,
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: _submit,
        style: const TextStyle(color: Color(0xFF0D3320), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search topics, keywords...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _green1),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: _green1),
            onPressed: () {
              _submit(_controller.text);
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
