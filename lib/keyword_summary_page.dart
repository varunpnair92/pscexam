import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'keyword_summary_controller.dart';
import 'summary_card_model.dart';

class KeywordSummaryPage extends StatelessWidget {
  final KeywordSummaryController ctrl = Get.put(KeywordSummaryController());

  // ─── Theme Palette ───────────────────────────────────────────
  static const _bg = Color(0xFFF7FAF7);
  static const _surface = Colors.white;
  static const _greenPrimary = Color(0xFF1B8A4E);
  static const _greenLight = Color(0xFFE8F5E9);
  static const _textDark = Color(0xFF0F2E1E);
  static const _textMid = Color(0xFF4A6B56);
  static const _textMuted = Color(0xFF8FA899);

  KeywordSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ctrl.handleBack();
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
            onPressed: ctrl.handleBack,
          ),
          title: Obx(() => Text(
            ctrl.currentKeyword.value.isEmpty ? "Summary" : ctrl.currentKeyword.value,
            style: const TextStyle(
              color: _textDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── Search bar ──
            _buildSearchBar(),

            // ── Tab selector when both summary & children exist ──
            Obx(() {
              final bool showTabs = ctrl.responseType.value == 'both' ||
                  (ctrl.childrenList.isNotEmpty &&
                      (ctrl.summaryCards.isNotEmpty || ctrl.summaryData.isNotEmpty));

              if (!showTabs || ctrl.isLoading.value) {
                return const SizedBox.shrink();
              }
              return _buildTabSelector();
            }),

            // ── Main Content Area ──
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _greenPrimary),
                  );
                }

                if (ctrl.responseType.value == 'error') {
                  return _buildErrorState();
                }

                if (ctrl.responseType.value == 'empty') {
                  return _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: "വിവരം ലഭ്യമല്ല",
                    subtitle: ctrl.errorMessage.value.isNotEmpty
                        ? ctrl.errorMessage.value
                        : "ഈ വിഷയത്തിൽ സംഗ്രഹം കണ്ടെത്താനായില്ല.",
                  );
                }

                // If both are available, show based on active tab
                if (ctrl.responseType.value == 'both') {
                  return ctrl.activeTab.value == 0
                      ? _buildSummaryView()
                      : _buildChildrenView();
                }

                // Parent only (only children)
                if (ctrl.responseType.value == 'parent') {
                  if (ctrl.childrenList.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.account_tree_outlined,
                      title: "ഉപവിഷയങ്ങൾ ലഭ്യമല്ല",
                      subtitle: "ഉപവിഷയങ്ങൾ ഒന്നും ചേർത്തിട്ടില്ല.",
                    );
                  }
                  return _buildChildrenView();
                }

                // Child only (only summary)
                if (ctrl.responseType.value == 'child') {
                  if (ctrl.summaryCards.isEmpty && ctrl.summaryData.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.article_outlined,
                      title: "സംഗ്രഹം ലഭ്യമല്ല",
                      subtitle: "സംഗ്രഹ വിവരങ്ങൾ ലഭ്യമല്ല.",
                    );
                  }
                  return _buildSummaryView();
                }

                // Unknown / initial fallback
                return _buildEmptyState(
                  icon: Icons.search_rounded,
                  title: "തിരയുക",
                  subtitle: "സംഗ്രഹം കാണാൻ ഒരു വിഷയം തിരയുക.",
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    final TextEditingController textCtrl = TextEditingController();
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _greenPrimary.withValues(alpha: 0.15), width: 1.2),
        ),
        child: TextField(
          controller: textCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ctrl.onSearchSubmit(val.trim());
              textCtrl.clear();
            }
          },
          style: const TextStyle(color: _textDark, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Search keywords (e.g. കേരള മുഖ്യമന്ത്രിമാർ)...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: _greenPrimary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── Tab Selector ───────────────────────────────────────────
  Widget _buildTabSelector() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _greenPrimary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ctrl.activeTab.value = 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: ctrl.activeTab.value == 0 ? _greenPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: ctrl.activeTab.value == 0
                        ? [
                            BoxShadow(
                              color: _greenPrimary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_rounded,
                        size: 16,
                        color: ctrl.activeTab.value == 0 ? Colors.white : _textMid,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "സംഗ്രഹം (Summary)",
                        style: TextStyle(
                          color: ctrl.activeTab.value == 0 ? Colors.white : _textMid,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => ctrl.activeTab.value = 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: ctrl.activeTab.value == 1 ? _greenPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: ctrl.activeTab.value == 1
                        ? [
                            BoxShadow(
                              color: _greenPrimary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_tree_rounded,
                        size: 16,
                        color: ctrl.activeTab.value == 1 ? Colors.white : _textMid,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ഉപവിഷയങ്ങൾ (${ctrl.childrenList.length})",
                        style: TextStyle(
                          color: ctrl.activeTab.value == 1 ? Colors.white : _textMid,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary View (Cards or Lines) ──────────────────────────
  Widget _buildSummaryView() {
    if (ctrl.summaryCards.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: ctrl.summaryCards.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final card = ctrl.summaryCards[index];
          return _buildRichCard(context, card);
        },
      );
    }

    // Fallback to plain summary lines
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: ctrl.summaryData.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final line = ctrl.summaryData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _greenPrimary.withValues(alpha: 0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.check_circle_rounded, color: _greenPrimary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  line,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 14.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Rich Summary Card ──────────────────────────────────────
  Widget _buildRichCard(BuildContext context, SummaryCardModel card) {
    final color = card.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(card.icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    card.cleanTitle,
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                  ),
                ),
                // Item count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${card.items.length}",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: _textMid,
                  tooltip: "Copy Points",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: card.toShareText()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${card.cleanTitle} വിവരങ്ങൾ കോപ്പി ചെയ്തു"),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: _greenPrimary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Card Items ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(card.items.length, (i) {
                final item = card.items[i];
                final isEven = i % 2 == 0;

                if (item.hasValue) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: isEven ? _bg.withValues(alpha: 0.6) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.value!,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Plain text bullet point
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isEven ? _bg.withValues(alpha: 0.6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.rawText,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 13.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-topics (Children) View ─────────────────────────────
  Widget _buildChildrenView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: ctrl.childrenList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final child = ctrl.childrenList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _greenPrimary.withValues(alpha: 0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ctrl.onKeywordTap(child.name, kid: child.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _greenLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: _greenPrimary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        child.name,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _textMuted,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Error State ────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
            ),
            const SizedBox(height: 18),
            const Text(
              "ഡാറ്റ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല",
              style: TextStyle(
                color: _textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ctrl.errorMessage.value.isNotEmpty
                  ? ctrl.errorMessage.value
                  : "നെറ്റ്‌വർക്ക് കണക്ഷൻ പരിശോധിക്കുക.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textMid, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ctrl.fetchSummary(
                ctrl.currentKeyword.value,
                kid: ctrl.currentKid.value,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("വീണ്ടും ശ്രമിക്കുക (Try Again)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _greenPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _greenLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: _greenPrimary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: _textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textMid, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}
