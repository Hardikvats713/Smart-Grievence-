import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../models/grievance_model.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_step_progress_indicator.dart';

/// Screen 08 — Submit Grievance: Select Category.
class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({
    super.key,
    this.controller,
  });

  final GrievanceController? controller;

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  late final GrievanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
  }

  void _onCategorySelected(GrievanceCategory category) {
    _controller.selectCategory(category);

    // Route dynamically to category-specific forms (Screens 19, 20, 21) or standard Details (Screen 09)
    switch (category) {
      case GrievanceCategory.electricity:
        Navigator.of(context).pushNamed('/submit-grievance/electricity');
        break;
      case GrievanceCategory.waterSupply:
        Navigator.of(context).pushNamed('/submit-grievance/water-supply');
        break;
      case GrievanceCategory.sanitation:
        Navigator.of(context).pushNamed('/submit-grievance/sanitation');
        break;
      default:
        Navigator.of(context).pushNamed('/submit-grievance/details');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final selectedCategory = _controller.draft.category;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Bottom-right decorative wave
              Positioned(
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.85,
                    child: Image.asset(
                      'assets/images/category_bottom_right_wave.png',
                      width: 220,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      // Header
                      GrievanceHeader(
                        title: 'Submit a Grievance',
                        onBack: () => Navigator.of(context).maybePop(),
                      ),

                      // Stepper: Step 1
                      const GrievanceStepProgressIndicator(currentStep: 1),

                      const SizedBox(height: 12),
                      const Text(
                        'Select Category',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7 Category Cards Grid (2 columns)
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: GrievanceCategory.values.length,
                          itemBuilder: (context, index) {
                            final cat = GrievanceCategory.values[index];
                            final isSelected = selectedCategory == cat;

                            return _CategoryCard(
                              category: cat,
                              isSelected: isSelected,
                              onTap: () => _onCategorySelected(cat),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final GrievanceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 28,
                color: isSelected ? AppColors.accent : AppColors.primary,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
