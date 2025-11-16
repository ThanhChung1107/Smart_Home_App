import 'package:flutter/material.dart';
import 'package:PBL4_smart_home/screens/schedule_screen.dart';
import 'package:PBL4_smart_home/screens/security_screen.dart';
import 'package:PBL4_smart_home/screens/setting_screnn.dart';
import 'package:PBL4_smart_home/screens/statistics_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'package:PBL4_smart_home/models/user.dart';
import 'camera_screen.dart';
import 'devices_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'SMART HOME',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.red.shade700),
                  onPressed: () async {
                    await AuthService.logout();
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    authProvider.logout();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // User Info Card - Premium Style
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          backgroundImage: user?.avatar != null
                              ? NetworkImage('http://your-server-ip:8000${user!.avatar!}')
                              : null,
                          child: user?.avatar == null
                              ? Icon(Icons.person, size: 32, color: Color(0xFF6366F1))
                              : null,
                        ),
                      ),
                      SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Người dùng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Text(
                                user?.role == 'admin' ? '👑 Chủ nhà'
                                    : user?.role == 'member' ? '👥 Thành viên'
                                    : '👤 Khách',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Các tính năng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Features Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _buildFeatureCard(
                  icon: Icons.devices_outlined,
                  title: 'Thiết bị',
                  subtitle: 'Điều khiển',
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  iconColor: Color(0xFF10B981),
                  context: context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DevicesScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.security_outlined,
                  title: 'Cảnh báo',
                  subtitle: 'Người lạ',
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  iconColor: Color(0xFFF59E0B),
                  context: context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecurityScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.analytics_outlined,
                  title: 'Thống kê',
                  subtitle: 'Năng lượng',
                  colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                  iconColor: Color(0xFFFCD34D),
                  context: context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StatisticsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.schedule_outlined,
                  title: 'Lịch trình',
                  subtitle: 'Tự động',
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  iconColor: Color(0xFFEF4444),
                  context: context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScheduleScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.camera_indoor_outlined,
                  title: 'Camera',
                  subtitle: 'Giám sát',
                  colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                  iconColor: Color(0xFFA855F7),
                  context: context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  subtitle: 'Hệ thống',
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  iconColor: Color(0xFF3B82F6),
                  context: context,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required Color iconColor,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Background decoration
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}