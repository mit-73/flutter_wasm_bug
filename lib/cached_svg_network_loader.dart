import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CachedSvgNetworkLoader extends SvgNetworkLoader {
  const CachedSvgNetworkLoader(
    super.url, {
    super.theme,
    super.headers,
    super.colorMapper,
  });

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    try {
      final File file = await DefaultCacheManager().getSingleFile(url);
      return file.readAsBytes();
    } catch (e) {
      debugPrint(e.toString());

      return null;
    }
  }
}
