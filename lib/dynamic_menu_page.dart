import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dynamic_menu_controller.dart';
import 'auth_controller.dart';

class DynamicMenuPage extends StatelessWidget {
  final DynamicMenuController ctrl = Get.put(DynamicMenuController());

  DynamicMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(ctrl.keys.join(" > "))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ctrl.goBack,
        ),
      ),
      body: Obx(() {
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: ctrl.items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, i) {
            final item = ctrl.items[i];
            final title = ctrl.getTitle(item);
            
            final auth = AuthController.instance;
            final bool hasAccess = auth.canAccess(item);

            return GestureDetector(
              onTap: () => ctrl.onTileTap(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Opacity(
                        opacity: hasAccess ? 1.0 : 0.5,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (!hasAccess)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock_rounded,
                              color: Colors.black26,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    if (!hasAccess)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}