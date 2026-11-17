import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'keyword_summary_controller.dart';

class KeywordSummaryPage extends StatelessWidget {
  final KeywordSummaryController ctrl = Get.put(KeywordSummaryController());

  // Rotating pastel gradients for swiping cards (Knowledge Capsule theme)
  static const List<List<Color>> _cardGradients = [
    [Color(0xFFEBF4FF), Color(0xFFF3E8FF), Colors.white], // Soft Blue to Lavender
    [Color(0xFFE6FFFA), Color(0xFFF0FDF4), Colors.white], // Soft Teal to Mint
    [Color(0xFFFFFBEB), Color(0xFFFFF7ED), Colors.white], // Warm Amber to Peach
    [Color(0xFFFFF1F2), Color(0xFFFDF2F8), Colors.white], // Soft Rose to Pink
    [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Colors.white], // Indigo to Sky
  ];

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
        backgroundColor: Colors.grey.shade100, // Light background for cards
        appBar: AppBar(
          title: Obx(() => Text(
            ctrl.currentKeyword.value.isEmpty ? "Knowledge Capsule" : ctrl.currentKeyword.value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
            onPressed: ctrl.handleBack,
          ),
          actions: [
            Obx(() {
              if (ctrl.childrenList.isEmpty || ctrl.isLoading.value) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(
                  ctrl.activeTab.value == 1 ? Icons.amp_stories_rounded : Icons.account_tree_outlined,
                  color: Colors.indigo.shade700,
                ),
                tooltip: ctrl.activeTab.value == 1 ? "View Cards" : "View Sub-topics (${ctrl.childrenList.length})",
                onPressed: () {
                  ctrl.activeTab.value = ctrl.activeTab.value == 0 ? 1 : 0;
                },
              );
            }),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Tab bar toggle if both Cards and Sub-topics exist
            Obx(() {
              final bool showTabs = ctrl.childrenList.isNotEmpty && ctrl.capsuleCards.isNotEmpty;
              if (!showTabs || ctrl.isLoading.value) {
                return const SizedBox.shrink();
              }
              return _buildTabSelector();
            }),

            // Main Body Content
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                }

                if (ctrl.responseType.value == 'error') {
                  return _buildErrorState();
                }

                if (ctrl.responseType.value == 'empty') {
                  return _buildEmptyState(
                    title: "വിവരം ലഭ്യമല്ല",
                    subtitle: ctrl.errorMessage.value.isNotEmpty
                        ? ctrl.errorMessage.value
                        : "ഈ വിഷയത്തിൽ വിവരങ്ങൾ കണ്ടെത്താനായില്ല.",
                  );
                }

                // If sub-topics tab is actively selected
                if (ctrl.activeTab.value == 1 && ctrl.childrenList.isNotEmpty) {
                  return _buildChildrenView();
                }

                // If only children exist (parent node without summary)
                if (ctrl.capsuleCards.isEmpty && ctrl.childrenList.isNotEmpty) {
                  return _buildChildrenView();
                }

                // Swiping Knowledge Capsule Cards
                if (ctrl.capsuleCards.isNotEmpty) {
                  return _buildCapsuleCardsView();
                }

                return _buildEmptyState(
                  title: "സംഗ്രഹം ലഭ്യമല്ല",
                  subtitle: "ഈ വിഷയത്തിൽ സംഗ്രഹം ചേർത്തിട്ടില്ല.",
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    final TextEditingController textCtrl = TextEditingController();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
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
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Search keywords (e.g. കേരള മുഖ്യമന്ത്രിമാർ)...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.indigo.shade600, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ─── Tab Toggle (Cards vs Sub-topics) ──────────────────────────
  Widget _buildTabSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ctrl.activeTab.value = 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: ctrl.activeTab.value == 0 ? Colors.indigo.shade800 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: ctrl.activeTab.value == 0
                        ? [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.25),
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
                        Icons.amp_stories_rounded,
                        size: 16,
                        color: ctrl.activeTab.value == 0 ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "കാപ്സ്യൂൾ (${ctrl.capsuleCards.length})",
                        style: TextStyle(
                          color: ctrl.activeTab.value == 0 ? Colors.white : Colors.black87,
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: ctrl.activeTab.value == 1 ? Colors.indigo.shade800 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: ctrl.activeTab.value == 1
                        ? [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.25),
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
                        color: ctrl.activeTab.value == 1 ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ഉപവിഷയങ്ങൾ (${ctrl.childrenList.length})",
                        style: TextStyle(
                          color: ctrl.activeTab.value == 1 ? Colors.white : Colors.black87,
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

  // ─── Swiping Knowledge Capsule Cards ───────────────────────────
  Widget _buildCapsuleCardsView() {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: ctrl.capsuleCards.length,
      itemBuilder: (context, index) {
        final card = ctrl.capsuleCards[index];
        final gradient = _cardGradients[index % _cardGradients.length];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading with copy button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, color: Colors.indigo.shade400, size: 20),
                    tooltip: "Copy Points",
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: "${card.title}\n\n${card.content}"));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${card.title} കോപ്പി ചെയ്തു"),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1.5),

              // Summary content (large, clean, bold readable typography)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    card.content,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.7,
                      fontWeight: FontWeight.w600, // bolder for readability
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Footer indicator
              Center(
                child: Text(
                  "${index + 1} of ${ctrl.capsuleCards.length}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
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

  // ─── Sub-topics List View ──────────────────────────────────────
  Widget _buildChildrenView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: ctrl.childrenList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final child = ctrl.childrenList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                ctrl.onKeywordTap(child.name, kid: child.id);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.purple.shade50],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_tree_rounded,
                        color: Colors.indigo.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        child.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 16,
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

  // ─── Error State ───────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ctrl.errorMessage.value.isNotEmpty
                  ? ctrl.errorMessage.value
                  : "നെറ്റ്‌വർക്ക് കണക്ഷൻ പരിശോധിക്കുക.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => ctrl.fetchSummary(
                ctrl.currentKeyword.value,
                kid: ctrl.currentKid.value,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("വീണ്ടും ശ്രമിക്കുക (Try Again)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────
  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.amp_stories_outlined, size: 48, color: Colors.indigo.shade400),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
