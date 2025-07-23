import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../providers/success_provider.dart';
import '../../models/success_entry.dart';
import '../../utils/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Journal des Succès'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SuccessProvider>(
        builder: (context, successProvider, child) {
          if (successProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (successProvider.successes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.star,
                    size: 64,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun succès enregistré',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez à célébrer vos victoires !',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildStats(context, successProvider),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: successProvider.successes.length,
                    itemBuilder: (context, index) {
                      final success = successProvider.successes[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 30.0,
                          child: FadeInAnimation(
                            child: _buildSuccessCard(context, success),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSuccessDialog(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Iconsax.star, color: Colors.white),
      ),
    );
  }

  Widget _buildStats(BuildContext context, SuccessProvider successProvider) {
    final totalSuccesses = successProvider.successes.length;
    final thisWeekSuccesses = successProvider.successes.where((s) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return s.date.isAfter(weekStart);
    }).length;
    
    final avgConfidenceImpact = totalSuccesses > 0 
        ? successProvider.successes.map((s) => s.confidenceImpact).reduce((a, b) => a + b) / totalSuccesses
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Total', totalSuccesses.toString(), Iconsax.star),
          _buildStatItem(context, 'Cette semaine', thisWeekSuccesses.toString(), Iconsax.calendar),
          _buildStatItem(context, 'Impact moyen', '${avgConfidenceImpact.toStringAsFixed(1)}/5', Iconsax.heart),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard(BuildContext context, SuccessEntry success) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(success.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getCategoryIcon(success.category),
                    color: _getCategoryColor(success.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        success.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(success.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < success.confidenceImpact ? Iconsax.star5 : Iconsax.star,
                      size: 16,
                      color: index < success.confidenceImpact 
                          ? AppTheme.warningColor 
                          : AppTheme.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              success.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            if (success.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: success.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(SuccessCategory category) {
    switch (category) {
      case SuccessCategory.professional:
        return AppTheme.primaryColor;
      case SuccessCategory.personal:
        return AppTheme.secondaryColor;
      case SuccessCategory.learning:
        return AppTheme.accentColor;
      case SuccessCategory.wellness:
        return AppTheme.warningColor;
      case SuccessCategory.social:
        return AppTheme.errorColor;
    }
  }

  IconData _getCategoryIcon(SuccessCategory category) {
    switch (category) {
      case SuccessCategory.professional:
        return Iconsax.briefcase;
      case SuccessCategory.personal:
        return Iconsax.heart;
      case SuccessCategory.learning:
        return Iconsax.book;
      case SuccessCategory.wellness:
        return Iconsax.health;
      case SuccessCategory.social:
        return Iconsax.people;
    }
  }

  void _showAddSuccessDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    SuccessCategory selectedCategory = SuccessCategory.personal;
    int selectedImpact = 3;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouveau succès'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du succès',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SuccessCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: SuccessCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryName(category)),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Impact sur la confiance'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImpact = index + 1;
                            });
                          },
                          child: Icon(
                            index < selectedImpact ? Iconsax.star5 : Iconsax.star,
                            size: 32,
                            color: index < selectedImpact 
                                ? AppTheme.warningColor 
                                : AppTheme.textSecondary.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  final success = SuccessEntry(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                    confidenceImpact: selectedImpact,
                  );
                  
                  Provider.of<SuccessProvider>(context, listen: false).addSuccess(success);
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Succès enregistré ! 🎉'),
                      backgroundColor: AppTheme.accentColor,
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(SuccessCategory category) {
    switch (category) {
      case SuccessCategory.professional:
        return 'Professionnel';
      case SuccessCategory.personal:
        return 'Personnel';
      case SuccessCategory.learning:
        return 'Apprentissage';
      case SuccessCategory.wellness:
        return 'Bien-être';
      case SuccessCategory.social:
        return 'Social';
    }
  }
}