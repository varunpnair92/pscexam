import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'characteristic_controller.dart';
import 'characteristic_model.dart';
import 'modern_study_card.dart';
import 'psc_loading_logo.dart';

class CharacteristicPage extends StatelessWidget {
  CharacteristicPage({super.key});

  final CharacteristicController controller = Get.put(CharacteristicController());

  // ─── Green + White Palette ────────────────────────────────────
  static const _bg = Color(0xFFF4FBF4);
  static const _green1 = Color(0xFF1B8A4E);
  static const _green2 = Color(0xFF27AE60);
  static const _green3 = Color(0xFF52C97A);
  static const _textDark = Color(0xFF0D3320);

  @override
  Widget build(BuildContext context) {
    // Initial fetch if keyword passed in arguments
    final args = Get.arguments ?? {};
    final String initialKeyword = args['title'] ?? (args['keywords'] != null && (args['keywords'] as List).isNotEmpty ? args['keywords'][0] : "");
    final String targetCategory = args['category'] ?? "";
    
    if (initialKeyword.isNotEmpty && controller.currentKeyword.value != initialKeyword) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.fetchCharacteristics(initialKeyword);
        if (targetCategory.isNotEmpty && controller.characteristicMap.containsKey(targetCategory)) {
          controller.selectCategory(targetCategory);
        }
      });
    } else if (targetCategory.isNotEmpty && controller.characteristicMap.containsKey(targetCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectCategory(targetCategory);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _green1.withOpacity(0.4), width: 2),
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
               return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _buildBody(),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(
        child: PSCLoadingLogo(size: 80),
      );
    }

    if (controller.characteristicMap.isEmpty) {
      return _buildEmptyState();
    }

    if (controller.selectedCategory.isEmpty) {
      return _buildCategoryGrid();
    }

    return _buildTreeView();
  }

  Widget _buildHeader() {
    bool hasSelection = controller.selectedCategory.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_green1, _green2, _green3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  if (hasSelection) {
                    controller.clearSelection();
                  } else {
                    Get.back();
                  }
                },
              ),
              Expanded(
                child: Text(
                  hasSelection ? controller.selectedCategory.value : 'Characteristics',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!hasSelection) ...[
            const SizedBox(height: 16),
            _SearchBar(controller: controller),
          ],
        ],
      ),
    );
  }

  // ─── Grid of Category Cards ───────────────────────────────────
  Widget _buildCategoryGrid() {
    final categories = controller.characteristicMap.keys.toList();
    
    return GridView.builder(
      key: const ValueKey('grid'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final count = controller.characteristicMap[category]?.length ?? 0;

        return GestureDetector(
          onTap: () => controller.selectCategory(category),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _green1.withOpacity(0.12), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _green1.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _green1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: _green1, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '$count Questions',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Tree-View Detail ─────────────────────────────────────────
  Widget _buildTreeView() {
    final category = controller.selectedCategory.value;
    final questions = controller.characteristicMap[category] ?? [];

    return ListView.builder(
      key: const ValueKey('tree'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 40),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        
        return _TreeItem(
          index: index,
          question: q,
          isLast: index == questions.length - 1,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            controller.currentKeyword.isEmpty ? 'Search for a topic' : 'No characteristics found for "${controller.currentKeyword.value}"',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Individual Tree Node & Branch Widget ─────────────────────
class _TreeItem extends StatelessWidget {
  final int index;
  final CharacteristicQuestion question;
  final bool isLast;

  const _TreeItem({
    required this.index,
    required this.question,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── The Vertical Trunk & Node ───
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8A4E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1B8A4E).withOpacity(0.3), blurRadius: 4),
                  ],
                ),
              ),
              Expanded(
                child: isLast
                    ? const SizedBox.shrink()
                    : Container(
                        width: 2,
                        color: const Color(0xFF1B8A4E).withOpacity(0.3),
                      ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),

          // ─── The Branch Content ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2), // Align with node
                ModernStudyCard(
                  index: index,
                  q: {
                    "id": question.id,
                    "question": question.question,
                    "answer": question.answer,
                    "description": question.description,
                    "option1": question.option1,
                    "option2": question.option2,
                    "option3": question.option3,
                    "option4": question.option4,
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final CharacteristicController controller;
  const _SearchBar({required this.controller});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        textInputAction: TextInputAction.search,
        onSubmitted: (val) => widget.controller.fetchCharacteristics(val),
        decoration: InputDecoration(
          hintText: "Search keywords (e.g.Cricket)...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1B8A4E)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1B8A4E)),
            onPressed: () => widget.controller.fetchCharacteristics(_textController.text),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
