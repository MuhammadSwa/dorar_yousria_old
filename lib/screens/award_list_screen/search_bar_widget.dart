import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yosria/models/azkar_models.dart';

class SearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const SearchBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  String searchQuery = '';
  final List<String> fullList = allAzkar.getTitles();
  @override
  Widget build(BuildContext context) {
    return EasySearchBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      cancelableSuggestions: true,
      openOverlayOnSearch: true,
      title: const Padding(
          padding: EdgeInsets.only(right: 16), child: Text('الأوراد')),
      elevation: 0,
      suggestionTextStyle: const TextStyle(
        fontSize: 16,
        height: 2,
      ),
      animationDuration: const Duration(milliseconds: 100),
      searchTextDirection: TextDirection.rtl,
      onSearch: (query) => searchQuery = query,
      onSuggestionTap: (title) =>
          context.go('/awradScreen/zikr/$title'),
      suggestions: fullList,
    );
  }
}
