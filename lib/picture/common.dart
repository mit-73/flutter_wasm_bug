import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wasm_bug/cached_svg_network_loader.dart';
import 'package:wasm_bug/data_provider.dart';

/// {@template Picture}
///
/// Load all Picture (svg, png, jpg, ...) from assets & network.
///
/// Assets:
/// - "assets:test.png"
/// - "assets:test.png?packageName=packageTest"
/// - "assets:assets/images/test.png?packageName=packageTest"
/// - "assets:test.svg"
/// - "assets:test.svg?packageName=packageTest"
/// - "assets:assets/images/test.svg?packageName=packageTest"
///
/// Network:
/// - "https://mysite.ru/test.png"
/// - "https://mysite.ru/test.svg"
/// {@endtemplate}
@immutable
class Picture extends StatelessWidget {
  const Picture(
    this.url, {
    super.key,
    this.boxFit,
    this.height,
    this.width,
    this.color,
    this.gradient,
    this.errorPlaceHolder,
    this.errorPlaceHolderColor,
    this.onRefresh,
    this.loadingWidget,
  });

  final String url;
  final BoxFit? boxFit;
  final double? height;
  final double? width;
  final Color? color;
  final Gradient? gradient;
  final Widget? errorPlaceHolder;
  final Color? errorPlaceHolderColor;
  final VoidCallback? onRefresh;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    throw 'Platform not supported';
  }
}

@immutable
class PictureDataProvider extends StatefulWidget {
  const PictureDataProvider({
    super.key,
    required Widget child,
    required this.url,
    this.boxFit,
    this.height,
    this.width,
    this.color,
    this.gradient,
    this.errorPlaceholder,
    this.errorPlaceholderColor,
    this.onRefresh,
    this.loadingWidget,
  }) : _child = child;

  final Widget _child;
  final String url;
  final BoxFit? boxFit;
  final double? height;
  final double? width;
  final Color? color;
  final Gradient? gradient;
  final Widget? errorPlaceholder;
  final Color? errorPlaceholderColor;
  final VoidCallback? onRefresh;
  final Widget? loadingWidget;

  Uri? get uri => Uri.tryParse(url);

  Widget get loading => loadingWidget ?? SizedBox.shrink();

  Widget get error =>
      errorPlaceholder ??
      Refresh(
        color: errorPlaceholderColor,
        onRefresh: onRefresh,
      );

  ImageProvider<Object>? _networkImageProvider(String url) {
    if (url.isEmpty) return null;

    return CachedNetworkImageProvider(url);
  }

  ImageProvider<Object>? _assetImageProvider(
      String asset, String? packageName) {
    if (asset.isEmpty) return null;

    return AssetImage(asset, package: packageName);
  }

  Future<BytesLoader?> _networkSvgLoader(
      String url, BuildContext context) async {
    if (url.isEmpty) return null;

    final loader = CachedSvgNetworkLoader(url, theme: const SvgTheme());
    final isLoaded = await loader.prepareMessage(context);
    if (isLoaded == null) return null;
    return loader;
  }

  Future<BytesLoader?> _assetSvgLoader(
      String asset, String? packageName, BuildContext context) async {
    if (asset.isEmpty) return null;
    final loader = SvgAssetLoader(asset,
        packageName: packageName, theme: const SvgTheme());
    final isLoaded = await loader.prepareMessage(context);
    if (isLoaded == null) return null;
    return loader;
  }

  ImageProvider<Object>? getImage(Uri uri) {
    switch (uri.scheme) {
      case 'http':
      case 'https':
        return _networkImageProvider(uri.toString());
      case 'assets':
        return _assetImageProvider(
            uri.path, uri.queryParameters['packageName']);
    }

    return null;
  }

  Future<BytesLoader?>? getSvgProvider(Uri uri, BuildContext context) {
    switch (uri.scheme) {
      case 'http':
      case 'https':
        return _networkSvgLoader(uri.toString(), context);
      case 'assets':
        return _assetSvgLoader(
            uri.path, uri.queryParameters['packageName'], context);
    }

    return null;
  }

  @override
  State<PictureDataProvider> createState() => _PictureDataProviderState();
}

class _PictureDataProviderState extends State<PictureDataProvider> {
  @override
  void didUpdateWidget(covariant PictureDataProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {}
  }

  @override
  Widget build(BuildContext context) {
    return DataProvider<PictureDataProvider>(
      key: ValueKey(widget.url),
      data: widget,
      child: widget._child,
    );
  }
}

class Refresh extends StatelessWidget {
  const Refresh({super.key, this.color, required this.onRefresh});

  final Color? color;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Center(
        child: Icon(
          Icons.refresh,
          color: color,
          size: 24.0,
          semanticLabel: 'Text to announce in accessibility modes',
        ),
      ),
    );
  }
}
