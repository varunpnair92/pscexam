import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'keyword_summary_controller.dart';

class KeywordSummaryPage extends StatelessWidget {
  final KeywordSummaryController ctrl = Get.put(KeywordSummaryController());

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);            // off-white background
  static const _green1 = Color(0xFF1B8A4E);        // deep green
  static const _green2 = Color(0xFF27AE60);        // lighter green
  static const _textDark = Color(0xFF0D3320);      // dark green text
  static const _textMid = Color(0xFF4D7A5E);

  KeywordSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ctrl.handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
            onPressed: ctrl.handleBack,
          ),
          title: Obx(() => Text(
            ctrl.currentKeyword.value.isEmpty ? "Summary" : ctrl.currentKeyword.value,
            style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 18),
          )),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── Search bar to initiate new searches ──
            _searchBar(),
            
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: _green1));
                }
      
                if (ctrl.responseType.value == 'error') {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    message: "An error occurred while fetching data.",
                  );
                }
      
                if (ctrl.responseType.value == 'parent') {
                  if (ctrl.childrenList.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.account_tree_outlined,
                      message: "No sub-topics found for this keyword.",
                    );
                  }
                  return _buildParentView();
                }
      
                if (ctrl.responseType.value == 'child') {
                  if (ctrl.summaryData.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.article_outlined,
                      message: "No summary data available.",
                    );
                  }
                  return _buildChildView();
                }
      
                // Unknown / Initial
                return _buildEmptyState(
                  icon: Icons.search_rounded,
                  message: "Search for a keyword to view its summary.",
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    final TextEditingController _textCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green1.withOpacity(0.12), width: 1.5),
        ),
        child: TextField(
          controller: _textCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ctrl.onSearchSubmit(val.trim());
              _textCtrl.clear();
            }
          },
          decoration: InputDecoration(
            hintText: "Search keywords...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _green1, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildParentView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.childrenList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final childName = ctrl.childrenList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green1.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ctrl.onKeywordTap(childName),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _bg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_tree_rounded, color: _green1, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        childName,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChildView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.summaryData.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final line = ctrl.summaryData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green1.withOpacity(0.15), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.check_circle_rounded, color: _green1, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  line,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 15,
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
}
