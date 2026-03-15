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

/// {@template headline_tile_compact}
/// A shared widget to display a headline item with a small image at the start.
/// {@endtemplate}
class HeadlineTileCompact extends StatelessWidget {
  /// {@macro headline_tile_image_start}
  const HeadlineTileCompact({
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 120,
                child: Stack(
                  children: [
                    if (headline.imageUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          headline.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return ColoredBox(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                        ),
                      )
                    else
                      Positioned.fill(
                        child: ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      right: AppSpacing.xs,
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
                          children: [
                            if (headline.source.logoUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.xs,
                                ),
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundImage: NetworkImage(
                                    headline.source.logoUrl!,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                headline.source.name.getValue(context),
                                style: textTheme.labelSmall?.copyWith(
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
                    Positioned(
                      bottom: AppSpacing.xs,
                      left: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: Text(
                        formattedDate,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (headline.isBreaking)
                          TextSpan(
                            text: '${l10n.breakingNewsPrefix} - ',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        TextSpan(text: headline.title.getValue(context)),
                      ],
                    ),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
