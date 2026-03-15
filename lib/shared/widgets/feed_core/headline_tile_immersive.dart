import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:veritai_mobile/ads/services/interstitial_ad_manager.dart';
import 'package:veritai_mobile/app/bloc/app_bloc.dart';
import 'package:veritai_mobile/l10n/l10n.dart';
import 'package:veritai_mobile/router/routes.dart';
import 'package:veritai_mobile/shared/extensions/multilingual_map_extension.dart';
import 'package:veritai_mobile/shared/widgets/feed_core/headline_tap_handler.dart';

/// {@template headline_tile_immersive}
/// A shared widget to display a headline item with a large image at the top.
/// {@endtemplate}
class HeadlineTileImmersive extends StatelessWidget {
  /// {@macro headline_tile_image_top}
  const HeadlineTileImmersive({
    required this.headline,
    super.key,
    this.onHeadlineTap,
    this.currentContextEntityType,
    this.currentContextEntityId,
  });

  /// The headline data to display.
  final Headline headline;

  /// Callback when the main content of the headline (e.g., title area) is tapped.
  final VoidCallback? onHeadlineTap;

  /// The type of the entity currently being viewed in detail (e.g., on a category page).
  final ContentType? currentContextEntityType;

  /// The ID of the entity currently being viewed in detail.
  final String? currentContextEntityId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizationsX(context).l10n;
    final currentLocale = context.watch<AppBloc>().state.locale;

    final formattedDate = timeago.format(
      headline.createdAt,
      locale: currentLocale.languageCode,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMedium,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap:
            onHeadlineTap ??
            () => HeadlineTapHandler.handleHeadlineTap(context, headline),
        child: SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (headline.imageUrl != null)
                Image.network(
                  headline.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: AppSpacing.xxl,
                    ),
                  ),
                )
              else
                ColoredBox(color: colorScheme.surfaceContainerHighest),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          await context
                              .read<InterstitialAdManager>()
                              .onPotentialAdTrigger();
                          if (!context.mounted) return;
                          await context.pushNamed(
                            Routes.entityDetailsName,
                            pathParameters: {
                              'type': ContentType.source.name,
                              'id': headline.source.id,
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (headline.source.logoUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.xs,
                                ),
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(
                                    headline.source.logoUrl!,
                                  ),
                                ),
                              ),
                            Flexible(
                              child: Text(
                                headline.source.name.getValue(context),
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      formattedDate,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (headline.isBreaking)
                        TextSpan(
                          text: '${l10n.breakingNewsPrefix} - ',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primaryContainer,
                          ),
                        ),
                      TextSpan(text: headline.title.getValue(context)),
                    ],
                  ),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
