import 'package:flutter/material.dart';
import 'package:priv_shot/core/theme.dart';
import 'package:priv_shot/models/review_state.dart';

class PresetButtons extends StatelessWidget {
  final PresetMode activePreset;
  final ValueChanged<PresetMode> onPresetSelected;

  const PresetButtons({
    super.key,
    required this.activePreset,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Presets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PresetChip(
                label: 'Social',
                icon: Icons.people,
                isActive: activePreset == PresetMode.socialMedia,
                onTap: () => onPresetSelected(PresetMode.socialMedia),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: 'Financial',
                icon: Icons.account_balance,
                isActive: activePreset == PresetMode.financial,
                onTap: () => onPresetSelected(PresetMode.financial),
              ),
              const SizedBox(width: 8),
              _PresetChip(
                label: 'Full Privacy',
                icon: Icons.shield,
                isActive: activePreset == PresetMode.fullPrivacy,
                onTap: () => onPresetSelected(PresetMode.fullPrivacy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppTheme.primary : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}