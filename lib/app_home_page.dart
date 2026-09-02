import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/auth_controller.dart';
import 'theme_controller.dart';
import 'home_controller.dart';
import 'test_controller.dart';
import 'exam_menu_controller.dart';
import 'story_menu_controller.dart';
import 'study_controller.dart';
import 'image_slider_controller.dart';
import 'notification_controller.dart';
import 'notification_overlay.dart';
import 'notification_overlay.dart';
import 'knowledge_capsule_overlay.dart';
import 'news_ticker_widget.dart';
import 'booster_story_widget.dart';
import 'dynamic_story_widget.dart';
import 'psc_loading_logo.dart'; // 🔥 Import Logo
import 'ui_utils.dart';
import 'exam_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHomePage extends StatelessWidget {
  final HomeController ctrl = Get.put(HomeController());
  final testCtrl = Get.find<TestController>();
  final ImageSliderController sliderCtrl = Get.put(ImageSliderController());
  final NotificationController notifCtrl = Get.put(NotificationController());

  AppHomePage({super.key});

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4); 
  static const _surface = Colors.white;
  static const _textDark = Color(0xFF0D3320);
  static const _textMid = Color(0xFF4D7A5E);
  static const _green1 = Color(0xFF1B8A4E); 
  static const _green2 = Color(0xFF27AE60); 
  static const _green3 = Color(0xFF52C97A); 
  static const _gold = Color(0xFFF5A623); 

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.instance.isDarkMode.value;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : _bg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _green1.withOpacity(isDark ? 0.2 : 0.4), width: 2),
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
                    return const Center(child: PSCLoadingLogo(size: 80));
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
                            const BoosterStoryWidget(), // 🌟 Booster Stories
                            ...ctrl.extraDynamicCategories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: DynamicStoryWidget(
                                  title: cat['title'] ?? '',
                                  items: cat['items'] ?? [],
                                ),
                              );
                            }),
                            const SizedBox(height: 4),
                            _resumeCard(), // 🔥 Premium Green Resume Card
                            const SizedBox(height: 4),
                            _imageSlider(),
                            const SizedBox(height: 16),
                            _examStatsSection(),
                            const SizedBox(height: 24),
                            if (ctrl.attemptCategories.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _boxedSection(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _sectionTitle(ctrl.attemptSectionName.value),
                                      const SizedBox(height: 16),
                                      _attemptCategoriesGrid(),
                                    ],
                                  ),
                                ),
                              ),

                            /*
                            if (ctrl.examCategories.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _boxedSection(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _sectionTitle(ctrl.examSectionName.value),
                                      const SizedBox(height: 16),
                                      _examCategoriesGrid(),
                                    ],
                                  ),
                                ),
                              ),
                            */

                            _boxedSection(child: _quickActions()),
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
    });
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
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
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
                      Obx(
                        () => Text(
                          'Hello ${ctrl.userName.value.isNotEmpty ? ctrl.userName.value : 'User'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
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
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/psc_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PSC Online',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFFD700),
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '3', // Placeholder for daily streak
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () async {
            final auth = AuthController.instance;
            await auth.fetchUserDetails(auth.userName.value);
            if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchHomeData(force: true);
            if (Get.isRegistered<ExamMenuController>()) Get.find<ExamMenuController>().fetchTree(force: true);
            if (Get.isRegistered<StoryMenuController>()) Get.find<StoryMenuController>().fetchTree(force: true);
            if (Get.isRegistered<StudyController>()) Get.find<StudyController>().fetchTree(force: true);
          },
        ),
        Obx(() => IconButton(
              icon: Icon(
                ThemeController.instance.isDarkMode.value
                    ? Icons.brightness_2_rounded
                    : Icons.brightness_5_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                ThemeController.instance.toggleTheme();
              },
            )),
        Obx(
          () => Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
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
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
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
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$answered/$total Answered",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$min min left",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green1.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
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
          color: Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green1.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
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
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: _green1,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Your Progress',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const Spacer(),
                Builder(
                  builder: (context) {
                    String badgeName = 'Novice';
                    Color badgeColor = Colors.brown.shade400;
                    IconData badgeIcon = Icons.star_border_rounded;

                    if (progress >= 0.8) {
                      badgeName = 'Master';
                      badgeColor = const Color(0xFF00E5FF); // Cyan
                      badgeIcon = Icons.diamond_rounded;
                    } else if (progress >= 0.5) {
                      badgeName = 'Expert';
                      badgeColor = const Color(0xFFFFD700); // Gold
                      badgeIcon = Icons.workspace_premium_rounded;
                    } else if (progress >= 0.2) {
                      badgeName = 'Scholar';
                      badgeColor = Colors.blueGrey.shade400; // Silver
                      badgeIcon = Icons.military_tech_rounded;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(badgeIcon, color: badgeColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            badgeName,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4 Stat Cards Grid (Responsive)
            Row(
              children: [
                _miniStat('Total', '$total', Icons.list_alt_rounded, _green1),
                const SizedBox(width: 8),
                _miniStat(
                  'Attended',
                  '$attempted',
                  Icons.check_circle_rounded,
                  _green2,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  'Remaining',
                  '$remaining',
                  Icons.hourglass_top_rounded,
                  _gold,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  'Success',
                  '${ratio.toStringAsFixed(1)}%',
                  Icons.emoji_events_rounded,
                  const Color(0xFFE74C3C),
                ),
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
                    Text(
                      'Completion',
                      style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(fontSize: 12),
                    ),
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
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(fontSize: 12),
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
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: _textMid, fontSize: 11),
            ),
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
        color: _textDark,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
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
        'icon': Icons.hub_rounded,
        'label': 'Mind Map',
        'route': '/graphView',
        'color': const Color(0xFF7F56D9),
      },
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
                        offset: const Offset(0, 2),
                      ),
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
                          fontWeight: FontWeight.w600,
                        ),
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

        return Obx(() {
          final bool hasAccess = AuthController.instance.canAccess(item);

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
              child: Stack(
                children: [
                  Opacity(
                    opacity: hasAccess ? 1.0 : 0.6,
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
                  if (!hasAccess)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // ─── Exam Categories Grid ─────────────────────────────────────
  Widget _examCategoriesGrid() {
    final items = ctrl.examCategories;
    if (items.isEmpty) {
      return const Center(
        child: Text('No exam categories', style: TextStyle(color: _textMid)),
      );
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

        return Obx(() {
          final bool hasAccess = AuthController.instance.canAccess(item);

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
              child: Stack(
                children: [
                  Opacity(
                    opacity: hasAccess ? 1.0 : 0.6,
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
                  if (!hasAccess)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
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
        Get.toNamed('/keywordSearch', arguments: {"keyword": val.trim()});
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
        style: const TextStyle(
          color: Color(0xFF0D3320),
          fontWeight: FontWeight.w500,
        ),
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
