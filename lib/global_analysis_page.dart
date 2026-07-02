import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class GlobalAnalysisPage extends StatelessWidget {
  final HomeController ctrl = Get.find<HomeController>();

  GlobalAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4),
      appBar: AppBar(
        title: const Text("Performance Analysis", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B8A4E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.statsLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A4E)));
        }

        final total = ctrl.totalExams.value;
        final attempted = ctrl.attemptedExams.value;
        final remaining = ctrl.remainingExams.value;
        final ratio = ctrl.successRatio.value;

        // 🔥 NEW QUESTION STATS
        final questionsAttended = ctrl.totalQuestionsAttended.value;
        final correctAnswers = ctrl.totalCorrectAnswers.value;
        final wrongAnswers = (questionsAttended - correctAnswers).clamp(0, 999999);
        final questionRatio = ctrl.questionSuccessRatio.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGrowthHeader(ratio),
              const SizedBox(height: 24),
              _buildTimeAnalysis(ctrl.cumulativeTime, attempted),
              const SizedBox(height: 24),
              _buildQuestionStats(questionsAttended, correctAnswers, wrongAnswers, questionRatio),
              const SizedBox(height: 24),
              _buildStatsGrid(total, attempted, remaining, ratio),
              const SizedBox(height: 24),
              _buildActivityChart(attempted),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGrowthHeader(double ratio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B8A4E), Color(0xFF52C97A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1B8A4E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overall Success Rate", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${ratio.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 8.0),
                child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ratio >= 70 ? "You are on track consistently! Keep it up 🔥" : "Keep studying, you'll reach your goal soon 🎯",
            style: const TextStyle(color: Colors.white, fontSize: 13),
          )
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis(Map timeData, int attempted) {
    if (timeData.isEmpty) return const SizedBox.shrink();

    int totalSec = 0;
    if (timeData["Total"] is int) totalSec = timeData["Total"];
    final int avgSec = attempted > 0 ? (totalSec ~/ attempted) : totalSec;
    
    // Find categories and sort
    Map<String, int> categories = {};
    timeData.forEach((key, value) {
      if (key != "Total" && value is int) {
        categories[key] = value;
      }
    });

    String strongCategory = "None";
    String weakCategory = "None";
    
    if (categories.isNotEmpty) {
      var sortedCats = categories.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
        
      strongCategory = sortedCats.first.key; // least time taken
      weakCategory = sortedCats.last.key;    // most time taken
    }

    String formatTime(int sec) {
      int m = sec ~/ 60;
      int s = sec % 60;
      if (m > 0) return "${m}m ${s}s";
      return "${s}s";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Time Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3320))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeStatBox("Avg Exam Time", formatTime(avgSec), Icons.timer, Colors.blue),
              _timeStatBox("Total Time", formatTime(totalSec), Icons.access_time_filled, Colors.orange),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _categoryStrength("Strongest", strongCategory, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _categoryStrength("Needs Work", weakCategory, Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text("Category Breakdown", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            ...categories.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(color: Colors.black54)),
                  Text(formatTime(e.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D3320))),
                ],
              ),
            )),
          ]
        ],
      ),
    );
  }

  Widget _timeStatBox(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D3320))),
      ],
    );
  }

  Widget _categoryStrength(String title, String cat, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(cat, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // ─── Question Accuracy Donut Chart ───
  Widget _buildQuestionStats(int attended, int correct, int wrong, double ratio) {
    final hasData = attended > 0;
    final cVal = hasData ? correct.toDouble() : 1.0;
    final wVal = hasData ? wrong.toDouble() : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Global Question Accuracy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3320))),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(value: cVal, color: const Color(0xFF27AE60), showTitle: false, radius: 15),
                          PieChartSectionData(value: wVal, color: const Color(0xFFE74C3C), showTitle: false, radius: 15),
                          if (!hasData) PieChartSectionData(value: 1, color: Colors.grey.shade200, showTitle: false, radius: 15),
                        ],
                      ),
                    ),
                    Text(
                      "${ratio.toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D3320)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem("Attended", attended.toString(), Colors.blueGrey),
                    const SizedBox(height: 16),
                    _legendItem("Correct", correct.toString(), const Color(0xFF27AE60)),
                    const SizedBox(height: 16),
                    _legendItem("Wrong", wrong.toString(), const Color(0xFFE74C3C)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatsGrid(int total, int attempted, int remaining, double ratio) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _statCard("Total Exams", total.toString(), Icons.list_alt_rounded, Colors.blue),
        _statCard("Attempted", attempted.toString(), Icons.check_circle_rounded, const Color(0xFF1B8A4E)),
        _statCard("Remaining", remaining.toString(), Icons.hourglass_top_rounded, Colors.orange),
        _statCard("Accuracy", "${ratio.toStringAsFixed(0)}%", Icons.track_changes_rounded, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D3320))),
        ],
      ),
    );
  }

  Widget _buildActivityChart(int attempted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity (Mock)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3320))),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'M'; break;
                          case 1: text = 'T'; break;
                          case 2: text = 'W'; break;
                          case 3: text = 'T'; break;
                          case 4: text = 'F'; break;
                          case 5: text = 'S'; break;
                          case 6: text = 'S'; break;
                          default: text = ''; break;
                        }
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, (attempted % 3).toDouble() + 1),
                  _makeGroupData(1, (attempted % 4).toDouble() + 2),
                  _makeGroupData(2, (attempted % 2).toDouble() + 3),
                  _makeGroupData(3, (attempted % 5).toDouble() + 1),
                  _makeGroupData(4, (attempted % 6).toDouble() + 2),
                  _makeGroupData(5, (attempted % 2).toDouble() + 4),
                  _makeGroupData(6, (attempted % 7).toDouble() + 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF52C97A),
          width: 12,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: const Color(0xFF1B8A4E).withOpacity(0.05),
          ),
        ),
      ],
    );
  }
}
