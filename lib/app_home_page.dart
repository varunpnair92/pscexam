import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'test_controller.dart';
import 'image_slider_controller.dart';

class AppHomePage extends StatelessWidget {
  final HomeController ctrl = Get.put(HomeController());
  final testCtrl = Get.find<TestController>();
  final ImageSliderController sliderCtrl = Get.put(ImageSliderController());

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

  static const _categoryIcons = [
    Icons.rocket_launch_rounded,
    Icons.live_tv_rounded,
    Icons.workspace_premium_rounded,
    Icons.school_rounded,
    Icons.trending_up_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _green2),
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
                  _imageSlider(),
                  const SizedBox(height: 16),
                  _examStatsSection(),
                  const SizedBox(height: 16),
                  _statsRow(),
                  const SizedBox(height: 24),
                  _sectionTitle('🚀 Attempts'),
                  const SizedBox(height: 12),
                  _attemptCategoriesGrid(),
                  const SizedBox(height: 24),
                  _sectionTitle('📋 Exam Categories'),
                  const SizedBox(height: 12),
                  _examCategoriesGrid(),
                  const SizedBox(height: 24),
                  _quickActions(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── SliverAppBar ─────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
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
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, size: 7, color: Colors.white),
                          SizedBox(width: 5),
                          Text('PSC Kerala',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => Text(
                      ctrl.userName.value.isNotEmpty
                          ? 'ഹലോ, ${ctrl.userName.value.split(' ').first}! 👋'
                          : 'നമസ്കാരം 👋',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.4),
                    )),
                    const SizedBox(height: 2),
                    const Text(
                      'Ready to Crack PSC?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ── Stats tiles inside header ──
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Obx(() => Row(
                        children: [
                          _headerStat('Total', '${ctrl.totalExams.value}', Icons.list_alt_rounded),
                          const SizedBox(width: 8),
                          _headerStat('Attended', '${ctrl.attemptedExams.value}', Icons.check_circle_rounded),
                          const SizedBox(width: 8),
                          _headerStat('Remaining', '${ctrl.remainingExams.value}', Icons.hourglass_top_rounded),
                          const SizedBox(width: 8),
                          _headerStat('Success', '${ctrl.successRatio.value.toStringAsFixed(1)}%', Icons.emoji_events_rounded),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),        // closes Stack
          ),        // closes Container (ClipRRect child)
        ),          // closes ClipRRect
      ),            // closes FlexibleSpaceBar
      title: const Text(
        'PSC Kerala',
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: const Icon(Icons.person_outline,
                color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _headerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }


  // ─── Image Slider ─────────────────────────────────────────────
  Widget _imageSlider() {
    return Obx(() {
      if (sliderCtrl.isLoading.value) {
        return const SizedBox(
          height: 170,
          child: Center(child: CircularProgressIndicator(color: _green1)),
        );
      }
      if (sliderCtrl.sliderImages.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 170,
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
            child: SizedBox(height: 48, child: CircularProgressIndicator(color: _green2, strokeWidth: 2.5)),
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

            // 4 Stat Cards Row
            Row(
              children: [
                _miniStat('Total', '$total', Icons.list_alt_rounded, _green1),
                const SizedBox(width: 8),
                _miniStat('Attended', '$attempted', Icons.check_circle_rounded, _green2),
                const SizedBox(width: 8),
                _miniStat('Remaining', '$remaining', Icons.hourglass_top_rounded, _gold),
                const SizedBox(width: 8),
                _miniStat('Success', '${ratio.toStringAsFixed(1)}%', Icons.emoji_events_rounded, const Color(0xFFE74C3C)),
              ],
            ),

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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: _textMid, fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────
  Widget _statsRow() {
    return Obx(() => Row(
          children: [
            _statCard(
              icon: Icons.quiz_rounded,
              label: 'Attempts',
              value: '${ctrl.totalAttempts.value}',
              color: _green1,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (ctrl.lastExamName.value.isNotEmpty) {
                    int id = int.tryParse(ctrl.lastExamId.value) ?? 0;
                    if (id > 0 && await testCtrl.hasProgressForExam(id)) {
                      await testCtrl.loadProgress(id);
                      Get.toNamed('/exam', arguments: {'id': id});
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _gold.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: _gold, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Continue from where you stopped',
                                style: TextStyle(
                                    color: _textMid, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              ctrl.lastExamName.value.isEmpty
                                  ? 'Start an exam →'
                                  : ctrl.lastExamName.value,
                              style: const TextStyle(
                                color: _textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
              ),
            ),
          ],
        ));
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
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: _textMid, fontSize: 11)),
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

  // ─── Quick Actions ────────────────────────────────────────────
  Widget _quickActions() {
    final actions = [
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Analysis',
        'route': '/analysis',
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final name = item['name'] ?? '';

        return GestureDetector(
          onTap: () => ctrl.navigateAttemptCategory(item),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _green1.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: _green1.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _green1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch, color: _green1, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

    final gradients = [
      [const Color(0xFF1B8A4E), const Color(0xFF27AE60)],   // deep→mid green
      [const Color(0xFF27AE60), const Color(0xFF52C97A)],   // mid→light green
      [const Color(0xFF145A32), const Color(0xFF1E8449)],   // dark greens
      [const Color(0xFF52C97A), const Color(0xFF27AE60)],   // reversed
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final grad = gradients[i % gradients.length];
        final icon = _categoryIcons[i % _categoryIcons.length];
        final name = item['name'] ?? '';

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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // icon in white circle
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text('Tap to explore →',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 10)),
                    ],
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
