import 'dart:async';
import 'dart:math';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:wasm_bug/data_provider.dart';
import 'package:web/web.dart' as web;

import 'common.dart';

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
    return PictureDataProvider(
      url: url,
      boxFit: boxFit,
      height: height,
      width: width,
      color: color,
      gradient: gradient,
      errorPlaceholder: errorPlaceHolder,
      errorPlaceholderColor: errorPlaceHolderColor,
      onRefresh: onRefresh,
      loadingWidget: loadingWidget,
      child: const _WebPicture(),
    );
  }
}

class _WebPicture extends StatefulWidget {
  const _WebPicture();

  @override
  State<_WebPicture> createState() => _WebPictureState();
}

class _WebPictureState extends State<_WebPicture> {
  PictureDataProvider get pictureProvider =>
      DataProvider.of<PictureDataProvider>(context, listen: false);

  String? baseUrl;

  late String realUrl;
  late String viewTypeKey;

  final _loaded = ValueNotifier<bool>(false);
  final _haveError = ValueNotifier<bool>(false);

  StreamSubscription<web.Event>? onLoadSubscription;
  StreamSubscription<web.Event>? onErrorSubscription;

  double? imageHeight;
  double? imageWidth;

  @override
  void initState() {
    super.initState();

    baseUrl = pictureProvider.url;

    imageHeight = pictureProvider.height;
    imageWidth = pictureProvider.width;

    viewTypeKey = generateViewTypeKey();

    changeUrl(pictureProvider.url);
    changeToHtml(realUrl);
  }

  @override
  void didUpdateWidget(covariant _WebPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (baseUrl != pictureProvider.url) {
      baseUrl = pictureProvider.url;
      onLoadSubscription?.cancel();
      onErrorSubscription?.cancel();
      changeUrl(pictureProvider.url);
      changeToHtml(realUrl);
    }
  }

  @override
  void dispose() {
    onLoadSubscription?.cancel();
    onErrorSubscription?.cancel();
    super.dispose();
  }

  String generateViewTypeKey() =>
      String.fromCharCodes(List.generate(64, (i) => Random().nextInt(33) + 89));

  void changeToHtml(String src) {
    final image = web.HTMLImageElement()
      ..src = src
      ..style.width = '100%'
      ..style.height = '100%';

    onLoadSubscription = image.onLoad.listen((_) {
      _loaded.value = true;
      setState(() {
        imageHeight = image.height.toDouble();
        imageWidth = image.width.toDouble();
      });
    });

    onErrorSubscription = image.onError.listen((_) {
      _haveError.value = true;
    });

    ui.platformViewRegistry.registerViewFactory(
      viewTypeKey,
      (int id) => image,
    );
  }

  void changeUrl(String newUrl) {
    _loaded.value = false;
    _haveError.value = false;
    realUrl = newUrl;
    final Uri? uri = Uri.tryParse(realUrl);
    if (uri != null && uri.scheme == 'assets') {
      final String? packageName = uri.queryParameters['packageName'];
      final String assetName = uri.path;
      realUrl = packageName == null
          ? assetName
          : 'assets/packages/$packageName/$assetName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final PictureDataProvider pictureProvider =
        DataProvider.of<PictureDataProvider>(context);

    final Widget child = SizedBox(
      height: imageHeight,
      width: imageWidth,
      child: Stack(
        children: [
          HtmlElementView(
            viewType: viewTypeKey,
          ),
          Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );

    final BoxFit? fit = pictureProvider.boxFit;

    return SizedBox(
      width: pictureProvider.width,
      height: pictureProvider.height,
      child: ListenableBuilder(
        listenable: _loaded,
        builder: (context, _) {
          if (_loaded.value) {
            if (fit != null) {
              return FittedBox(
                fit: fit,
                clipBehavior: Clip.antiAlias,
                child: child,
              );
            }
            return child;
          }
          return ListenableBuilder(
            listenable: _haveError,
            builder: (context, _) {
              if (_haveError.value) {
                if (fit != null) {
                  return FittedBox(
                    fit: fit,
                    clipBehavior: Clip.antiAlias,
                    child: pictureProvider.error,
                  );
                }
                return pictureProvider.error;
              }
              return pictureProvider.loading;
            },
          );
        },
      ),
    );
  }
}
