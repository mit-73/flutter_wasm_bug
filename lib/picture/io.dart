import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wasm_bug/data_provider.dart';

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
      child: const _IOPicture(),
    );
  }
}

class _IOPicture extends StatefulWidget {
  const _IOPicture();

  @override
  State<_IOPicture> createState() => _IOPictureState();
}

class _IOPictureState extends State<_IOPicture> {
  @override
  Widget build(BuildContext context) {
    final PictureDataProvider pictureProvider =
        DataProvider.of<PictureDataProvider>(context);

    final Uri? uri = pictureProvider.uri;

    if (uri == null) {
      return pictureProvider.error;
    }

    final bool isSvg = uri.path.endsWith('.svg');

    Widget? picture;
    if (isSvg) {
      final svg = pictureProvider.getSvgProvider(uri, context);
      if (svg != null) {
        picture = _Svg(svg: svg);
      }
    } else {
      final image = pictureProvider.getImage(uri);
      if (image != null) {
        picture = _Image(image: image);
      }
    }

    final gradient = pictureProvider.gradient;

    if (gradient != null && picture != null) {
      picture = ShaderMask(
        child: picture,
        shaderCallback: (Rect bounds) {
          final Rect rect = Rect.fromLTRB(
              0, 0, pictureProvider.width ?? 0, pictureProvider.height ?? 0);
          return gradient.createShader(rect);
        },
      );
    }

    return picture ?? pictureProvider.error;
  }
}

class _Svg extends StatelessWidget {
  const _Svg({
    required this.svg,
  });

  final Future<BytesLoader?> svg;

  @override
  Widget build(BuildContext context) {
    final PictureDataProvider pictureProvider =
        DataProvider.of<PictureDataProvider>(context);

    final gradient = pictureProvider.gradient;
    final color = gradient == null ? pictureProvider.color : null;
    final colorFilter =
        color == null ? null : ColorFilter.mode(color, BlendMode.srcIn);

    return SizedBox(
      width: pictureProvider.width,
      height: pictureProvider.height,
      child: FutureBuilder(
        future: svg,
        builder: (BuildContext context, AsyncSnapshot<BytesLoader?> snapshot) {
          final data = snapshot.data;

          if (snapshot.hasData && data != null) {
            return SvgPicture(
              data,
              fit: pictureProvider.boxFit ?? BoxFit.contain,
              width: pictureProvider.width,
              height: pictureProvider.height,
              colorFilter: colorFilter,
              placeholderBuilder: (_) => pictureProvider.loading,
            );
          }

          if (snapshot.hasError) {
            return pictureProvider.error;
          }

          return pictureProvider.loading;
        },
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.image,
  });

  final ImageProvider<Object> image;

  @override
  Widget build(BuildContext context) {
    final PictureDataProvider pictureProvider =
        DataProvider.of<PictureDataProvider>(context);

    final gradient = pictureProvider.gradient;

    return Image(
      image: image,
      fit: pictureProvider.boxFit,
      width: pictureProvider.width,
      height: pictureProvider.height,
      color: gradient == null ? pictureProvider.color : null,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return pictureProvider.loading;
      },
      errorBuilder: (_, e, st) {
        debugPrint('Error loading image: $e\n$st');
        return pictureProvider.error;
      },
    );
  }
}
