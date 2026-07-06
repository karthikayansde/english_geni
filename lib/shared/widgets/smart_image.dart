import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io' as io;

class SmartImage extends StatelessWidget {
  final String? _networkUrl;
  final String? _assetPath;
  final String? _filePath;
  final Uint8List? _memoryBytes;
  final String? _base64String;
  final bool _isSvg;
  final double? width;
  final double? height;
  final BoxFit fit;
  final dynamic placeholder;
  final dynamic error;
  final Duration fadeOutDuration;
  final int? memCacheWidth;
  final int? maxWidthDiskCache;
  final Color? color;
  final double borderRadius; // Add this
  final BorderRadius? customBorderRadius; // Add this for custom radius

  const SmartImage._({
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
    this.fadeOutDuration = const Duration(milliseconds: 100),
    this.memCacheWidth,
    this.maxWidthDiskCache = 1600,
    this.borderRadius = 0, // Add default
    this.customBorderRadius, // Add this
    String? networkUrl,
    String? assetPath,
    String? filePath,
    Uint8List? memoryBytes,
    String? base64String,
    bool isSvg = false,
    this.color = Colors.black,
  })  : _networkUrl = networkUrl,
        _assetPath = assetPath,
        _filePath = filePath,
        _memoryBytes = memoryBytes,
        _base64String = base64String,
        _isSvg = isSvg;

  /// Network raster image (PNG, JPG, WebP, etc.)
  factory SmartImage.networkRaster({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    int? memCacheWidth,
    int? maxWidthDiskCache = 1600,
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      networkUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      memCacheWidth: memCacheWidth,
      maxWidthDiskCache: maxWidthDiskCache,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: false,
    );
  }

  /// Network SVG image
  factory SmartImage.networkSvg({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      networkUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: true,
    );
  }

  /// Asset raster image (PNG, JPG, WebP, etc.)
  factory SmartImage.assetRaster({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      assetPath: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: false,
    );
  }

  /// Asset SVG image
  factory SmartImage.assetSvg({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    dynamic placeholder,
    dynamic error,
    Color? color,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      assetPath: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      color: color,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: true,
    );
  }

  /// File system raster image (PNG, JPG, WebP, etc.)
  factory SmartImage.fileRaster({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      filePath: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: false,
    );
  }

  /// File system SVG image
  factory SmartImage.fileSvg({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      filePath: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: true,
    );
  }

  /// In-memory raster image bytes
  factory SmartImage.memoryRaster({
    required Uint8List bytes,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      memoryBytes: bytes,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: false,
    );
  }

  /// In-memory SVG image bytes
  factory SmartImage.memorySvg({
    required Uint8List bytes,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      memoryBytes: bytes,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: true,
    );
  }

  /// Base64-encoded raster image
  factory SmartImage.base64Raster({
    required String base64,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      base64String: base64,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: false,
    );
  }

  /// Base64-encoded SVG image
  factory SmartImage.base64Svg({
    required String base64,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    dynamic placeholder,
    dynamic error,
    Duration fadeOutDuration = const Duration(milliseconds: 100),
    double borderRadius = 0,
    BorderRadius? customBorderRadius,
  }) {
    return SmartImage._(
      base64String: base64,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      error: error,
      fadeOutDuration: fadeOutDuration,
      borderRadius: borderRadius,
      customBorderRadius: customBorderRadius,
      isSvg: true,
    );
  }

  /// Get BorderRadius based on borderRadius or customBorderRadius
  BorderRadius _getEffectiveBorderRadius() {
    if (customBorderRadius != null) {
      return customBorderRadius!;
    }
    return BorderRadius.circular(borderRadius);
  }

  /// Decodes base64 string, handling data URI prefixes
  Uint8List? _decodeBase64(String base64String) {
    try {
      String cleanBase64 = base64String;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s'), '');
      return base64Decode(cleanBase64);
    } catch (e) {
      debugPrint('❌ SmartImage: Failed to decode base64: $e');
      return null;
    }
  }

  /// Default placeholder icon (same size as image)
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: _getEffectiveBorderRadius(),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: _getIconSize(),
        ),
      ),
    );
  }

  /// Default error icon (same size as image)
  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: _getEffectiveBorderRadius(),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[600],
          size: _getIconSize(),
        ),
      ),
    );
  }

  /// Calculate icon size based on container size
  double _getIconSize() {
    final double? w = (width != null && width!.isFinite) ? width : null;
    final double? h = (height != null && height!.isFinite) ? height : null;

    if (w != null && h != null) {
      return (w + h) / 4;
    } else if (w != null) {
      return w / 2;
    } else if (h != null) {
      return h / 2;
    }
    return 48;
  }

  /// Build placeholder widget
  Widget _buildPlaceholder() {
    if (placeholder == null) return _buildDefaultPlaceholder();

    if (placeholder is Widget) return placeholder as Widget;

    if (placeholder is String && placeholder.toString().isNotEmpty) {
      if (placeholder.toString().toLowerCase().endsWith('.svg')) {
        return ClipRRect(
          borderRadius: _getEffectiveBorderRadius(),
          child: SvgPicture.asset(
            placeholder.toString(),
            width: width,
            height: height,
            fit: fit,
          ),
        );
      }
      return ClipRRect(
        borderRadius: _getEffectiveBorderRadius(),
        child: Image.asset(
          placeholder.toString(),
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
    return _buildDefaultPlaceholder();
  }

  /// Build error widget
  Widget _buildError() {
    if (error == null) return _buildDefaultError();

    if (error is Widget) return error as Widget;

    if (error is String && error.toString().isNotEmpty) {
      if (error.toString().toLowerCase().endsWith('.svg')) {
        return ClipRRect(
          borderRadius: _getEffectiveBorderRadius(),
          child: SvgPicture.asset(
            error.toString(),
            width: width,
            height: height,
            fit: fit,
          ),
        );
      }
      return ClipRRect(
        borderRadius: _getEffectiveBorderRadius(),
        child: Image.asset(
          error.toString(),
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
    return _buildDefaultError();
  }

  /// Build network SVG image
  Widget _buildNetworkSvg() {
    if (_networkUrl == null || _networkUrl.isEmpty) {
      debugPrint('❌ SmartImage: NetworkSvg URL is empty');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: SvgPicture.network(
        _networkUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _buildPlaceholder(),
      ),
    );
  }

  /// Build asset raster image
  Widget _buildAssetRaster() {
    if (_assetPath == null || _assetPath.isEmpty) {
      debugPrint('❌ SmartImage: AssetRaster path is empty');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: Image.asset(
        _assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ SmartImage: Asset not found: $_assetPath');
          return _buildError();
        },
      ),
    );
  }

  /// Build asset SVG image
  Widget _buildAssetSvg() {
    if (_assetPath == null || _assetPath.isEmpty) {
      debugPrint('❌ SmartImage: AssetSvg path is empty');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: SvgPicture.asset(
        _assetPath,
        width: width,
        height: height,
        fit: fit,
        color: color,
      ),
    );
  }

  /// Build file raster image
  Widget _buildFileRaster() {
    if (kIsWeb) {
      debugPrint('⚠️ SmartImage: FileRaster is not supported on Web');
      return _buildPlaceholder();
    }

    if (_filePath == null || _filePath.isEmpty) {
      debugPrint('❌ SmartImage: FileRaster path is empty');
      return _buildPlaceholder();
    }

    final file = io.File(_filePath);
    if (!file.existsSync()) {
      debugPrint('❌ SmartImage: File not found: $_filePath');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ SmartImage: Failed to load file: $_filePath - $error');
          return _buildError();
        },
      ),
    );
  }

  /// Build file SVG image
  Widget _buildFileSvg() {
    if (kIsWeb) {
      debugPrint('⚠️ SmartImage: FileSvg is not supported on Web');
      return _buildPlaceholder();
    }

    if (_filePath == null || _filePath.isEmpty) {
      debugPrint('❌ SmartImage: FileSvg path is empty');
      return _buildPlaceholder();
    }

    final file = io.File(_filePath);
    if (!file.existsSync()) {
      debugPrint('❌ SmartImage: SVG file not found: $_filePath');
      return _buildPlaceholder();
    }

    try {
      final bytes = file.readAsBytesSync();
      return ClipRRect(
        borderRadius: _getEffectiveBorderRadius(),
        child: SvgPicture.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    } catch (e) {
      debugPrint('❌ SmartImage: Error reading SVG file: $e');
      return _buildError();
    }
  }

  /// Build memory raster image
  Widget _buildMemoryRaster() {
    if (_memoryBytes == null || _memoryBytes.isEmpty) {
      debugPrint('❌ SmartImage: MemoryRaster bytes are empty');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: Image.memory(
        _memoryBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ SmartImage: Failed to decode memory bytes: $error');
          return _buildError();
        },
      ),
    );
  }

  /// Build memory SVG image
  Widget _buildMemorySvg() {
    if (_memoryBytes == null || _memoryBytes.isEmpty) {
      debugPrint('❌ SmartImage: MemorySvg bytes are empty');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: SvgPicture.memory(
        _memoryBytes,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  /// Build base64 raster image
  Widget _buildBase64Raster() {
    if (_base64String == null || _base64String.isEmpty) {
      debugPrint('❌ SmartImage: Base64Raster string is empty');
      return _buildPlaceholder();
    }

    final decoded = _decodeBase64(_base64String);
    if (decoded == null || decoded.isEmpty) {
      debugPrint('❌ SmartImage: Failed to decode base64 raster');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: Image.memory(
        decoded,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ SmartImage: Failed to decode base64 image: $error');
          return _buildError();
        },
      ),
    );
  }

  /// Build base64 SVG image
  Widget _buildBase64Svg() {
    if (_base64String == null || _base64String.isEmpty) {
      debugPrint('❌ SmartImage: Base64Svg string is empty');
      return _buildPlaceholder();
    }

    final decoded = _decodeBase64(_base64String);
    if (decoded == null || decoded.isEmpty) {
      debugPrint('❌ SmartImage: Failed to decode base64 SVG');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: _getEffectiveBorderRadius(),
      child: SvgPicture.memory(
        decoded,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      if (_networkUrl != null) return _buildNetworkSvg();
      if (_assetPath != null) return _buildAssetSvg();
      if (_filePath != null) return _buildFileSvg();
      if (_memoryBytes != null) return _buildMemorySvg();
      if (_base64String != null) return _buildBase64Svg();
    } else {
      // if (_networkUrl != null) return _buildNetworkRaster();
      if (_assetPath != null) return _buildAssetRaster();
      if (_filePath != null) return _buildFileRaster();
      if (_memoryBytes != null) return _buildMemoryRaster();
      if (_base64String != null) return _buildBase64Raster();
    }

    debugPrint('❌ SmartImage: No image source provided');
    return _buildPlaceholder();
  }
}