import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/test_controller.dart';

class EntriHomePage extends StatelessWidget {
  final testController = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PSC Kerala")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 Resume Banner
            Card(
              color: Colors.blue.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.play_circle, size: 40),
                title: Text("Continue Mock Test"),
                subtitle: Text("LDC Mock Test 3"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Get.toNamed('/exam', arguments: {"id": 1});
                },
              ),
            ),

            SizedBox(height: 20),

            /// ⚡ Quick Actions
            Text("Quick Access",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _menu(Icons.quiz, "Mock", "/examMenu"),
                _menu(Icons.book, "Study", "/study"),
                _menu(Icons.flash_on, "Daily", "/daily"),
                _menu(Icons.bar_chart, "Result", "/result"),
                _menu(Icons.show_chart, "Progress", "/progress"),
              ],
            ),

            SizedBox(height: 20),

            /// 📚 Categories
            Text("Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _courseCard("LDC"),
                  _courseCard("Degree Level"),
                  _courseCard("10th Level"),
                ],
              ),
            ),

            SizedBox(height: 20),

            /// 📊 Performance
            Card(
              child: ListTile(
                leading: Icon(Icons.analytics, color: Colors.green),
                title: Text("Your Performance"),
                subtitle: Text("Accuracy: 72%"),
                trailing: Text("Improve"),
                onTap: () {
                  Get.toNamed('/progress');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu(IconData icon, String title, String route) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }

  Widget _courseCard(String title) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        child: Center(
          child: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}