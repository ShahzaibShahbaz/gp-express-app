import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/page_transitions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

class GPProfileScreen extends StatefulWidget {
  const GPProfileScreen({Key? key}) : super(key: key);

  @override
  State<GPProfileScreen> createState() => _GPProfileScreenState();
}

class _GPProfileScreenState extends State<GPProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'gpEx',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                SlideUpRoute(page: const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            children: [
              // Profile Header Section with staggered animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.5 + (0.5 * value),
                                  child: child,
                                );
                              },
                              child: const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, size: 40, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.fullName ?? 'GP Name',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ?? 'email@example.com',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            if (user?.phoneNumber != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user!.phoneNumber!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Settings Section with delayed animation
              _buildAnimatedSection(
                title: 'Paramètres',
                delay: 0.2,
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Implement notifications settings
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Confidentialité',
                    onTap: () {
                      // TODO: Implement privacy settings
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.security,
                    title: 'Sécurité',
                    onTap: () {
                      // TODO: Implement security settings
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: 'Langue',
                    onTap: () {
                      // TODO: Implement language settings
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Help & Support Section with delayed animation
              _buildAnimatedSection(
                title: 'Aide & Support',
                delay: 0.3,
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Centre d\'aide',
                    onTap: () {
                      // TODO: Implement help center
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.article_outlined,
                    title: 'Termes et conditions',
                    onTap: () {
                      // TODO: Implement terms and conditions
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.policy_outlined,
                    title: 'Politique de confidentialité',
                    onTap: () {
                      // TODO: Implement privacy policy
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Logout Section with delayed animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final delayedValue = (_animationController.value - 0.4).clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - delayedValue)),
                    child: Opacity(
                      opacity: delayedValue,
                      child: Container(
                        color: Colors.white,
                        child: _buildSettingsTile(
                          icon: Icons.logout,
                          title: 'Déconnexion',
                          titleColor: Colors.red,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required List<Widget> children,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedValue = (_animationController.value - delay).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - delayedValue)),
          child: Opacity(
            opacity: delayedValue,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }
}