import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'auth_controller.dart';
import 'ui_utils.dart';
import 'dart:math' as math;

class DynamicStoryWidget extends StatefulWidget {
  final String title;
  final List items;
  final String? orientation;

  const DynamicStoryWidget({
    super.key,
    required this.title,
    required this.items,
    this.orientation,
  });

  @override
  State<DynamicStoryWidget> createState() => _DynamicStoryWidgetState();
}

class _DynamicStoryWidgetState extends State<DynamicStoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final HomeController ctrl = Get.find<HomeController>();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStoryItem(List items, int index, BuildContext context) {
    final item = items[index];
    final name = item['name'] ?? '';
    final icon = UIUtils.getIconForName(name);

    return GestureDetector(
      onTap: () => ctrl.navigateAttemptCategory(item),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 2 * math.pi,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Color(0xFFE1306C),
                              Color(0xFFF77737),
                              Color(0xFFFCAF45),
                              Color(0xFFE1306C),
                            ],
                            stops: [0.0, 0.33, 0.66, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFF1B8A4E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 66,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D3320),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List items, BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildStoryItem(items, index, context);
        },
      ),
    );
  }

  Widget _buildExpandedGrid(List items, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 0,
        runSpacing: 16,
        alignment: WrapAlignment.start,
        children: List.generate(items.length, (index) {
          return _buildStoryItem(items, index, context);
        }),
      ),
    );
  }

  Widget _buildFixedGrid(List items, BuildContext context) {
    final cardGradients = UIUtils.getPremiumGradients();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(Icons.lock_rounded, color: Colors.white, size: 28),
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

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final String orient = (widget.orientation ?? 'horizontal').toLowerCase().trim();
    final bool isFixed = orient == 'fixed';
    final bool isCollapse = orient == 'collapse';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.only(top: 14, bottom: isCollapse ? 2 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1B8A4E).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B8A4E).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: Text(
                  widget.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B8A4E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            if (isFixed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildFixedGrid(widget.items, context),
              )
            else if (isCollapse) ...[
              _isExpanded
                  ? _buildExpandedGrid(widget.items, context)
                  : _buildHorizontalList(widget.items, context),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ),
            ] else ...[
              // 'horizontal' orientation: Horizontal scrolling list ONLY, no collapse arrow
              _buildHorizontalList(widget.items, context),
            ],
          ],
        ),
      ),
    );
  }
}
