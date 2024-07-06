import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:yosria/services/providers.dart';

class ZikrListViewTile extends StatelessWidget {
  const ZikrListViewTile({
    super.key,
    required this.title,
    required this.route,
  });
  final String title, route;

  @override
  Widget build(BuildContext context) {
    // TODO: this gets bookmarks everytime from sharedpreds
    // get it from static cache?
    // final bookmarks = context.watch<CoordinatesProvider>().getBookmarks();
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.chevron_right),
      leading: SizedBox(
          width: 35,
          child: GetBuilder<BookmarksController>(builder: (c) {
            return IconButton(
              highlightColor: Colors.lightGreenAccent,
              onPressed: () {
                final wasBookmark = c.toggleBookmark(title);
                final message = wasBookmark
                    ? 'تم الحذف من المحفوظات'
                    : 'تم الإضافة إلى المحفوظات';

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 700),
                    content: Text(message),
                  ),
                );
              },
              icon: c.bookmarks.contains(title)
                  ? const Icon(Icons.bookmark)
                  : const Icon(Icons.bookmark_outline_rounded),
            );
          })),
      onTap: () {
        context.go(route);
      },
    );
  }
}
