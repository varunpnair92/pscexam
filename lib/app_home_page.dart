import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class AppHomePage extends StatelessWidget {
  final HomeController ctrl = Get.put(HomeController());

  AppHomePage({super.key});

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);            // off-white background
  static const _surface = Colors.white;
  static const _green1 = Color(0xFF1B8A4E);        // deep green
  static const _green2 = Color(0xFF27AE60);        // mid green
  static const _green3 = Color(0xFF52C97A);        // light green
  static const _greenLight = Color(0xFFDFF4E8);    // very light green tint
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
                  _statsRow(),
                  const SizedBox(height: 24),
                  _sectionTitle('📋 Exam Categories'),
                  const SizedBox(height: 12),
                  _examCategoriesGrid(),
                  const SizedBox(height: 24),
                  _sectionTitle('📚 Study Topics'),
                  const SizedBox(height: 12),
                  _studyTopicsList(),
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
      expandedHeight: 190,
      pinned: true,
      backgroundColor: _green1,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_green1, _green2, _green3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // decorative circle
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
                    const Text(
                      'നമസ്കാരം 👋',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.4),
                    ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  // ─── Study Topics Carousel ────────────────────────────────────
  Widget _studyTopicsList() {
    final topics = ctrl.studyTopics;
    if (topics.isEmpty) {
      return const Center(
          child:
              Text('No study topics', style: TextStyle(color: _textMid)));
    }

    final shades = [
      _green1,
      _green2,
      _green3,
      const Color(0xFF145A32),
      const Color(0xFF0E6655),
      const Color(0xFF1E8449),
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: topics.length,
        itemBuilder: (_, i) {
          final topic = topics[i];
          final name = topic['name'] ?? '';
          final color = shades[i % shades.length];

          return GestureDetector(
            onTap: () => ctrl.navigateStudy(topic),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.book_outlined, color: color, size: 16),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
}
