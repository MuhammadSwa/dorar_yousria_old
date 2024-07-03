import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yosria/common/helpers/helpers.dart';
import 'package:yosria/screens/library_screen/library_screen.dart';
import 'package:yosria/screens/library_screen/pdfViewer/markers_view.dart';
import 'package:yosria/screens/library_screen/pdfViewer/outline_view.dart';
import 'package:yosria/screens/library_screen/pdfViewer/search_view.dart';
import 'package:yosria/screens/library_screen/pdfViewer/thumbnails_view.dart';

class PdfviewerWidget extends StatefulWidget {
  const PdfviewerWidget({super.key, required this.title});
  final String title;

  @override
  State<PdfviewerWidget> createState() => _PdfviewerWidgetState();
}

class _PdfviewerWidgetState extends State<PdfviewerWidget> {
  final documentRef = ValueNotifier<PdfDocumentRef?>(null);
  final controller = PdfViewerController();
  final showLeftPane = ValueNotifier<bool>(false);
  final outline = ValueNotifier<List<PdfOutlineNode>?>(null);
  late final textSearcher = PdfTextSearcher(controller)..addListener(_update);
  final _markers = <int, List<Marker>>{};
  PdfTextRanges? _selectedText;

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    textSearcher.removeListener(_update);
    textSearcher.dispose();
    showLeftPane.dispose();
    outline.dispose();
    documentRef.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            showLeftPane.value = !showLeftPane.value;
          },
        ),
        title: Text(widget.title,style: const TextStyle(fontSize: 16),maxLines: 2,),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.circle,
              color: Colors.red,
            ),
            onPressed: () => _addCurrentSelectionToMarkers(Colors.red),
          ),
          IconButton(
            icon: const Icon(
              Icons.circle,
              color: Colors.green,
            ),
            onPressed: () => _addCurrentSelectionToMarkers(Colors.green),
          ),
          IconButton(
            icon: const Icon(
              Icons.circle,
              color: Colors.orangeAccent,
            ),
            onPressed: () => _addCurrentSelectionToMarkers(Colors.orangeAccent),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => controller.zoomUp(),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => controller.zoomDown(),
          ),
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: () => controller.goToPage(pageNumber: 1),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: () =>
                controller.goToPage(pageNumber: controller.pages.length),
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: ValueListenableBuilder(
              valueListenable: showLeftPane,
              builder: (context, showLeftPane, child) => SizedBox(
                width: showLeftPane ? 300 : 0,
                child: child!,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(1, 0, 4, 0),
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const TabBar(tabs: [
                        Tab(icon: Icon(Icons.search), text: 'Search'),
                        Tab(icon: Icon(Icons.menu_book), text: 'TOC'),
                        Tab(icon: Icon(Icons.image), text: 'Pages'),
                        Tab(icon: Icon(Icons.bookmark), text: 'Markers'),
                      ]),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // NOTE: documentRef is not explicitly used but it indicates that
                            // the document is changed.
                            ValueListenableBuilder(
                              valueListenable: documentRef,
                              builder: (context, documentRef, child) =>
                                  TextSearchView(
                                textSearcher: textSearcher,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: outline,
                              builder: (context, outline, child) => OutlineView(
                                outline: outline,
                                controller: controller,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: documentRef,
                              builder: (context, documentRef, child) =>
                                  ThumbnailsView(
                                documentRef: documentRef,
                                controller: controller,
                              ),
                            ),
                            MarkersView(
                              markers:
                                  _markers.values.expand((e) => e).toList(),
                              onTap: (marker) {
                                final rect =
                                    controller.calcRectForRectInsidePage(
                                  pageNumber: marker.ranges.pageText.pageNumber,
                                  rect: marker.ranges.bounds,
                                );
                                controller.ensureVisible(rect);
                              },
                              onDeleteTap: (marker) {
                                _markers[marker.ranges.pageNumber]!
                                    .remove(marker);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: getApplicationSupportDirectory(),
            builder: (context, snapshotDir) {
              final streamRef =
                  PdfDocumentRefUri(Uri.parse(booksTitles[widget.title]!));
              final fileRef = PdfDocumentRefFile(
                  '${snapshotDir.data?.path}/books/${widget.title}.pdf');
              return FutureBuilder(
                  future:
                      isFileDownloaded(title: widget.title, directory: 'books'),
                  builder: (context, snapshot) {
                    return Expanded(
                      child: Stack(
                        children: [
                          PdfViewer(
                            // PdfDocumentRefFile(
                            //     '${snapshotDir.data?.path}/books/${widget.title}.pdf'),
                            snapshot.data == true ? fileRef : streamRef,
                            controller: controller,
                            params: PdfViewerParams(
                              enableTextSelection: true,
                              maxScale: 8,
                              //
                              // Scroll-thumbs example
                              //
                              viewerOverlayBuilder: (context, size) => [
                                //
                                // Double-tap to zoom
                                //
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onDoubleTap: () {
                                    controller.zoomUp(loop: true);
                                  },
                                  child: IgnorePointer(
                                    child: SizedBox(
                                        width: size.width, height: size.height),
                                  ),
                                ),
                                //
                                // Scroll-thumbs example
                                //
                                // Show vertical scroll thumb on the right; it has page number on it
                                PdfViewerScrollThumb(
                                  controller: controller,
                                  orientation: ScrollbarOrientation.right,
                                  thumbSize: const Size(40, 25),
                                  thumbBuilder: (context, thumbSize, pageNumber,
                                          controller) =>
                                      Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: Text(
                                        pageNumber.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                // Just a simple horizontal scroll thumb on the bottom
                                PdfViewerScrollThumb(
                                  controller: controller,
                                  orientation: ScrollbarOrientation.bottom,
                                  thumbSize: const Size(80, 30),
                                  thumbBuilder: (context, thumbSize, pageNumber,
                                          controller) =>
                                      Container(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                              //
                              // Loading progress indicator example
                              //
                              loadingBannerBuilder:
                                  (context, bytesDownloaded, totalBytes) =>
                                      Center(
                                child: CircularProgressIndicator(
                                  value: totalBytes != null
                                      ? bytesDownloaded / totalBytes
                                      : null,
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                              //
                              // Link handling example
                              //
                              // GestureDetector/IgnorePointer propagate panning/zooming gestures to the viewer
                              linkWidgetBuilder: (context, link, size) =>
                                  MouseRegion(
                                cursor: SystemMouseCursors.click,
                                hitTestBehavior: HitTestBehavior.translucent,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    if (link.url != null) {
                                      navigateToUrl(link.url!);
                                    } else if (link.dest != null) {
                                      controller.goToDest(link.dest);
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: Container(
                                      color: Colors.blue.withOpacity(0.2),
                                      width: size.width,
                                      height: size.height,
                                    ),
                                  ),
                                ),
                              ),
                              pagePaintCallbacks: [
                                textSearcher.pageTextMatchPaintCallback,
                                _paintMarkers,
                              ],
                              onDocumentChanged: (document) async {
                                if (document == null) {
                                  documentRef.value = null;
                                  outline.value = null;
                                  _selectedText = null;
                                  _markers.clear();
                                }
                              },
                              onViewerReady: (document, controller) async {
                                documentRef.value = controller.documentRef;
                                outline.value = await document.loadOutline();
                              },
                              onTextSelectionChange: (selection) {
                                _selectedText = selection;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
          )
        ],
      ),
    );
  }

  void _paintMarkers(Canvas canvas, Rect pageRect, PdfPage page) {
    final markers = _markers[page.pageNumber];
    if (markers == null) {
      return;
    }
    for (final marker in markers) {
      final paint = Paint()
        ..color = marker.color.withAlpha(100)
        ..style = PaintingStyle.fill;

      for (final range in marker.ranges.ranges) {
        final f = PdfTextRangeWithFragments.fromTextRange(
          marker.ranges.pageText,
          range.start,
          range.end,
        );
        if (f != null) {
          canvas.drawRect(
            f.bounds.toRectInPageRect(page: page, pageRect: pageRect),
            paint,
          );
        }
      }
    }
  }

  void _addCurrentSelectionToMarkers(Color color) {
    if (controller.isReady &&
        _selectedText != null &&
        _selectedText!.isNotEmpty) {
      _markers
          .putIfAbsent(_selectedText!.pageNumber, () => [])
          .add(Marker(color, _selectedText!));
      setState(() {});
    }
  }

  Future<void> navigateToUrl(Uri url) async {
    if (await shouldOpenUrl(context, url)) {
      await launchUrl(url);
    }
  }

  Future<bool> shouldOpenUrl(BuildContext context, Uri url) async {
    final result = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Navigate to URL?'),
          content: SelectionArea(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                      text:
                          'Do you want to navigate to the following location?\n'),
                  TextSpan(
                    text: url.toString(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}


