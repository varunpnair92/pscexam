import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/completed_exam_controller.dart';

class ProfilePage extends StatelessWidget {
  final AuthController auth = Get.find<AuthController>();
  final ResultController resultCtrl = Get.put(ResultController());

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B8A4E);
    const accentGold = Color(0xFFF5A623);

    return Scaffold(
      backgroundColor: Color(0xFFF4FBF4),
      body: CustomScrollView(
        slivers: [
          // ─── Profile Header ───
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryGreen, Color(0xFF27AE60)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        auth.fullName.value.isNotEmpty ? auth.fullName.value[0].toUpperCase() : "U",
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryGreen),
                      ),
                    ),
                    SizedBox(height: 15),
                    Obx(() => Text(
                      auth.fullName.value,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Obx(() => Text(
                        auth.userType.value.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Statistics Grid ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Statistics",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3320)),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _buildStatCard(
                        "Exams Taken", 
                        Obx(() => Text("${resultCtrl.exams.length}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen))),
                        Icons.assignment_turned_in_rounded,
                        primaryGreen,
                      ),
                      SizedBox(width: 15),
                      _buildStatCard(
                        "Courses", 
                        Obx(() => Text("${auth.courses.length}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentGold))),
                        Icons.book_rounded,
                        accentGold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Contact Info ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3320)),
                  ),
                  SizedBox(height: 10),
                  _infoTile(Icons.email_outlined, "Email", auth.email.value, primaryGreen),
                  _infoTile(Icons.phone_android_rounded, "Phone", auth.phone.value, primaryGreen),
                ],
              ),
            ),
          ),

          // ─── Recent Exams List ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Completed Exams",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3320)),
                  ),
                  SizedBox(height: 10),
                  Obx(() {
                    if (resultCtrl.isLoading.value) return Center(child: CircularProgressIndicator());
                    if (resultCtrl.exams.isEmpty) return Text("No exams completed yet.", style: TextStyle(color: Colors.grey));
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: resultCtrl.exams.length.clamp(0, 5), // Show last 5
                      itemBuilder: (context, index) {
                        final exam = resultCtrl.exams[index];
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                          child: ListTile(
                            leading: Icon(Icons.check_circle_rounded, color: primaryGreen),
                            title: Text(exam.examName, style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text("Score: ${exam.mark}"),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── Logout Button ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => auth.signOut(),
                  icon: Icon(Icons.logout_rounded, color: Colors.white),
                  label: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, Widget value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            value,
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value.isNotEmpty ? value : "Not provided", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}
