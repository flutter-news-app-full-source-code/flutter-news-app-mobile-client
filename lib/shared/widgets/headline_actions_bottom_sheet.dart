import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:veritai_mobile/analytics/services/analytics_service.dart';
import 'package:veritai_mobile/app/bloc/app_bloc.dart';
import 'package:veritai_mobile/headlines_feed/bloc/headlines_feed_bloc.dart';
import 'package:veritai_mobile/l10n/l10n.dart';
import 'package:veritai_mobile/router/routes.dart';
import 'package:veritai_mobile/shared/constants/app_layout.dart';
import 'package:veritai_mobile/shared/widgets/feed_core/headline_tap_handler.dart';
import 'package:veritai_mobile/user_content/engagement/view/reactions_bottom_sheet.dart';
import 'package:veritai_mobile/user_content/reporting/view/report_content_bottom_sheet.dart';

/// {@template headline_actions_bottom_sheet}
/// A modal bottom sheet that displays secondary actions for a given headline,
/// such as saving, sharing, and reporting.
/// {@endtemplate}
class HeadlineActionsBottomSheet extends StatefulWidget {
  /// {@macro headline_actions_bottom_sheet}
  const HeadlineActionsBottomSheet({required this.headline, super.key});

  /// The headline for which to display actions.
  final Headline headline;

  @override
  State<HeadlineActionsBottomSheet> createState() =>
      _HeadlineActionsBottomSheetState();
}

class _HeadlineActionsBottomSheetState
    extends State<HeadlineActionsBottomSheet> {
  final bool _isBookmarking = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsX(context).l10n;
    final isBookmarked = context.select<AppBloc, bool>(
      (bloc) =>
          bloc.state.userContentPreferences?.savedHeadlines.any(
            (h) => h.id == widget.headline.id,
          ) ??
          false,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final remoteConfig = context.watch<AppBloc>().state.remoteConfig;
    final communityConfig = remoteConfig?.features.community;
    final isHeadlineReportingEnabled =
        (communityConfig?.enabled ?? false) &&
        (communityConfig?.reporting.headlineReportingEnabled ?? false);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxDialogContentWidth,
            ),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.chrome_reader_mode_outlined),
                  title: Text(l10n.readActionLabel),
                  onTap: () {
                    Navigator.of(context).pop();
                    // We bypass the handler logic here to avoid re-opening the sheet.
                    // This uses the core navigation utility.
                    HeadlineTapHandler.openHeadlineUrl(
                      context,
                      widget.headline,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_reaction_outlined),
                  title: Text(l10n.reactActionLabel),
                  onTap: () {
                    final feedBloc = context.read<HeadlinesFeedBloc>();
                    Navigator.of(context).pop();
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => BlocProvider.value(
                        value: feedBloc,
                        child: ReactionsBottomSheet(
                          headlineId: widget.headline.id,
                        ),
                      ),
                    );
                  },
                ),
                if (widget.headline.mentionedPersons.isNotEmpty ||
                    widget.headline.mentionedCountries.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.label_important_outline),
                    title: Text(l10n.mentionsActionLabel),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.pushNamed(
                        Routes.mentionedEntitiesName,
                        extra: widget.headline,
                      );
                    },
                  ),
                ListTile(
                  leading: _isBookmarking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(null),
                          ),
                        )
                      : Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        ),
                  title: Text(
                    isBookmarked
                        ? l10n.removeBookmarkActionLabel
                        : l10n.bookmarkActionLabel,
                  ),
                  iconColor: isBookmarked ? colorScheme.primary : null,
                  onTap: () {
                    context.read<AppBloc>().add(
                      AppBookmarkToggled(
                        headline: widget.headline,
                        isBookmarked: isBookmarked,
                        context: context,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: Text(l10n.shareActionLabel),
                  onTap: () {
                    // Pop the sheet before sharing to avoid it being open in the background.
                    Navigator.of(context).pop();
                    Share.share(widget.headline.url);
                    context.read<AnalyticsService>().logEvent(
                      AnalyticsEvent.contentShared,
                      payload: ContentSharedPayload(
                        contentId: widget.headline.id,
                        contentType: ContentType.headline.name,
                        // TODO(fulleni): We assume system share for now as we can't easily detect the
                        // specific app chosen by the user in the native sheet.
                        shareMedium: 'system',
                      ),
                    );
                  },
                ),
                if (isHeadlineReportingEnabled)
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: Text(l10n.reportActionLabel),
                    onTap: () async {
                      // Pop the current sheet before showing the new one.
                      Navigator.of(context).pop();
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ReportContentBottomSheet(
                          entityId: widget.headline.id,
                          reportableEntity: ReportableEntity.headline,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
