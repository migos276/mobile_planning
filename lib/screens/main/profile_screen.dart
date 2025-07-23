import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/success_provider.dart';
import '../../utils/theme.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Consumer3<AuthProvider, TaskProvider, SuccessProvider>(
        builder: (context, authProvider, taskProvider, successProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return AnimationLimiter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildProfileHeader(context, user),
                    const SizedBox(height: 24),
                    _buildStatsCards(context, user, taskProvider, successProvider),
                    const SizedBox(height: 24),
                    _buildBadges(context, user),
                    const SizedBox(height: 24),
                    _buildProgressSection(context, user),
                    const SizedBox(height: 24),
                    _buildMenuItems(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Iconsax.profile_circle,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Niveau ${user.confidenceLevel} - Confiance en développement',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, user, TaskProvider taskProvider, SuccessProvider successProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Tâches\nterminées',
            '${taskProvider.completedTasks.length}',
            Iconsax.task_square,
            AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Succès\nenregistrés',
            '${successProvider.successes.length}',
            Iconsax.star,
            AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Jours\nactifs',
            '${DateTime.now().difference(user.joinDate).inDays}',
            Iconsax.calendar,
            AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(BuildContext context, user) {
    final badges = [
      {'name': 'Premier succès', 'icon': Iconsax.star, 'earned': user.badges.contains('first-success')},
      {'name': 'Guerrière de la semaine', 'icon': Iconsax.award, 'earned': user.badges.contains('week-warrior')},
      {'name': 'Bâtisseuse de confiance', 'icon': Iconsax.heart, 'earned': user.badges.contains('confidence-builder')},
      {'name': 'Planificatrice pro', 'icon': Iconsax.task_square, 'earned': false},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes badges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: badges.map((badge) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badge['earned'] as bool 
                    ? AppTheme.warningColor.withOpacity(0.1)
                    : AppTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: badge['earned'] as bool 
                      ? AppTheme.warningColor
                      : AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    badge['icon'] as IconData,
                    color: badge['earned'] as bool 
                        ? AppTheme.warningColor
                        : AppTheme.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge['name'] as String,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: badge['earned'] as bool 
                          ? AppTheme.warningColor
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression confiance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Niveau ${user.confidenceLevel}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(user.confidenceLevel / 5 * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: user.confidenceLevel / 5,
            backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Continue à enregistrer tes succès pour développer ta confiance !',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'title': 'Paramètres', 'icon': Iconsax.setting, 'action': () => _showSettings(context)},
      {'title': 'Aide et support', 'icon': Iconsax.info_circle, 'action': () => _showHelp(context)},
      {'title': 'À propos', 'icon': Iconsax.document, 'action': () => _showAbout(context)},
      {'title': 'Se déconnecter', 'icon': Iconsax.logout, 'action': () => _logout(context)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;
          
          return InkWell(
            onTap: item['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: !isLast ? Border(
                  bottom: BorderSide(
                    color: AppTheme.textSecondary.withOpacity(0.1),
                  ),
                ) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: item['title'] == 'Se déconnecter' 
                        ? AppTheme.errorColor 
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: item['title'] == 'Se déconnecter' 
                            ? AppTheme.errorColor 
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres - À venir')),
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aide et support - À venir')),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: const Text(
          'ConfidenceBoost v1.0.0\n\n'
          'Votre compagnon quotidien pour planifier, réussir et développer votre confiance en vous.\n\n'
          'Développé avec ❤️ pour vous accompagner dans votre épanouissement personnel et professionnel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûre de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}