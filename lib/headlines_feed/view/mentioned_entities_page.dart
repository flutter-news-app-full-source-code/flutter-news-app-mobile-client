import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:veritai_mobile/l10n/l10n.dart';
import 'package:veritai_mobile/router/routes.dart';
import 'package:veritai_mobile/shared/extensions/multilingual_map_extension.dart';

/// {@template mentioned_entities_page}
/// A page that displays a mixed list of all persons and countries mentioned
/// within a specific headline.
/// {@endtemplate}
class MentionedEntitiesPage extends StatelessWidget {
  /// {@macro mentioned_entities_page}
  const MentionedEntitiesPage({required this.headline, super.key});

  /// The headline containing the mentioned entities.
  final Headline headline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsX(context).l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final mentions = <FeedItem>[
      ...headline.mentionedPersons,
      ...headline.mentionedCountries,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mentionedEntitiesPageTitle)),
      body: SafeArea(
        child: ListView.separated(
          itemCount: mentions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = mentions[index];
            String id;
            ContentType type;
            Map<SupportedLanguage, String> nameMap;
            String? imageUrl;
            IconData fallbackIcon;

            if (item is Person) {
              id = item.id;
              type = ContentType.person;
              nameMap = item.name;
              imageUrl = item.imageUrl;
              fallbackIcon = Icons.person_outline;
            } else if (item is Country) {
              id = item.id;
              type = ContentType.country;
              nameMap = item.name;
              imageUrl = item.flagUrl;
              fallbackIcon = Icons.flag_outlined;
            } else {
              return const SizedBox.shrink();
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          fallbackIcon,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(fallbackIcon, color: colorScheme.onSurfaceVariant),
              ),
              title: Text(
                nameMap.getValue(context),
                style: theme.textTheme.titleMedium,
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                context.pushNamed(
                  Routes.entityDetailsName,
                  pathParameters: {'type': type.name, 'id': id},
                );
              },
            );
          },
        ),
      ),
    );
  }
}
