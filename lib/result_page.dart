import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psc_exam/completed_exam_model.dart';
import 'package:psc_exam/test_controller.dart';
import 'package:psc_exam/completed_exam_controller.dart';

class ResultPage extends StatelessWidget {
  final ResultController ctrl;
  final TestController testCtrl = Get.find<TestController>();

  ResultPage({super.key}) : ctrl = Get.put(ResultController());

  // ── Palette (mirrors AppHomePage greens) ──────────────────────
  static const _bg = Color(0xFFF4FBF4);
  static const _green1 = Color(0xFF1B8A4E);
  static const _green2 = Color(0xFF27AE60);
  static const _green3 = Color(0xFF52C97A);
  static const _greenLight = Color(0xFFDFF4E8);
  static const _textDark = Color(0xFF0D3320);
  static const _textMid = Color(0xFF4D7A5E);
  static const _surface = Colors.white;
  static const _gold = Color(0xFFF5A623);

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSummaryBanner()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: Obx(() {
              if (ctrl.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _green2),
                  ),
                );
              }
              if (ctrl.errorMsg.isNotEmpty) {
                return SliverFillRemaining(child: _buildError());
              }
              if (ctrl.exams.isEmpty) {
                return SliverFillRemaining(child: _buildEmpty());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ExamCard(
                    exam: ctrl.exams[i],
                    testCtrl: testCtrl,
                    index: i,
                  ),
                  childCount: ctrl.exams.length,
                ),
              );
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: _green1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
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
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      '🏆 Results & Attempts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your latest attempts for each exam',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      title: const Text(
        'My Results',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ctrl.fetchLatestAttempts(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  // ── Summary banner ────────────────────────────────────────────
  Widget _buildSummaryBanner() {
    return Obx(() {
      final total = ctrl.exams.length;
      final totalMark = ctrl.exams.fold<int>(0, (sum, e) => sum + e.mark);
      final avg = total == 0 ? 0 : (totalMark / total).round();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green2.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: _green1.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _summaryItem('📝', total.toString(), 'Exams Done'),
            _divider(),
            _summaryItem('⭐', avg.toString(), 'Avg Score'),
            _divider(),
            _summaryItem('🔥', total == 0 ? '0' : _bestScore(), 'Best Score'),
          ],
        ),
      );
    });
  }

  String _bestScore() {
    int best = 0;
    for (final e in ctrl.exams) {
      if (e.mark > best) best = e.mark;
    }
    return best.toString();
  }

  Widget _summaryItem(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: _textMid, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: _greenLight);
  }

  // ── Empty / Error states ──────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: _greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.quiz_outlined, color: _green2, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'No completed exams yet',
            style: TextStyle(
              color: _textDark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take an exam and your results will appear here.',
            style: TextStyle(color: _textMid, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green1,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Go Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: _textMid, size: 48),
          const SizedBox(height: 16),
          Text(
            ctrl.errorMsg.value,
            style: const TextStyle(color: _textMid, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ctrl.fetchLatestAttempts(),
            icon: const Icon(Icons.refresh_rounded, color: _green1),
            label: const Text('Retry', style: TextStyle(color: _green1)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _green1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual exam card ──────────────────────────────────────────
class _ExamCard extends StatelessWidget {
  final CompletedExam exam;
  final TestController testCtrl;
  final int index;

  const _ExamCard({
    required this.exam,
    required this.testCtrl,
    required this.index,
  });

  static const _green1 = Color(0xFF1B8A4E);
  static const _green2 = Color(0xFF27AE60);
  static const _greenLight = Color(0xFFDFF4E8);
  static const _textDark = Color(0xFF0D3320);
  static const _textMid = Color(0xFF4D7A5E);
  static const _gold = Color(0xFFF5A623);
  static const _surface = Colors.white;

  Color get _scoreColor {
    if (exam.mark >= 80) return _green1;
    if (exam.mark >= 50) return _green2;
    if (exam.mark >= 30) return _gold;
    return Colors.redAccent;
  }

  String get _grade {
    if (exam.mark >= 80) return 'Excellent';
    if (exam.mark >= 60) return 'Good';
    if (exam.mark >= 40) return 'Average';
    return 'Needs Work';
  }

  IconData get _gradeIcon {
    if (exam.mark >= 80) return Icons.emoji_events_rounded;
    if (exam.mark >= 60) return Icons.thumb_up_rounded;
    if (exam.mark >= 40) return Icons.trending_up_rounded;
    return Icons.refresh_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: _green1.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Header strip ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_green1.withOpacity(0.08), Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  // Index circle
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_green1, _green2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.examName,
                          style: const TextStyle(
                            color: _textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Exam ID: ${exam.examids}  •  Attempt #${exam.attempt}',
                          style: const TextStyle(color: _textMid, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // Score badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _scoreColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _scoreColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${exam.mark}',
                      style: TextStyle(
                        color: _scoreColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Grade + Actions row ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Grade chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_gradeIcon, color: _scoreColor, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          _grade,
                          style: TextStyle(
                            color: _scoreColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Review button
                  OutlinedButton.icon(
                    onPressed: () async {
                      testCtrl.examId = exam.examids;
                      await testCtrl.fetchResult();
                      testCtrl.current.value = 0;
                      Get.toNamed('/review');
                    },
                    icon: const Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: _green1,
                    ),
                    label: const Text(
                      'Review',
                      style: TextStyle(color: _green1, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _green1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Retake button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('last_exam_name', exam.examName);
                      prefs.setString('last_exam_id', exam.examids.toString());

                      bool resume = await testCtrl.hasProgressForExam(
                        exam.examids,
                      );
                      if (resume) {
                        await testCtrl.loadProgress(exam.examids);
                        Get.defaultDialog(
                          title: "Resume Exam",
                          middleText:
                              "You have reached question ${testCtrl.current.value + 1} of ${testCtrl.questions.length}. Resume or restart?",
                          textCancel: "Restart",
                          textConfirm: "Resume",
                          onConfirm: () {
                            Get.back();
                            Get.toNamed(
                              '/exam',
                              arguments: {'id': exam.examids},
                            );
                          },
                          onCancel: () async {
                            Get.back();
                            await testCtrl.clearProgress(exam.examids);
                            testCtrl.questions.clear();
                            testCtrl.examId = exam.examids;
                            await testCtrl.loadQuestions(exam.examids);
                            Get.toNamed(
                              '/exam',
                              arguments: {'id': exam.examids},
                            );
                          },
                        );
                      } else {
                        testCtrl.questions.clear();
                        testCtrl.examId = exam.examids;
                        await testCtrl.loadQuestions(exam.examids);
                        Get.toNamed('/exam', arguments: {'id': exam.examids});
                      }
                    },
                    icon: const Icon(
                      Icons.replay_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Retake',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 0,
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
}
