import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/completed_exam_controller.dart';
import 'package:psc_exam/app_config.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController auth = Get.find<AuthController>();
  final ResultController resultCtrl = Get.put(ResultController());

  List<dynamic> _allCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final res = await http.get(Uri.parse(AppConfig.courses));
      if (res.statusCode == 200) {
        setState(() {
          _allCourses = jsonDecode(res.body);
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
      setState(() => _isLoadingCourses = false);
    }
  }

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

          // ─── Course Selection ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Active Course",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D3320)),
                      ),
                      Obx(() => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auth.selectedCourseName.value,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 15),
                  if (_isLoadingCourses)
                    Center(child: CircularProgressIndicator())
                  else
                    _buildCourseList(primaryGreen),
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

  Widget _buildCourseList(Color primaryColor) {
    // 🌍 NO FILTERING: Show all courses so users know what they are missing!
    final role = auth.userType.value.toLowerCase().trim();
    final isPremium = role == "paid" || role == "trial";
    
    if (_allCourses.isEmpty) return Text("No alternative courses available.", style: TextStyle(color: Colors.grey));

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _allCourses.length,
        itemBuilder: (context, index) {
          final course = _allCourses[index];
          final id = course['id'];
          final name = course['name'] ?? "Unknown";
          final type = (course['course_type'] ?? 'free').toString().toLowerCase();
          final isCoursePremium = type != 'free';
          final hasAccess = isPremium || !isCoursePremium;
          
          return Obx(() {
            final isSelected = auth.selectedCourseId.value == id || auth.selectedCourseName.value == name;
            
            return GestureDetector(
              onTap: () {
                if (hasAccess) {
                  auth.updateSelectedCourse(id, name);
                } else {
                  // 🔒 PREMIUM UNLOCK MESSAGE
                  Get.snackbar(
                    "Premium Unlock Required",
                    "This course is available for Premium users. Unlock now to access!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                    icon: Icon(Icons.lock_outline_rounded, color: Colors.amber),
                  );
                }
              },
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 140,
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300, width: 2),
                      boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : (hasAccess ? Icons.book_outlined : Icons.lock_outline_rounded),
                          color: isSelected ? Colors.white : (hasAccess ? primaryColor : Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (hasAccess ? Colors.black87 : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!hasAccess)
                    Positioned(
                      top: 8,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("PREMIUM", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            );
          });
        },
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
