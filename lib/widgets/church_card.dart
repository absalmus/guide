import 'package:flutter/material.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/core/utils/distance_utils.dart';
import 'package:stitch_smart_church_guide/models/church.dart';

class ChurchCard extends StatelessWidget {
  const ChurchCard({
    super.key,
    required this.church,
    this.onTap,
    this.compact = false,
  });

  final Church church;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: compact ? _buildCompact(theme) : _buildFull(theme),
      ),
    );
  }

  Widget _buildFull(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Image.network(
              church.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: AppColors.copticBurgundy.withValues(alpha: 0.1),
                child: const Icon(Icons.church, size: 48),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _StatusBadge(isOpen: church.isOpen),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                church.name,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    church.distanceKm != null
                        ? DistanceUtils.formatDistance(church.distanceKm!)
                        : church.governorate,
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(Icons.schedule, size: 16, color: AppColors.copticGold),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      church.nextLiturgy,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(ThemeData theme) {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            child: Image.network(
              church.imageUrl,
              width: 90,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 100,
                color: AppColors.copticBurgundy.withValues(alpha: 0.1),
                child: const Icon(Icons.church),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    church.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _StatusBadge(isOpen: church.isOpen, small: true),
                  const SizedBox(height: 4),
                  Text(
                    church.distanceKm != null
                        ? DistanceUtils.formatDistance(church.distanceKm!)
                        : church.governorate,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen, this.small = false});

  final bool isOpen;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.openGreen : AppColors.closedRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'مفتوح الآن' : 'مغلق الآن',
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
