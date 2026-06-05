import 'package:flutter/material.dart';
import 'package:priv_shot/core/theme.dart';
import 'package:priv_shot/models/redact_box.dart';

class DetectionChip extends StatelessWidget {
  final RedactBox box;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const DetectionChip({
    super.key,
    required this.box,
    required this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRedacting = box.shouldRedact;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRedacting
                ? AppTheme.primary.withOpacity(0.1)
                : AppTheme.surfaceDark.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRedacting
                  ? AppTheme.primary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isRedacting
                      ? AppTheme.primary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isRedacting ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: isRedacting ? AppTheme.primary : AppTheme.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      box.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      box.isAutoDetected ? 'Auto-detected' : 'User-drawn',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppTheme.accent),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}