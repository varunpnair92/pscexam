import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_theme.dart';
import 'timeline_controller.dart';
import 'timeline_model.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimelineController ctrl = Get.put(TimelineController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          AppTheme.buildImmersiveBackground(context),
          SafeArea(
            child: Column(
              children: [
                // ── App Bar ──
                Obx(() => AppTheme.buildPremiumAppBar(
                      title: ctrl.currentKeyword.value.isNotEmpty
                          ? "Timeline: ${ctrl.currentKeyword.value}"
                          : ctrl.pageTitle.value,
                      onBack: () => Get.back(),
                    )),

                // ── Search Window (Only when opened without node keyword) ──
                Obx(() {
                  if (ctrl.hasInitialKeyword.value) {
                    return const SizedBox.shrink();
                  }
                  return AppTheme.buildPremiumSearchBar(
                    controller: ctrl.searchCtrl,
                    hintText: "Enter keyword (e.g., കേരള സമരങ്ങൾ)...",
                    onChanged: (val) {
                      if (val.isEmpty) {
                        ctrl.currentKeyword.value = "";
                      }
                    },
                    onClear: ctrl.clearSearch,
                    onSubmitted: (query) => ctrl.onSearchSubmit(query),
                    onSearchTap: () => ctrl.onSearchSubmit(ctrl.searchCtrl.text),
                  );
                }),

                // ── Body Content ──
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      );
                    }

                    if (ctrl.currentKeyword.value.isEmpty && ctrl.timelineYears.isEmpty) {
                      return _buildInitialSearchState(context, ctrl);
                    }

                    if (ctrl.errorMessage.value.isNotEmpty && ctrl.timelineYears.isEmpty) {
                      return _buildEmptyOrErrorState(ctrl);
                    }

                    return _buildTimelineList(context, ctrl);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Initial State when no keyword is specified ──
  Widget _buildInitialSearchState(BuildContext context, TimelineController ctrl) {
    final suggestions = ["കേരള സമരങ്ങൾ", "സ്വാതന്ത്ര്യ സമരം", "സൈലന്റ് വാലി", "വിമോചന സമരം"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timeline_rounded,
              size: 64,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Explore Keyword Timeline",
            style: AppTheme.titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Enter a keyword in the search bar above to view chronological historical events and summaries.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Popular Topics:",
              style: TextStyle(
                color: AppTheme.textDark.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestions.map((topic) {
              return InkWell(
                onTap: () {
                  ctrl.searchCtrl.text = topic;
                  ctrl.fetchTimeline(topic);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_edu_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        topic,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Error / No Results State ──
  Widget _buildEmptyOrErrorState(TimelineController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              ctrl.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ctrl.fetchTimeline(ctrl.searchCtrl.text),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry Search"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vertical Timeline View ──
  Widget _buildTimelineList(BuildContext context, TimelineController ctrl) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: ctrl.timelineYears.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final yearItem = ctrl.timelineYears[index];
        final gradient = AppTheme.premiumGradients[index % AppTheme.premiumGradients.length];

        return AppTheme.buildStaggeredAnimation(
          index: index,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year Badge Node
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      yearItem.year,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Timeline Content Tree with vertical connecting line
              Stack(
                children: [
                  // Vertical Line
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 17,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Events under this year
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: yearItem.events.map((event) {
                        return _buildEventCard(context, yearItem.year, event, gradient);
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ── Event Card ──
  Widget _buildEventCard(
    BuildContext context,
    String year,
    TimelineEvent event,
    List<Color> gradient,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showSummaryBottomSheet(context, year, event, gradient),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip & Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (event.category.isNotEmpty)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        Text(
                          "Summary",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Event Keyword / Title
                Text(
                  event.keyword,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: TextStyle(
                      color: AppTheme.textMid,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Show Detail Summary Bottom Sheet when clicked ──
  void _showSummaryBottomSheet(
    BuildContext context,
    String year,
    TimelineEvent event,
    List<Color> gradient,
  ) {
    final List<String> summaryLines = event.summary
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      year,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.keyword,
                      style: AppTheme.titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Get.back(),
                  )
                ],
              ),
            ),
            const Divider(height: 20),

            // Detailed Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (event.description.isNotEmpty) ...[
                      const Text(
                        "Description",
                        style: TextStyle(
                          color: AppTheme.textMid,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Text(
                      "Summary Points",
                      style: TextStyle(
                        color: AppTheme.textMid,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (summaryLines.isEmpty)
                      Text(
                        event.summary.isNotEmpty ? event.summary : "No additional summary available.",
                        style: const TextStyle(color: AppTheme.textDark, fontSize: 14, height: 1.5),
                      )
                    else
                      Column(
                        children: summaryLines.map((line) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.primary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    line,
                                    style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 14,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
