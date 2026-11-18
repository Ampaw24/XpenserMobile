import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/sheet_title.dart';
import 'package:flutter/material.dart';

/// One choice in [showAppOptionSheet].
class AppSelectOption<T> {
  const AppSelectOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  /// Tint for the icon tile and selection; defaults to the accent color.
  final Color? color;
}

/// Bottom-sheet single-select replacing dropdown menus app-wide.
/// Resolves to the chosen value, or null if dismissed. Set [searchable] for
/// long lists; it filters by label and subtitle.
Future<T?> showAppOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppSelectOption<T>> options,
  T? selected,
  bool searchable = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (_) => _OptionSheet<T>(
          title: title,
          options: options,
          selected: selected,
          searchable: searchable,
        ),
  );
}

class _OptionSheet<T> extends StatefulWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchable,
  });

  final String title;
  final List<AppSelectOption<T>> options;
  final T? selected;
  final bool searchable;

  @override
  State<_OptionSheet<T>> createState() => _OptionSheetState<T>();
}

class _OptionSheetState<T> extends State<_OptionSheet<T>> {
  String _query = '';

  List<AppSelectOption<T>> get _visible {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where(
          (o) =>
              o.label.toLowerCase().contains(query) ||
              (o.subtitle?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final options = _visible;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.screenSize.height * 0.7),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.contentGutter,
          0,
          context.contentGutter,
          context.rs(16) + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(widget.title),
            SizedBox(height: context.rs(12)),
            if (widget.searchable) ...[
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search_rounded, size: context.rs(20)),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              SizedBox(height: context.rs(12)),
            ],
            if (options.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.rs(24)),
                child: Text(
                  'No matches',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.rs(14),
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => SizedBox(height: context.rs(6)),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _OptionTile(
                    option: option,
                    isSelected: option.value == widget.selected,
                    onTap: () => Navigator.of(context).pop(option.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AppSelectOption<dynamic> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = option.color ?? palette.accent;
    final radius = BorderRadius.circular(context.rs(16));
    final tileSize = context.rs(40);

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color:
            isSelected ? color.withValues(alpha: 0.10) : palette.surfaceMuted,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(14),
              vertical: context.rs(option.icon == null ? 14 : 12),
            ),
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Container(
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(context.rs(12)),
                    ),
                    child: Icon(
                      option.icon,
                      size: context.rs(20),
                      color: color,
                    ),
                  ),
                  SizedBox(width: context.rs(12)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.rs(15),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: palette.textPrimary,
                        ),
                      ),
                      if (option.subtitle != null)
                        Text(
                          option.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.rs(12),
                            color: palette.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isSelected ? 1 : 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: context.rs(22),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
