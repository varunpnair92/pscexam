import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_theme.dart';
import 'exam_battle_controller.dart';
import 'exam_battle_model.dart';

class ExamBattlePage extends StatelessWidget {
  const ExamBattlePage({super.key});

  static const Color _primary = Color(0xFF1B8A4E);
  static const Color _primaryDark = Color(0xFF0D3320);
  static const Color _accentOrange = Color(0xFFFF9800);
  static const Color _gold = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final ExamBattleController ctrl = Get.put(ExamBattleController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ─── BACKGROUND ───
          AppTheme.buildImmersiveBackground(context),

          SafeArea(
            child: Column(
              children: [
                // ─── TOP APP BAR ───
                _buildAppBar(ctrl),

                // ─── TAB SWITCHER ───
                _buildTabBar(ctrl),

                // ─── CONTENT BODY ───
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primary),
                      );
                    }

                    if (ctrl.errorMessage.value.isNotEmpty &&
                        ctrl.battles.isEmpty &&
                        ctrl.results.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              ctrl.errorMessage.value,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => ctrl.fetchBattleExams(),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text("Retry"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                              ),
                            )
                          ],
                        ),
                      );
                    }

                    return ctrl.selectedTab.value == 0
                        ? _buildBattlesTab(ctrl)
                        : _buildResultsTab(ctrl);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ExamBattleController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark, size: 20),
            onPressed: () => Get.back(),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  "Exam Battle Arena",
                  style: TextStyle(
                    color: _primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  "Compete Live & Compare Rankings",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _primary, size: 24),
            tooltip: "Refresh Battles",
            onPressed: () => ctrl.fetchBattleExams(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ExamBattleController ctrl) {
    return Obx(() {
      final int sel = ctrl.selectedTab.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tab 0: Active Battles
            Expanded(
              child: GestureDetector(
                onTap: () => ctrl.selectedTab.value = 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel == 0 ? _primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        size: 18,
                        color: sel == 0 ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Battles",
                        style: TextStyle(
                          color: sel == 0 ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (ctrl.battles.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sel == 0 ? Colors.white.withOpacity(0.25) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${ctrl.battles.length}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: sel == 0 ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Tab 1: Results
            Expanded(
              child: GestureDetector(
                onTap: () => ctrl.selectedTab.value = 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel == 1 ? _primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard_rounded,
                        size: 18,
                        color: sel == 1 ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Results & Ranks",
                        style: TextStyle(
                          color: sel == 1 ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════
  // ─── TAB 1: BATTLES (ARENA & UPCOMING)
  // ════════════════════════════════════════════════════════
  Widget _buildBattlesTab(ExamBattleController ctrl) {
    if (ctrl.battles.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ctrl.fetchBattleExams(),
        color: _primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Icon(Icons.sports_kabaddi_rounded, size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "No Battle Exams Scheduled",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              "Daily battles will appear here. Pull down to refresh.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ctrl.fetchBattleExams(),
      color: _primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: ctrl.battles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final item = ctrl.battles[i];
          return _buildBattleCard(context, ctrl, item);
        },
      ),
    );
  }

  Widget _buildBattleCard(
      BuildContext context, ExamBattleController ctrl, BattleExamItem item) {
    return Obx(() {
      // Trigger reactivity whenever currentTime ticks
      ctrl.currentTime.value;
      final bool live = ctrl.canAttend(item);
      final bool hasAttended = item.hasAttended;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: live ? _primary.withOpacity(0.5) : Colors.grey.shade200,
            width: live ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: live
                  ? _primary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Bar inside Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: live
                    ? _primary.withOpacity(0.08)
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasAttended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.blue, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Attended",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (live)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "LIVE NOW",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _accentOrange.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, color: _accentOrange, size: 13),
                          SizedBox(width: 4),
                          Text(
                            "Upcoming",
                            style: TextStyle(
                              color: _accentOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.specialization,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Metadata Pills
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.quiz_outlined,
                        "${item.totalQuestions} Questions",
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.timer_outlined,
                        "${(item.totalQuestions * 0.75).round()} Mins",
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── COUNTDOWN TIMER SECTION (If upcoming) ───
                  if (!live && item.startTime != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accentOrange.withOpacity(0.08),
                            _gold.withOpacity(0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _accentOrange.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.alarm_rounded, color: _accentOrange, size: 20),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "BATTLE STARTS IN",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: _accentOrange,
                                    ),
                                  ),
                                  Text(
                                    _formatScheduledTime(item.startTime!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _accentOrange.withOpacity(0.4)),
                            ),
                            child: Text(
                              ctrl.formatCountdown(item.startTime),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _accentOrange,
                                fontFamily: "monospace",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── ACTION BUTTON ───
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: hasAttended
                        ? OutlinedButton.icon(
                            onPressed: () {
                              ctrl.selectedTab.value = 1; // Go to results
                            },
                            icon: const Icon(Icons.leaderboard_outlined, size: 18),
                            label: const Text("View Battle Standing"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primary,
                              side: const BorderSide(color: _primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: live
                                ? () => ctrl.attendExam(item)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: live ? _primary : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              elevation: live ? 2 : 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  live ? Icons.play_arrow_rounded : Icons.lock_clock_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  live ? "Attend Exam Now" : "Waiting for Start Time",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════
  // ─── TAB 2: RESULTS & POSITION RANKING
  // ════════════════════════════════════════════════════════
  Widget _buildResultsTab(ExamBattleController ctrl) {
    if (ctrl.results.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ctrl.fetchBattleExams(),
        color: _primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Icon(Icons.emoji_events_outlined, size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "No Battle Results Yet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              "Once exam battles are completed and results are published, ranks and positions will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ctrl.fetchBattleExams(),
      color: _primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: ctrl.results.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final item = ctrl.results[i];
          return _buildResultCard(context, ctrl, item);
        },
      ),
    );
  }

  Widget _buildResultCard(
      BuildContext context, ExamBattleController ctrl, BattleExamItem item) {
    final bool isPublished = item.resultPublished;
    final userResult = item.userResult;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.specialization,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _primaryDark,
                        ),
                      ),
                      if (item.startTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${_formatScheduledTime(item.startTime!)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPublished ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPublished ? Colors.green.shade300 : Colors.amber.shade400,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPublished ? Icons.check_circle_outline_rounded : Icons.lock_clock_rounded,
                        size: 13,
                        color: isPublished ? Colors.green.shade700 : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPublished ? "Published" : "Pending",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPublished ? Colors.green.shade700 : Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ─── USER RESULT & POSITION SECTION ───
          if (isPublished) ...[
            if (userResult != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primary.withOpacity(0.06),
                      const Color(0xFF27AE60).withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Trophy / Position Badge
                        _buildRankBadge(userResult.rank),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "YOUR BATTLE STANDING",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: _primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Rank #${userResult.rank} of ${userResult.totalParticipants} Participants",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Marks Container
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${userResult.mark}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                              Text(
                                "/ ${userResult.totalMarks}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.grey.shade500, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "You did not participate in this battle.",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),

            // Top Rankers preview
            if (item.topRankers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: _gold, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      "Top Rankers",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${item.totalParticipants} Participants",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: item.topRankers.map((r) => _buildRankerTile(r)).toList(),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
            ],
          ] else ...[
            // Result NOT yet published
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty_rounded, color: Colors.amber.shade800, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Result Awaiting Publication",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.hasAttended
                                ? "Your exam answers are submitted. The marks and rankings will appear here once the administrator publishes results."
                                : "The administrator has not published the results for this battle exam yet.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color bg;
    Widget icon;

    if (rank == 1) {
      bg = const Color(0xFFFFD700); // Gold
      icon = const Text("🥇", style: TextStyle(fontSize: 22));
    } else if (rank == 2) {
      bg = const Color(0xFFC0C0C0); // Silver
      icon = const Text("🥈", style: TextStyle(fontSize: 22));
    } else if (rank == 3) {
      bg = const Color(0xFFCD7F32); // Bronze
      icon = const Text("🥉", style: TextStyle(fontSize: 22));
    } else {
      bg = Colors.white;
      icon = Text(
        "#$rank",
        style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryDark, fontSize: 16),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildRankerTile(BattleRanker r) {
    String medal = "";
    if (r.rank == 1) medal = "🥇";
    if (r.rank == 2) medal = "🥈";
    if (r.rank == 3) medal = "🥉";

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (medal.isNotEmpty)
            Text(medal, style: const TextStyle(fontSize: 16))
          else
            Text(
              "#${r.rank}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              r.fullname,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _primaryDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${r.mark} Marks",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScheduledTime(DateTime dt) {
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[local.month - 1];
    final h = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? "PM" : "AM";
    final min = local.minute.toString().padLeft(2, '0');
    return "$m ${local.day}, $h:$min $ampm";
  }
}
