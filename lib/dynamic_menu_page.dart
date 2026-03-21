import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dynamic_menu_controller.dart';

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

            return GestureDetector(
              onTap: () => ctrl.onTileTap(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}